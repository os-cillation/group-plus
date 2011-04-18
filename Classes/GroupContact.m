//
//  GroupContact.m
//  Groups
//
//  Created by Benjamin Mies on 24.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GroupContact.h"


@implementation GroupContact

@synthesize uniqueId;
@synthesize name;
@synthesize number;
@synthesize image;

+ (GroupContact *)groupContactFromPerson:(ABRecordRef)person
{
    if (person) {
        // setup the group contact
        GroupContact *groupContact = [[[GroupContact alloc] init] autorelease];
        groupContact.uniqueId = ABRecordGetRecordID(person);
        groupContact.name = [(NSString *)ABRecordCopyCompositeName(person) autorelease];
        
        // figure out the phone number for the contact
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if (phones) {
            for (CFIndex i = 0; i < ABMultiValueGetCount(phones); ++i) {
                NSString *label = [(NSString *)ABMultiValueCopyLabelAtIndex(phones, i) autorelease];
                if ([label isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                    groupContact.number = [(NSString *)ABMultiValueCopyValueAtIndex(phones, i) autorelease];
                    break;
                }
            }
            CFRelease(phones);
        }
        
        return groupContact;
    }
    else {
        return nil;
    }
}

- (void)dealloc {
    [self setNumber:nil];
    [self setImage:nil];
    [self setName:nil];
	[super dealloc];
}

@end
