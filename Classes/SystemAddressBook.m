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
        ABAddressBookRegisterExternalChangeCallback(_addressBook, (ABExternalChangeCallback)&ABAddressBookRevert, NULL);
    }
    return self;
}

- (void)dealloc
{
    ABAddressBookUnregisterExternalChangeCallback(_addressBook, (ABExternalChangeCallback)&ABAddressBookRevert, NULL);
    CFRelease(_addressBook);
    [super dealloc];
}

- (NSArray *)getGroups:(NSString *)filter {
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    NSArray *abGroups = [(NSArray *)ABAddressBookCopyArrayOfAllGroups(_addressBook) autorelease];
    for (CFIndex i = 0; i < [abGroups count]; ++i) {
        ABRecordRef abGroup = (ABRecordRef)[abGroups objectAtIndex:i];
        NSString *groupName = [(NSString *)ABRecordCopyValue(abGroup, kABGroupNameProperty) autorelease];
        // Namen mit Filter prüfen
        NSRange textRange;
        if (filter && [filter length]) {
            textRange = [[groupName lowercaseString] rangeOfString:[filter lowercaseString]];
        }
        if (textRange.location!=NSNotFound) {
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
    return [groups autorelease];
}
 
- (int)addGroup:(NSString *)nameString {
    ABRecordID groupId = -1;
    ABRecordRef group = ABGroupCreate();
    if (group) {
        ABRecordSetValue(group, kABGroupNameProperty, nameString, NULL);
        ABAddressBookAddRecord(_addressBook, group, NULL);
        ABAddressBookSave(_addressBook, NULL);
        groupId = ABRecordGetRecordID(group);
        CFRelease(group);
    }
    return groupId;
}

- (void)deleteGroup:(ABRecordID)groupId {
    ABRecordRef group = ABAddressBookGetGroupWithRecordID(_addressBook, groupId);
    if (group) {
        ABAddressBookRemoveRecord(_addressBook, group, NULL);
        ABAddressBookSave(_addressBook, NULL);
    }
}

- (void)renameGroup:(ABRecordID)groupId withName:(NSString *)name {
    ABRecordRef group = ABAddressBookGetGroupWithRecordID(_addressBook, groupId);
    if (group) {
        ABRecordSetValue(group, kABGroupNameProperty, name, NULL);
        ABAddressBookSave(_addressBook, NULL);
    }
}

- (NSArray *)getGroupContacts:(ABRecordID)groupId withFilter:(NSString *)filter {
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(_addressBook, groupId);
    if (groupRef) {
        NSArray *persons = [(NSArray *)ABGroupCopyArrayOfAllMembers(groupRef) autorelease];
        
        for (CFIndex i = 0; i < [persons count]; ++i) {
            ABRecordRef person = (ABRecordRef) [persons objectAtIndex:i];
            if (person) {
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
                // Namen mit Filter prüfen
                NSRange textRange;
                if (filter && [filter length]) {
                    textRange = [[fullName lowercaseString] rangeOfString:[filter lowercaseString]];
                }
                if (textRange.location!=NSNotFound) {
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
    
    return [contacts autorelease];
}

- (Boolean)addGroupContact:(ABRecordID) groupId withPerson:(ABRecordRef)person
{
    Boolean worked = false;
    ABRecordRef group =  ABAddressBookGetGroupWithRecordID(_addressBook, groupId);
    if (group) {
        worked = ABAddressBookAddRecord(_addressBook, person, NULL);
        if (worked) {
            ABGroupRemoveMember(group, person, NULL);
            worked = ABGroupAddMember (group, person, NULL);
            if (worked) {
                worked = ABAddressBookSave(_addressBook, NULL);
            }
        }
    }
    if (!worked) {
        ABAddressBookRevert(_addressBook);
    }
    return worked;
}

- (void)deleteGroupContact:(ABRecordID)groupId withContactId:(ABRecordID)contactId {
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(_addressBook, contactId);
    if (person) {
        ABRecordRef group = ABAddressBookGetGroupWithRecordID (_addressBook, groupId);
        if (group) {
            if (ABGroupRemoveMember(group, person, NULL))
                ABAddressBookSave(_addressBook, NULL);
        }
    }
}

@end
