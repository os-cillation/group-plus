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

- (NSComparisonResult)compareByName:(GroupContact *)groupContact
{
    return [self.name compare:groupContact.name];
}

@end
