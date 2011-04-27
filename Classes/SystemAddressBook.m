//
//  SystemAdressBook.m
//  GroupPlus
//
//  Created by Dennis on 13.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SystemAddressBook.h"
#import "Group.h"
#import "GroupContact.h"


@interface SystemAddressBook ()

- (void)addressBookChanged:(ABAddressBookRef)addressBook;

@end


static SystemAddressBook *systemAddressBook = nil;


static void SystemAddressBookChangeCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context)
{
    SystemAddressBook *systemAddressBook = (SystemAddressBook *)context;
    [systemAddressBook addressBookChanged:addressBook];
}


@implementation SystemAddressBook

- (id)init
{
    self = [super init];
    if (self) {
        _addressBook = ABAddressBookCreate();
        if (!_addressBook) {
            [self release];
            return nil;
        }
        ABAddressBookRegisterExternalChangeCallback(_addressBook, &SystemAddressBookChangeCallback, self);
    }
    return self;
}

- (void)dealloc
{
    if (systemAddressBook == self)
        systemAddressBook = nil;
    if (_addressBook) {
        ABAddressBookUnregisterExternalChangeCallback(_addressBook, &SystemAddressBookChangeCallback, self);
        CFRelease(_addressBook);
    }
    [super dealloc];
}

- (void)addressBookChanged:(ABAddressBookRef)addressBook
{
    assert(_addressBook == addressBook);
    
    // discard local changes
    ABAddressBookRevert(_addressBook);
    
    // notify all observers that the address book did change
    [[NSNotificationCenter defaultCenter] postNotificationName:AddressBookDidChangeNotification object:nil];
}

+ (id)systemAddressBook
{
    if (systemAddressBook == nil)
        systemAddressBook = [[[SystemAddressBook alloc] init] autorelease];
    return systemAddressBook;
}

- (NSArray *)getGroups:(NSString *)filter {
    NSMutableArray *groups = [NSMutableArray array];
    
    NSArray *abGroups = [(NSArray *)ABAddressBookCopyArrayOfAllGroups(_addressBook) autorelease];
    for (CFIndex i = 0; i < [abGroups count]; ++i) {
        ABRecordRef abGroup = (ABRecordRef)[abGroups objectAtIndex:i];
        NSString *groupName = [(NSString *)ABRecordCopyValue(abGroup, kABGroupNameProperty) autorelease];
        // Namen mit Filter prüfen
        if ([filter length]) {
            NSRange textRang = [[groupName lowercaseString] rangeOfString:[filter lowercaseString]];
            if (textRang.location == NSNotFound) {
                continue;
            }
        }
        ABRecordID groupId = ABRecordGetRecordID(abGroup);
        NSArray *persons = [(NSArray *)ABGroupCopyArrayOfAllMembers(abGroup) autorelease];
        int groupCount = [persons count];
        
        Group *group = [[Group alloc] init];
        [group setId:groupId];
        [group setCount:groupCount];
        [group setName:groupName];
        [groups addObject:group];
        [group release];
    }
    [groups sortUsingSelector:@selector(compareByName:)];
    return groups;
}
 
- (int64_t)addGroup:(NSString *)name error:(NSError **)outError {
    ABRecordRef group = ABGroupCreate();
    if (!group) {
        if (outError)
            *outError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:ENOMEM userInfo:nil];
        return -1;
    }
    if (!ABRecordSetValue(group, kABGroupNameProperty, name, (CFErrorRef *)outError) || !ABAddressBookAddRecord(_addressBook, group, (CFErrorRef *)outError)) {
        CFRelease(group);
        return -1;
    }
    if (!ABAddressBookSave(_addressBook, (CFErrorRef *)outError)) {
        ABAddressBookRevert(_addressBook);
        CFRelease(group);
        return -1;
    }
    
    ABRecordID groupId = ABRecordGetRecordID(group);
    CFRelease(group);
    
    return groupId;
}

- (BOOL)deleteGroup:(int64_t)groupId error:(NSError **)outError {
    ABRecordRef group = ABAddressBookGetGroupWithRecordID(_addressBook, groupId);
    if (group && ABAddressBookRemoveRecord(_addressBook, group, NULL)) {
        if (!ABAddressBookSave(_addressBook, (CFErrorRef *)outError)) {
            ABAddressBookRevert(_addressBook);
            return FALSE;
        }
    }
    return TRUE;
}

- (BOOL)renameGroup:(int64_t)groupId withName:(NSString *)name error:(NSError **)outError {
    ABRecordRef group = ABAddressBookGetGroupWithRecordID(_addressBook, groupId);
    if (!group) {
        if (outError)
            *outError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
        return FALSE;
    }
    if (!ABRecordSetValue(group, kABGroupNameProperty, name, (CFErrorRef *)outError)) {
        return FALSE;
    }
    if (!ABAddressBookSave(_addressBook, (CFErrorRef *)outError)) {
        ABAddressBookRevert(_addressBook);
        return FALSE;
    }
    return TRUE;
}

- (NSArray *)getGroupContacts:(int64_t)groupId withFilter:(NSString *)filter {
    NSMutableArray *groupContacts = [NSMutableArray array];
    ABRecordRef group = ABAddressBookGetGroupWithRecordID(_addressBook, groupId);
    if (group) {
        NSArray *persons = [(NSArray *)ABGroupCopyArrayOfAllMembersWithSortOrdering(group, kABPersonSortByLastName) autorelease];
        for (CFIndex i = 0; i < [persons count]; ++i) {
            GroupContact *groupContact = [GroupContact groupContactFromPerson:[persons objectAtIndex:i]];
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
    
    return groupContacts;
}

- (BOOL)addGroupContact:(int64_t)groupId withPersonId:(int64_t)personId error:(NSError **)outError
{
    ABRecordRef group = ABAddressBookGetGroupWithRecordID(_addressBook, groupId);
    if (!group) {
        if (outError)
            *outError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
        return FALSE;
    }
    
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(_addressBook, personId);
    if (!person) {
        if (outError)
            *outError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
        return FALSE;
    }
    
    if (!ABGroupAddMember(group, person, (CFErrorRef *)outError)) {
        return FALSE;
    }
    
    if (!ABAddressBookSave(_addressBook, (CFErrorRef *)outError)) {
        ABAddressBookRevert(_addressBook);
        return FALSE;
    }

    return TRUE;
}

- (BOOL)deleteGroupContact:(int64_t)groupId withPersonId:(int64_t)personId error:(NSError **)outError
{
    ABRecordRef group = ABAddressBookGetGroupWithRecordID(_addressBook, groupId);
    if (!group) {
        if (outError)
            *outError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
        return FALSE;
    }
    
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(_addressBook, personId);
    if (!person) {
        if (outError)
            *outError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
        return FALSE;
    }
    
    if (!ABGroupRemoveMember(group, person, (CFErrorRef *)outError)) {
        return FALSE;
    }
    
    if (!ABAddressBookSave(_addressBook, (CFErrorRef *)outError)) {
        ABAddressBookRevert(_addressBook);
        return FALSE;
    }
    
    return TRUE;
}

@end
