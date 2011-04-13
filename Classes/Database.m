//
//  Database.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "Database.h"
#import "Group.h"
#import "GroupContact.h"
#import "GroupsAppDelegate.h"


static sqlite3 *connection = NULL; // TODO


@implementation Database

+ (void)createEditableCopyOfDatabaseIfNeeded {
	NSLog(@"Creating editable copy of database...");

	BOOL success;
	NSFileManager *fileManager = [NSFileManager alloc];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
	success = [fileManager fileExistsAtPath:writableDBPath];
	if (success) return;
	[fileManager removeItemAtPath:writableDBPath error:&error];
	
	// The writeable database does not exist, so copy the default to the appropriate location
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"data.sqlite"];

	success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	if (!success) {
		//NSAssert1(0, @"Failed to create writeable database file with message'%@'.", [error localizedDescription]);
		NSLog(@"Failed to create writeable database");
	}
	
	
}

+ (sqlite3 *)getConnection {
	if (connection == NULL) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
        // Open the database.
        if (sqlite3_open([path UTF8String], &connection) == SQLITE_OK) {
            //NSLog(@"Databases successfully opened...");
        }
        else {
            //NSLog(@"Error while openening database...");
        }
        
        sqlite3_exec(connection, "ALTER TABLE groups ADD COLUMN abGroup TINYINT(1);", NULL, NULL, NULL);
        sqlite3_exec(connection, "ALTER TABLE groupContacts ADD COLUMN abGroup TINYINT(1);", NULL, NULL, NULL);
        
        sqlite3_exec(connection, "UPDATE groups SET abGroup = 0 WHERE abGroup isNull;", NULL, NULL, NULL);
        sqlite3_exec(connection, "UPDATE groupContacts SET abGroup = 0 WHERE abGroup isNull;", NULL, NULL, NULL);

		[self performSelectorOnMainThread:@selector(prepareGroupInfo) withObject:nil waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(prepareContactInfo) withObject:nil waitUntilDone:YES];
		[NSThread detachNewThreadSelector:@selector(prepareDuplicateInfo) toTarget:self withObject:nil];
	}
	return connection;
}

+ (void)refreshData {
	[self performSelectorOnMainThread:@selector(prepareGroupInfo) withObject:nil waitUntilDone:YES];
	[NSThread detachNewThreadSelector:@selector(prepareContactInfo) toTarget:self withObject:nil];
	[NSThread detachNewThreadSelector:@selector(prepareDuplicateInfo) toTarget:self withObject:nil];

	[[GroupsAppDelegate sharedAppDelegate] handleRefreshFinished];
}

