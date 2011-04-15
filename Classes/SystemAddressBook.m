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


static void SystemAddressBookChangeCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context)
{
    ABAddressBookRevert(addressBook);
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
    ABAddressBookUnregisterExternalChangeCallback(_addressBook, &SystemAddressBookChangeCallback, self);
    CFRelease(_addressBook);
    [super dealloc];
}

- (NSArray *)getGroups:(NSString *)filter {
    NSMutableArray *groups = [NSMutableArray array];
    
    NSArray *abGroups = [(NSArray *)ABAddressBookCopyArrayOfAllGroups(_addressBook) autorelease];
    for (CFIndex i = 0; i < [abGroups count]; ++i) {
        ABRecordRef abGroup = (ABRecordRef)[abGroups objectAtIndex:i];
        NSString *groupName = [(NSString *)ABRecordCopyValue(abGroup, kABGroupNameProperty) autorelease];
        // Namen mit Filter prüfen
        NSRange textRange;
        if (filter && [filter length]) {
            textRange = [[groupName lowercaseString] rangeOfString:[filter lowercaseString]];
        }
        if (textRange.location != NSNotFound) {
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
        
    }
    [groups sortUsingSelector:@selector(compareByName:)];
    return groups;
}
 
- (int)addGroup:(NSString *)name error:(NSError **)outError {
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

- (BOOL)deleteGroup:(ABRecordID)groupId error:(NSError **)outError {
    ABRecordRef group = ABAddressBookGetGroupWithRecordID(_addressBook, groupId);
    if (group && ABAddressBookRemoveRecord(_addressBook, group, NULL)) {
        if (!ABAddressBookSave(_addressBook, (CFErrorRef *)outError)) {
            ABAddressBookRevert(_addressBook);
            return FALSE;
        }
    }
    return TRUE;
}

- (BOOL)renameGroup:(ABRecordID)groupId withName:(NSString *)name error:(NSError **)outError {
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

- (NSArray *)getGroupContacts:(ABRecordID)groupId withFilter:(NSString *)filter {
    NSMutableArray *contacts = [NSMutableArray array];
    ABRecordRef group = ABAddressBookGetGroupWithRecordID(_addressBook, groupId);
    if (group) {
        NSArray *persons = [(NSArray *)ABGroupCopyArrayOfAllMembersWithSortOrdering(group, kABPersonSortByLastName) autorelease];
        for (CFIndex i = 0; i < [persons count]; ++i) {
            ABRecordRef person = (ABRecordRef) [persons objectAtIndex:i];
            if (person) {
                ABRecordID contactId = ABRecordGetRecordID(person);
                NSString *fullName = [(NSString *)ABRecordCopyCompositeName(person) autorelease];
                
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
                // Namen mit Filter prüfen
                NSRange textRange;
                if (filter && [filter length]) {
                    textRange = [[fullName lowercaseString] rangeOfString:[filter lowercaseString]];
                }
                if (textRange.location != NSNotFound) {
                    GroupContact *contact = [[GroupContact alloc] init];
                    [contact setId:contactId];
                    [contact setName:fullName];
                    [contact setNumber:phoneNumber];
                    [contacts addObject:contact];
                    [contact release];
                }
            }
        }
    }
    
    return contacts;
}

- (BOOL)addGroupContact:(ABRecordID)groupId withPersonId:(ABRecordID)personId error:(NSError **)outError
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

- (BOOL)deleteGroupContact:(ABRecordID)groupId withPersonId:(ABRecordID)personId error:(NSError **)outError
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
