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
	ABAddressBookRef ab = ABAddressBookCreate();
	ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID (ab, [group getId]);
	if (groupRef != nil && groupRef != NULL) {
		ABAddressBookRemoveRecord(ab, groupRef, nil);
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
			ABAddressBookSave(ab, nil);
		}
	}
	[Database deleteGroup:[group getId]];
}

// Custom set accessor to ensure the new list is mutable
- (void)setList:(NSMutableArray *)newList {
    if (list != newList) {
        [list release];
        list = [newList mutableCopy];
    }
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
    [list release];
    [super dealloc];
}

@end
