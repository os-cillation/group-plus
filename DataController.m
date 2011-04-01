//
//  DataController.m
//  GroupManager2
//
//  Created by Benjamin Mies on 24.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataController.h"
#import <AddressBook/AddressBook.h>

#import "Group.h"
#import "Database.h"


@implementation DataController

- (id)init {
    self = [super init];
    if (self) {
		[Database getConnection];
    }
    return self;
}

- (NSArray *)getGroups:(NSString *)filter {
	return [Database getGroups:filter];
}

- (void)deleteGroup:(Group *)group {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        ABAddressBookRef book = ABAddressBookCreate();
        if (book) {
            ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(book, [group getId]);
            if (groupRef) {
                ABAddressBookRemoveRecord(book, groupRef, nil);
                ABAddressBookSave(book, nil);
            }
            CFRelease(book);
        }
    }
	[Database deleteGroup:[group getId]];
}

// Accessor methods for list
- (unsigned)countOfList:(NSString *)filter {
    return [[Database getGroups:filter] count];
}

- (Group *)objectInListAtIndex:(unsigned)theIndex withFilter:(NSString *)filter {
    //return [list objectAtIndex:theIndex];
	return [[Database getGroups:filter] objectAtIndex:theIndex];
}


- (void)dealloc {
    [super dealloc];
}

@end
