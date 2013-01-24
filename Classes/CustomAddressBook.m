/*-
 * Copyright 2012 os-cillation GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "CustomAddressBook.h"
#import "Group.h"
#import "GroupContact.h"
#import "GroupsAppDelegate.h"


NSString *const CustomAddressBookErrorDomain = @"CustomAddressBook";


@interface CustomAddressBook ()

- (void)addressBookChanged:(ABAddressBookRef)addressBook;
- (NSArray *)query:(NSString *)query withError:(NSError **)outError andParameters:(NSObject *)parameter, ...;
- (void)synchronize;

@end


static CustomAddressBook *customAddressBook = nil;


static void CustomAddressBookChangeCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context)
{
    CustomAddressBook *customAddressBook = (CustomAddressBook *)context;
    [customAddressBook addressBookChanged:addressBook];
}


@implementation CustomAddressBook

- (id)init
{
    self = [super init];
    if (self) {
        // connect to the system address book
        _addressBook = ABAddressBookCreate();
        if (!_addressBook) {
            [self release];
            return nil;
        }
        ABAddressBookRegisterExternalChangeCallback(_addressBook, &CustomAddressBookChangeCallback, self);
        
        // connect to the data.sqlite database
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
        if (sqlite3_open([path UTF8String], &_db) != SQLITE_OK) {
            [self release];
            return nil;
        }
        
        // create necessary tables
        sqlite3_exec(_db, "CREATE TABLE IF NOT EXISTS groups (id INTEGER PRIMARY KEY, name TEXT, abGroup TINYINT(1))", NULL, NULL, NULL);
        sqlite3_exec(_db, "CREATE TABLE IF NOT EXISTS groupContacts (groupId INTEGER, id INTEGER, name TEXT, number TEXT, abGroup TINYINT(1), PRIMARY KEY(groupId, id, abGroup))", NULL, NULL, NULL);
        
        // update the database file
        sqlite3_exec(_db, "ALTER TABLE groups ADD COLUMN abGroup TINYINT(1);", NULL, NULL, NULL);
        sqlite3_exec(_db, "ALTER TABLE groupContacts ADD COLUMN abGroup TINYINT(1);", NULL, NULL, NULL);
        sqlite3_exec(_db, "UPDATE groups SET abGroup = 0 WHERE abGroup isNull;", NULL, NULL, NULL);
        sqlite3_exec(_db, "UPDATE groupContacts SET abGroup = 0 WHERE abGroup isNull;", NULL, NULL, NULL);
        
        // synchronize database with address book
        [self synchronize];
    }
    return self;
}

- (void)dealloc
{
    if (customAddressBook == self)
        customAddressBook = nil;
    if (_addressBook) {
        ABAddressBookUnregisterExternalChangeCallback(_addressBook, &CustomAddressBookChangeCallback, self);
        CFRelease(_addressBook), _addressBook = NULL;
    }
    if (_db) {
        sqlite3_close(_db), _db = NULL;
    }
    [super dealloc];
}

- (void)addressBookChanged:(ABAddressBookRef)addressBook
{
    assert(_addressBook == addressBook);

    // synchronize with the system address book
    ABAddressBookRevert(_addressBook);
    [self synchronize];
    
    // notify all observers that the address book did change
    [[NSNotificationCenter defaultCenter] postNotificationName:AddressBookDidChangeNotification object:nil];
}

- (NSArray *)query:(NSString *)query withError:(NSError **)outError andParameters:(NSObject *)parameter, ...
{
    // compile the query into a statement
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_db, [query UTF8String], -1, &statement, NULL);
    if (result == SQLITE_OK) {
        // bind the parameters
        va_list ap;
        va_start(ap, parameter);
        for (int i = 1; result == SQLITE_OK && parameter; ++i) {
            if ([parameter isKindOfClass:[NSNumber class]]) {
                result = sqlite3_bind_int64(statement, i, (sqlite3_int64)[(NSNumber *)parameter longLongValue]);
            }
            else {
                result = sqlite3_bind_text(statement, i, [(NSString *)parameter UTF8String], -1, SQLITE_TRANSIENT);
            }
            parameter = va_arg(ap, NSObject *);
        }
        va_end(ap);
    }
    else {
        statement = NULL;
    }
    
    // execute the statement
    NSMutableArray *rows = [NSMutableArray array];
    if (result == SQLITE_OK) {
        // process the result rows
        for (;;) {
            result = sqlite3_step(statement);
            if (result != SQLITE_ROW) {
                result = sqlite3_reset(statement);
                break;
            }
            NSMutableArray *row = [[NSMutableArray alloc] init];
            for (int i = 0; i < sqlite3_column_count(statement); ++i) {
                NSString *cell = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, i)];
                [row addObject:cell];
            }
            [rows addObject:row];
            [row release];
        }
    }

    // propagate error in case of failure
    if (result != SQLITE_OK && outError) {
        *outError = [[NSError alloc] initWithDomain:[NSString stringWithUTF8String:sqlite3_errmsg(_db)] code:sqlite3_errcode(_db) userInfo:nil];
    }
    
    // cleanup statement
    if (statement) {
        sqlite3_finalize(statement);
    }

    return (result == SQLITE_OK) ? rows : nil;
}

- (void)synchronize
{
    [self query:@"BEGIN" withError:NULL andParameters:nil];
    NSArray *rows = [self query:@"SELECT DISTINCT id FROM groupContacts WHERE abGroup = 0" withError:NULL andParameters:nil];
    for (NSArray *row in rows) {
        int64_t personId = [(NSString *)[row objectAtIndex:0] longLongValue];
        if (!ABAddressBookGetPersonWithRecordID(_addressBook, personId)) {
            // person is no longer around, drop from groupContacts
            [self query:@"DELETE FROM groupContacts WHERE abGroup = 0 AND id = ?" withError:NULL andParameters:[NSNumber numberWithLongLong:personId], nil];
        }
    }
    [self query:@"COMMIT" withError:NULL andParameters:nil];
}

+ (id)customAddressBook
{
    if (customAddressBook == nil)
        customAddressBook = [[[CustomAddressBook alloc] init] autorelease];
    return customAddressBook;
}

- (int64_t)addGroup:(NSString *)name error:(NSError **)outError
{
    if ([self query:@"INSERT INTO groups (name, abGroup) VALUES (?, 0)" withError:outError andParameters:name, nil]) {
        int64_t groupId = sqlite3_last_insert_rowid(_db);
        [[NSNotificationCenter defaultCenter] postNotificationName:AddressBookDidChangeNotification object:nil];
        return groupId;
    }
    return -1;
}

- (BOOL)deleteGroup:(int64_t)groupId error:(NSError **)outError
{
    NSNumber *groupIdAsNumber = [NSNumber numberWithLongLong:(long long)groupId];
    if ([self query:@"DELETE FROM groups WHERE id=?" withError:outError andParameters:groupIdAsNumber, nil] && [self query:@"DELETE FROM groupContacts WHERE groupId=?" withError:outError andParameters:groupIdAsNumber, nil]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AddressBookDidChangeNotification object:nil];
        return TRUE;
    }
    else {
        return FALSE;
    }
}

- (BOOL)renameGroup:(int64_t)groupId withName:(NSString *)name error:(NSError **)outError
{
    NSNumber *groupIdAsNumber = [NSNumber numberWithLongLong:(long long)groupId];
    if ([self query:@"UPDATE groups SET name=? WHERE id=?" withError:outError andParameters:name, groupIdAsNumber, nil]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AddressBookDidChangeNotification object:nil];
        return TRUE;
    }
    else {
        return FALSE;
    }
}

- (NSArray *)getGroups:(NSString *)filter
{
    NSMutableArray *groups = [NSMutableArray array];
    NSError *error = nil;
    NSArray *rows = [self query:@"SELECT id, name FROM groups WHERE abGroup=0 AND name LIKE ? ORDER BY name COLLATE NOCASE" withError:&error andParameters:filter ? [NSString stringWithFormat:@"%%%@%%", filter] : @"%", nil];
    if (rows) {
        for (NSArray *row in rows) {
            int64_t groupId = [(NSString *)[row objectAtIndex:0] longLongValue];
            NSString *groupName = (NSString *)[row objectAtIndex:1];
            int groupCount = [(NSString *)[[[self query:@"SELECT count(*) FROM groupContacts WHERE abGroup=0 AND groupId=?" withError:NULL andParameters:[NSNumber numberWithLongLong:groupId], nil] objectAtIndex:0] objectAtIndex:0] intValue];
            
            Group *group = [[Group alloc] init];
            [group setId:groupId];
            [group setCount:groupCount];
            [group setName:groupName];
            [groups addObject:group];
            [group release];
        }
    }
    else {
        NSLog(@"Failed to query groups (%@)", [error localizedDescription]);
        [error release];
    }
    return groups;
}

- (NSArray *)getGroupContacts:(int64_t)groupId withFilter:(NSString *)filter
{
    NSMutableArray *groupContacts = [NSMutableArray array];
    NSError *error = nil;
    NSArray *rows = [self query:@"SELECT id FROM groupContacts WHERE abGroup=0 AND groupId=?" withError:&error andParameters:[NSNumber numberWithLongLong:groupId], nil];
    if (rows) {
        for (NSArray *row in rows) {
            GroupContact *groupContact = [GroupContact groupContactFromPerson:ABAddressBookGetPersonWithRecordID(_addressBook, [(NSString *)[row objectAtIndex:0] longLongValue])];
            if (groupContact) {
                if ([filter length]) {
                    NSRange textRange = [[groupContact.name lowercaseString] rangeOfString:[filter lowercaseString]];
                    if (textRange.location == NSNotFound) {
                        continue;
                    }
                }
                [groupContacts addObject:groupContact];
            }
        }
    }
    else {
        NSLog(@"Failed to query group contacts (%@)", [error localizedDescription]);
        [error release];
    }
    [groupContacts sortUsingSelector:@selector(compareByName:)];
    return groupContacts;
}

- (BOOL)addGroupContact:(int64_t)groupId withPersonId:(int64_t)personId error:(NSError **)outError
{
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(_addressBook, personId);
    if (!person) {
        if (outError)
            *outError = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
        return FALSE;
    }
    
    // determine the group contact's name and number
    NSString *name = [(NSString *)ABRecordCopyCompositeName(person) autorelease];
    NSString *number = @"";
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (phones) {
        for (CFIndex i = 0; i < ABMultiValueGetCount(phones); ++i) {
            NSString *label = [(NSString *)ABMultiValueCopyLabelAtIndex(phones, i) autorelease];
            if ([label isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                number = [(NSString *)ABMultiValueCopyValueAtIndex(phones, i) autorelease];
                break;
            }
        }
        CFRelease(phones);
    }
    
    // insert the record into the database
    if ([self query:@"INSERT OR REPLACE INTO groupContacts (groupId, id, name, number, abGroup) VALUES (?, ?, ?, ?, 0)" withError:outError andParameters:[NSNumber numberWithLongLong:groupId], [NSNumber numberWithLongLong:personId], name, number, nil]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AddressBookDidChangeNotification object:nil];
        return TRUE;
    }
    else {
        return FALSE;
    }
}

- (BOOL)deleteGroupContact:(int64_t)groupId withPersonId:(int64_t)personId error:(NSError **)outError
{
    if ([self query:@"DELETE FROM groupContacts WHERE groupId=? AND id=?" withError:outError andParameters:[NSNumber numberWithLongLong:groupId], [NSNumber numberWithLongLong:personId], nil]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AddressBookDidChangeNotification object:nil];
        return TRUE;
    }
    else {
        return FALSE;
    }
}

@end
