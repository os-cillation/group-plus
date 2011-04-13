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
#import "SystemAddressBook.h"


@implementation DataController

- (id)init {
    self = [super init];
    if (self) {
		[Database getConnection];
    }
    return self;
}

- (NSArray *)getGroups:(NSString *)filter {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) { 
        return [SystemAddressBook getGroups:filter];
    } else 
        return [Database getGroups:filter];
}

- (void)deleteGroup:(Group *)group {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        [SystemAddressBook deleteGroup:[group getId]];
    } else {
        [Database deleteGroup:[group getId]];
    }
}

-(int)addGroup:(NSString *)name {
    int groupId;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        groupId = [SystemAddressBook addGroup:name];
    } else {
        groupId = [Database addGroup:name];
    }
    return groupId;
}

- (void)renameGroup:(Group *)group withName:(NSString *)name {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        [SystemAddressBook renameGroup:[group getId] withName:name];
    } else {
        [Database renameGroup:[group getId] withName:name];
    }
}

-(NSArray *)getGroupContacts:(Group *)group withFilter:(NSString *)filter {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        return [SystemAddressBook getGroupContacts:[group getId] withFilter:filter];
    } else {
        return [Database getGroupContacts:[group getId] withFilter:filter];
    }
}

- (Boolean) addGroupContact:(Group *)group withPerson:(ABRecordRef)person {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        return [SystemAddressBook addGroupContact:[group getId] withPerson:person];
    } else {
        [Database addGroupContact:[group getId] withPerson:person];
    }
    return true;
}

- (void) deleteGroupContact:(Group *)group withPersonId:(ABRecordID)personId {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        [SystemAddressBook deleteGroupContact:[group getId] withContactId:personId];
    } else {
        [Database deleteGroupContact:[group getId] withContactId:personId];
    }
    
    
}

// Accessor methods for list
- (unsigned)countOfList:(NSString *)filter {
    int count;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        count = [[SystemAddressBook getGroups:filter]count];
    } else {
        count = [[Database getGroups:filter]count];
    }
    return count;
}

- (Group *)objectInListAtIndex:(unsigned)theIndex withFilter:(NSString *)filter {
    Group *group;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        group = [[SystemAddressBook getGroups:filter]objectAtIndex:theIndex];
    } else {
        group = [[Database getGroups:filter]objectAtIndex:theIndex];
    }
	return group;
}


- (void)dealloc {
    [super dealloc];
}

@end