+ (void)prepareGroupInfo {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSLog(@"prepare group info...");
	sqlite3 *db = connection;
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(db, "CREATE TABLE IF NOT EXISTS groups(id INTEGER PRIMARY KEY, name TEXT, abGroup TINYINT(1));", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
		if (sqlite3_prepare_v2(db, "DELETE FROM groups WHERE abGroup=1", -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
		
		ABAddressBookRef book = ABAddressBookCreate();
        NSArray *groups = [(NSArray *)ABAddressBookCopyArrayOfAllGroups(book) autorelease];
        for (CFIndex i = 0; i < [groups count]; ++i) {
			ABRecordRef group = (ABRecordRef)[groups objectAtIndex:i];
            NSString *groupName = [(NSString *)ABRecordCopyValue(group, kABGroupNameProperty) autorelease];
            if (sqlite3_prepare_v2(db, "INSERT OR REPLACE INTO groups(id,name,abGroup) VALUES(?,?,1)", -1, &statement, NULL) == SQLITE_OK) {
                sqlite3_bind_int(statement, 1, ABRecordGetRecordID(group));
                sqlite3_bind_text(statement, 2, [groupName UTF8String], -1, SQLITE_STATIC);
                sqlite3_step(statement);
                sqlite3_finalize(statement);
            }
		}
		CFRelease(book);
	}
	[pool release];
}

+ (void)prepareContactInfo {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSLog(@"prepare contact info...");
	sqlite3 *db = connection;
	sqlite3_stmt *statement;

	if (sqlite3_prepare_v2(db, "CREATE TABLE IF NOT EXISTS groupContacts(groupId INTEGER, id INTEGER, name TEXT, number TEXT, abGroup TINYINT(1), PRIMARY KEY(groupId, id, abGroup));", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
		if (sqlite3_prepare_v2(db, "DELETE FROM groupContacts WHERE abGroup=1;", -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }

		// query all groups from address book and import their contacts into our own database
		ABAddressBookRef book = ABAddressBookCreate();
        NSArray *groups = [(NSArray *)ABAddressBookCopyArrayOfAllGroups(book) autorelease];
        for (CFIndex i = 0; i < [groups count]; ++i) {
            ABRecordRef group = (ABRecordRef)[groups objectAtIndex:i];
            ABRecordID groupId = ABRecordGetRecordID(group);
            
            // query all contacts for this group
            NSArray *persons = [(NSArray *)ABGroupCopyArrayOfAllMembers(group) autorelease];
            for (CFIndex j = 0; j < [persons count]; ++j) {
                ABRecordRef person = (ABRecordRef)[persons objectAtIndex:j];
                ABRecordID personId = ABRecordGetRecordID(person);
                
                // determine the person's full name
                NSString *personName = nil;
                NSString *personFirstName = [(NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty) autorelease];
                NSString *personLastName = [(NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty) autorelease];
                if (personFirstName && personLastName) {
                    if (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst) {
                        personName = [NSString stringWithFormat:@"%@ %@", personFirstName, personLastName];
                    }
                    else {
                        personName = [NSString stringWithFormat:@"%@ %@", personLastName, personFirstName];
                    }
                }
                else if (personFirstName) {
                    personName = personFirstName;
                }
                else if (personLastName) {
                    personName = personLastName;
                }
                else {
                    personName = [(NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty) autorelease];
                }
                
                // determine the person's mobile phone number
                NSString *personPhone = nil;
                ABMultiValueRef personPhones = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
                if (personPhones) {
                    for (CFIndex k = 0; k < ABMultiValueGetCount(personPhones); ++k) {
                        NSString *label = [(NSString *)ABMultiValueCopyLabelAtIndex(personPhones, k) autorelease];
                        if (label && [label isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                            personPhone = [(NSString *)ABMultiValueCopyValueAtIndex(personPhones, k) autorelease];
                            break;
                        }
                    }
                    CFRelease(personPhones);
                }
                
                // insert the contact
                if (sqlite3_prepare_v2(db, "INSERT OR REPLACE INTO groupContacts(groupId, id, name, number, abGroup) VALUES (?, ?, ?, ?, 1)", -1, &statement, NULL) == SQLITE_OK) {
                    sqlite3_bind_int64(statement, 1, groupId);
                    sqlite3_bind_int64(statement, 2, personId);
                    if (personName) {
                        sqlite3_bind_text(statement, 3, [personName UTF8String], -1, SQLITE_STATIC);
                    }
                    else {
                        sqlite3_bind_null(statement, 3);
                    }
                    if (personPhone) {
                        sqlite3_bind_text(statement, 4, [personPhone UTF8String], -1, SQLITE_STATIC);
                    }
                    else {
                        sqlite3_bind_null(statement, 4);
                    }
                    sqlite3_step(statement);
                    sqlite3_finalize(statement);
                }
            }
        }
        CFRelease(book);
	}
	[pool release];
}

+ (NSArray *)getGroups:(NSString *)filter {
	NSMutableArray *groups = [[NSMutableArray alloc] init];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, "SELECT * FROM groups WHERE abGroup=? AND name LIKE ? ORDER BY name COLLATE NOCASE", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, [[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"] ? 1 : 0);
        if (filter && [filter length]) {
            sqlite3_bind_text(statement, 2, [[NSString stringWithFormat:@"%%%@%%", filter] UTF8String], -1, SQLITE_STATIC);
        }
        else {
            sqlite3_bind_text(statement, 2, "%", -1, SQLITE_STATIC);
        }
		while (sqlite3_step(statement) == SQLITE_ROW) {
            int64_t groupId = sqlite3_column_int64(statement, 0);
			const char *groupName = (const char *)sqlite3_column_text(statement, 1);
            int64_t groupCount = [Database getGroupContactsCount:groupId];

            Group *group = [[Group alloc] init];
            [group setId:groupId];
            [group setCount:groupCount];
            if (groupName) {
                [group setName:[NSString stringWithUTF8String:groupName]];
            }
			[groups addObject:group];
			[group release];
		}
        sqlite3_finalize(statement);
	}
	
	return [groups autorelease];
}

+ (int)addGroup:(NSString *)name {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
    ABRecordID groupId;
    if (sqlite3_prepare_v2(db, "INSERT INTO groups (name, abGroup) VALUES (?, ?)", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_int(statement, 2, [[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"] ? 1 : 0);
        sqlite3_step(statement);
        groupId = sqlite3_last_insert_rowid(db);
    }
    return groupId;
}

+ (void)deleteGroup:(ABRecordID)groupId {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, "DELETE FROM groups WHERE id=?", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int64(statement, 1, groupId);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
    
    if (sqlite3_prepare_v2(db, "DELETE FROM groupContacts WHERE groupId=?", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int64(statement, 1, groupId);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
}

+(void) renameGroup:(ABRecordID)groupId withName:(NSString *)name {
    sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, "UPDATE groups SET name=? WHERE id=?", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_int64(statement, 2, groupId);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
}

+ (int)getGroupContactsCount:(ABRecordID)groupId {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
    int count = 0;
    if (sqlite3_prepare_v2(db, "SELECT count(*) FROM groupContacts WHERE groupId=?", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int64(statement, 1, groupId);
		while (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
	return count;
}

+ (NSArray *)getGroupContacts:(ABRecordID)groupId withFilter:(NSString *)filter {
	NSMutableArray *contacts = [[NSMutableArray alloc] init];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, "SELECT * FROM groupContacts WHERE groupId=? AND name LIKE ? ORDER BY name COLLATE NOCASE", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int64(statement, 1, groupId);
        if (filter && [filter length]) {
            sqlite3_bind_text(statement, 2, [[NSString stringWithFormat:@"%%%@%%", filter] UTF8String], -1, SQLITE_STATIC);
        }
        else {
            sqlite3_bind_text(statement, 2, "%", -1, SQLITE_STATIC);
        }
        ABAddressBookRef book = ABAddressBookCreate();
        if (book) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                int64_t personId = sqlite3_column_int64(statement, 1);
                const char *personName = (const char *)sqlite3_column_text(statement, 2);
                const char *personNumber = (const char *)sqlite3_column_text(statement, 3);
                
                ABRecordRef person = ABAddressBookGetPersonWithRecordID(book, personId);
                if (person) {
                    GroupContact *contact = [[GroupContact alloc] init];
                    [contact setId:personId];
                    if (personName) {
                        [contact setName:[NSString stringWithUTF8String:personName]];
                    }
                    if (personNumber) {
                        [contact setNumber:[NSString stringWithUTF8String:personNumber]];
                    }
                    [contacts addObject:contact];
                    [contact release];
                }
                else {
                    [Database deleteGroupContact:groupId withContactId:personId];
                }
            }
            CFRelease(book);
        }
        sqlite3_finalize(statement);
	}
	
	return [contacts autorelease];
}

+ (void) addGroupContact:(ABRecordID)groupId withPerson:(ABRecordRef)person {
    ABRecordID contactId = ABRecordGetRecordID(person);
    NSString *fullName;
    NSString* firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString* lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if ((firstName == NULL) && (lastName == NULL)) {
        fullName = (NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
    }	
    else if ((firstName == NULL) || (lastName == NULL)) {
        if (firstName == NULL) {
            fullName = lastName;
        }
        if (lastName == NULL) {
            fullName = firstName;
        }
    }
    else {
        fullName = [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
    }
    
    NSString *phoneNumber = [NSString alloc];
    phoneNumber = @"";
    ABMultiValueRef phoneProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex	count = ABMultiValueGetCount(phoneProperty);
    for (CFIndex i=0; i < count; i++) {
        NSString *label = (NSString*)ABMultiValueCopyLabelAtIndex(phoneProperty, i);
        
        if(([label isEqualToString:(NSString*)kABPersonPhoneMobileLabel]) /*|| ([label isEqualToString:kABPersonPhoneIPhoneLabel])*/) {
            phoneNumber = (NSString*)ABMultiValueCopyValueAtIndex(phoneProperty, i);
            break;
        }
    }
    
    [Database addGroupContact:groupId withContactId:contactId withName:fullName withNumber:phoneNumber];
}

+ (void)addGroupContact:(ABRecordID)groupId withContactId:(ABRecordID)contactId withName:(NSString *)name withNumber:(NSString *)number {
	sqlite3 *db = connection;
	sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, "INSERT OR REPLACE INTO groupContacts (groupId, id, name, number, abGroup) VALUES (?, ?, ?, ?, ?)", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int64(statement, 1, groupId);
        sqlite3_bind_int64(statement, 2, contactId);
        sqlite3_bind_text(statement, 3, [name UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(statement, 4, [number UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_int(statement, 5, [[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]? 1 : 0);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
}

+ (void)deleteGroupContact:(ABRecordID)groupId withContactId:(ABRecordID)contactId {
	sqlite3 *db = connection;
	sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, "DELETE FROM groupContacts WHERE groupId=? AND id=?", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int64(statement, 1, groupId);
        sqlite3_bind_int64(statement, 2, contactId);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
}

+ (void)prepareDuplicateInfo {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSLog(@"prepare duplicate info...");
	sqlite3 *db = connection;
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(db, "DROP TABLE IF EXISTS contactDuplicateName", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
	
	if (sqlite3_prepare_v2(db, "CREATE TABLE IF NOT EXISTS contactDuplicateName(id INTEGER, name TEXT, numberCount INTEGER, foto TINYINT(1), email INTEGER)", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
	
	if (sqlite3_prepare_v2(db, "CREATE TABLE IF NOT EXISTS contactDuplicateNumber(id INTEGER, name TEXT, number TEXT)", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
	
	if (sqlite3_prepare_v2(db, "DELETE FROM contactDuplicateNumber", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
	
	ABAddressBookRef book = ABAddressBookCreate();
    if (book) {
        NSArray *contacts = [(NSArray *)ABAddressBookCopyArrayOfAllPeople(book) autorelease];
        for (CFIndex i = [contacts count]; --i >= 0; ) {
            ABRecordRef	person = (ABRecordRef)[contacts objectAtIndex:i];
            ABRecordID personId = ABRecordGetRecordID(person);

            // determine the person's full name
            NSString *personName = nil;
            NSString *personFirstName = [(NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty) autorelease];
            NSString *personLastName = [(NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty) autorelease];
            if (personFirstName && personLastName) {
                if (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst) {
                    personName = [NSString stringWithFormat:@"%@ %@", personFirstName, personLastName];
                }
                else {
                    personName = [NSString stringWithFormat:@"%@ %@", personLastName, personFirstName];
                }
            }
            else if (personFirstName) {
                personName = personFirstName;
            }
            else if (personLastName) {
                personName = personLastName;
            }
            else {
                personName = [(NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty) autorelease];
            }
            
            if (personName) {
                ABMultiValueRef phones = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
                if (phones) {
                    if (sqlite3_prepare_v2(db, "INSERT OR IGNORE INTO contactDuplicateName (id, name, numberCount, foto, email) VALUES (?, ?, ?, 0, 0)", -1, &statement, NULL) == SQLITE_OK) {
                        sqlite3_bind_int64(statement, 1, personId);
                        sqlite3_bind_text(statement, 2, [personName UTF8String], -1, SQLITE_STATIC);
                        sqlite3_bind_int(statement, 3, ABMultiValueGetCount(phones));
                        sqlite3_step(statement);
                        sqlite3_finalize(statement);
                    }
                    
                    for (CFIndex i = 0; i < ABMultiValueGetCount(phones); ++i) {
                        NSString *phone = [(NSString *)ABMultiValueCopyValueAtIndex(phones, i) autorelease];
                        phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
                        phone = [phone stringByReplacingOccurrencesOfString:@"+49" withString:@"0"];
                        
                        if (sqlite3_prepare_v2(db, "INSERT OR IGNORE INTO contactDuplicateNumber (id, name, number) VALUES (?, ?, ?)", -1, &statement, NULL) == SQLITE_OK) {
                            sqlite3_bind_int64(statement, 1, personId);
                            sqlite3_bind_text(statement, 2, [personName UTF8String], -1, SQLITE_STATIC);
                            sqlite3_bind_text(statement, 3, [phone UTF8String], -1, SQLITE_STATIC);
                            sqlite3_step(statement);
                            sqlite3_finalize(statement);
                        }
                    }
                    CFRelease(phones);
                }
            }
        }
        CFRelease(book);
    }
	[pool release];
}

+ (NSArray *)getDuplicateNameData {
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
	sqlite3_stmt *statement2;
    
    if (sqlite3_prepare_v2(db, "SELECT * FROM contactDuplicateName GROUP BY name HAVING count(*) > 1 ORDER BY name COLLATE NOCASE", -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            const char *name = (const char *)sqlite3_column_text(statement, 1);
            if (name) {
                if (sqlite3_prepare_v2(db, "SELECT id FROM contactDuplicateName WHERE name=?", -1, &statement2, NULL) == SQLITE_OK) {
                    NSMutableArray *contacts = [[NSMutableArray alloc] init];
                    sqlite3_bind_text(statement2, 1, name, -1, SQLITE_STATIC);
                    while (sqlite3_step(statement2) == SQLITE_ROW) {
                        GroupContact *contact = [[GroupContact alloc] init];
                        [contact setId:sqlite3_column_int64(statement2, 0)];
                        [contact setName:[NSString stringWithUTF8String:name]];
                        [contacts addObject:contact];
                        [contact release];
                    }
                    [data addObject:contacts];
                    [contacts release];
                    sqlite3_finalize(statement2);
                }
            }
        }
        sqlite3_finalize(statement);
    }

	return [data autorelease];
}

+ (NSArray *)getDuplicateNumberData {
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
	sqlite3_stmt *statement2;
    
    if (sqlite3_prepare_v2(db, "SELECT * FROM contactDuplicateNumber GROUP BY number HAVING count(*) > 1 ORDER BY name COLLATE NOCASE", -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            const char *number = (const char *)sqlite3_column_text(statement, 2);
            if (number) {
                if (sqlite3_prepare_v2(db, "SELECT id,name FROM contactDuplicateNumber WHERE number=?", -1, &statement2, NULL) == SQLITE_OK) {
                    NSMutableArray *contacts = [[NSMutableArray alloc] init];
                    sqlite3_bind_text(statement2, 1, number, -1, SQLITE_STATIC);
                    while (sqlite3_step(statement2) == SQLITE_ROW) {
                        GroupContact *contact = [[GroupContact alloc] init];
                        [contact setId:sqlite3_column_int64(statement2, 0)];
                        const char *name = (const char *)sqlite3_column_text(statement2, 1);
                        if (name) {
                            [contact setName:[NSString stringWithUTF8String:name]];
                        }
                        [contact setNumber:[NSString stringWithUTF8String:number]];
                        [contacts addObject:contact];
                        [contact release];
                    }
                    [data addObject:contacts];
                    [contacts release];
                    sqlite3_finalize(statement2);
                }
            }
        }
        sqlite3_finalize(statement);
    }
    
	return [data autorelease];
}

+ (NSArray *)getWithoutNumberData {
	NSMutableArray *contacts = [[NSMutableArray alloc] init];
	sqlite3 *db = connection;
	sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, "SELECT * FROM contactDuplicateName WHERE numberCount=0 ORDER BY name", -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int64_t contactId = sqlite3_column_int64(statement, 0);
            const char *contactName = (const char *)sqlite3_column_text(statement, 1);
            
            GroupContact *contact = [[GroupContact alloc] init];
            [contact setId:contactId];
            if (contactName) {
                [contact setName:[NSString stringWithUTF8String:contactName]];
            }
			[contacts addObject:contact];
			[contact release];

		}
        sqlite3_finalize(statement);
	}
	
	return [contacts autorelease];
}

+ (NSArray *)getWithoutEmailData:(NSString *)filter {
	NSMutableArray *contacts = [[NSMutableArray alloc] init];
	sqlite3 *db = connection;
	sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, "SELECT * FROM contactDuplicateName WHERE email=0 AND name LIKE ? ORDER BY name", -1, &statement, NULL) == SQLITE_OK) {
        if (filter && [filter length]) {
            sqlite3_bind_text(statement, 1, [[NSString stringWithFormat:@"%%%@%%", filter] UTF8String], -1, SQLITE_STATIC);
        }
        else {
            sqlite3_bind_text(statement, 1, "%", -1, SQLITE_STATIC);
        }
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int64_t contactId = sqlite3_column_int64(statement, 0);
            const char *contactName = (const char *)sqlite3_column_text(statement, 1);
            
            GroupContact *contact = [[GroupContact alloc] init];
            [contact setId:contactId];
            if (contactName) {
                [contact setName:[NSString stringWithUTF8String:contactName]];
            }
            [contacts addObject:contact];
            [contact release];
        }
        sqlite3_finalize(statement);
    }
	
	return [contacts autorelease];
}

+ (NSArray *)getWithoutFotoData:(NSString *)filter {
	NSMutableArray *contacts = [[NSMutableArray alloc] init];
	sqlite3 *db = connection;
	sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, "SELECT * FROM contactDuplicateName WHERE foto=0 AND name LIKE ? ORDER BY name", -1, &statement, NULL) == SQLITE_OK) {
        if (filter && [filter length]) {
            sqlite3_bind_text(statement, 1, [[NSString stringWithFormat:@"%%%@%%", filter] UTF8String], -1, SQLITE_STATIC);
        }
        else {
            sqlite3_bind_text(statement, 1, "%", -1, SQLITE_STATIC);
        }
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int64_t contactId = sqlite3_column_int64(statement, 0);
            const char *contactName = (const char *)sqlite3_column_text(statement, 1);
            
            GroupContact *contact = [[GroupContact alloc] init];
            [contact setId:contactId];
            if (contactName) {
                [contact setName:[NSString stringWithUTF8String:contactName]];
            }
            [contacts addObject:contact];
            [contact release];
        }
        sqlite3_finalize(statement);
    }
	
	return [contacts autorelease];
}

+ (void)deleteCleanUpContact:(int)contactId {
	sqlite3 *db = connection;
	sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, "DELETE FROM contactDuplicateName WHERE id=?", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int64(statement, 1, contactId);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
	
    if (sqlite3_prepare_v2(db, "DELETE FROM contactDuplicateNumber WHERE id=?", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int64(statement, 1, contactId);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
}

@end
