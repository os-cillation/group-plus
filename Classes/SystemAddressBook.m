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

+(NSArray *)getGroups:(NSString *)filter {
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    ABAddressBookRef book = ABAddressBookCreate();
    NSArray *abGroups = [(NSArray *)ABAddressBookCopyArrayOfAllGroups(book) autorelease];
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
 
+(int) addGroup:(NSString *)nameString {
    ABAddressBookRef book = ABAddressBookCreate();
    if (book) {
        ABRecordRef groupRef = ABGroupCreate();
        ABRecordSetValue(groupRef, kABGroupNameProperty, nameString, nil);
        ABAddressBookAddRecord(book, groupRef, nil);
        ABAddressBookSave(book, nil);
        ABRecordID groupId = ABRecordGetRecordID(groupRef);
        CFRelease(book);
        return groupId;
    }
    return -1;
}

+ (void) deleteGroup:(ABRecordID)groupId {
    ABAddressBookRef book = ABAddressBookCreate();
    if (book) {
        ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(book, groupId);
        if (groupRef) {
            ABAddressBookRemoveRecord(book, groupRef, nil);
            ABAddressBookSave(book, nil);
        }
        CFRelease(book);
    }
}

+ (void) renameGroup:(ABRecordID)groupId withName:(NSString *)name {
    ABAddressBookRef book = ABAddressBookCreate();
    if (book) {
        ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(book, groupId);
        if (groupRef) {
            ABRecordSetValue(groupRef, kABGroupNameProperty, name, nil);
            ABAddressBookSave(book, nil);
        }
        CFRelease(book);
    }
}

+ (NSArray *) getGroupContacts:(ABRecordID)groupId withFilter:(NSString *)filter {
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    ABAddressBookRef book = ABAddressBookCreate();
    if (book) {
        ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(book, groupId);
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
        CFRelease(book);
    }

    
    return contacts;
}

+ (Boolean) addGroupContact:(ABRecordID) groupId withPerson:(ABRecordRef)person{
    Boolean worked = false;
    ABAddressBookRef book = ABAddressBookCreate();
    if (book) {
        ABRecordRef groupRef =  ABAddressBookGetGroupWithRecordID (book, groupId);
        ABAddressBookAddRecord(book, person, nil);
        ABAddressBookSave(book, nil);
        ABGroupRemoveMember(groupRef, person, nil);
        worked = ABGroupAddMember (groupRef, person, nil);
        ABAddressBookSave(book, nil);
        CFRelease(book);
    }
    return worked;
}

+ (void) deleteGroupContact:(ABRecordID)groupId withContactId:(ABRecordID)contactId {
    ABAddressBookRef book = ABAddressBookCreate();
    if (book) {
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(book, contactId);
        ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID (book, groupId);
        ABGroupRemoveMember(groupRef, person, nil);
        ABAddressBookSave(book, nil);
    }
    CFRelease(book);
}

@end
