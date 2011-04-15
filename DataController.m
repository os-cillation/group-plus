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


static DataController *sharedDataController = nil;


@implementation DataController

- (id)init
{
    self = [super init];
    if (self) {
        [Database getConnection]; //TODO
        _systemAddressBook = [[SystemAddressBook alloc] init];
        if (!_systemAddressBook) {
            [self release];
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    if (sharedDataController == self)
        sharedDataController = nil;
    [_systemAddressBook release];
    [super dealloc];
}

+ (DataController *)dataController
{
    if (!sharedDataController)
        sharedDataController = [[[DataController alloc] init] autorelease];
    return sharedDataController;
}

- (NSArray *)getGroups:(NSString *)filter
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) { 
        return [_systemAddressBook getGroups:filter];
    } 
    else {
        return [Database getGroups:filter];
    }
}

- (BOOL)deleteGroup:(Group *)group error:(NSError **)outError
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        return [_systemAddressBook deleteGroup:[group getId] error:outError];
    }
    else {
        [Database deleteGroup:[group getId]];
        return TRUE;
    }
}

-(int)addGroup:(NSString *)name error:(NSError **)outError
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        return [_systemAddressBook addGroup:name error:outError];
    } 
    else {
        return [Database addGroup:name];
    }
}

- (BOOL)renameGroup:(Group *)group withName:(NSString *)name error:(NSError **)outError
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        return [_systemAddressBook renameGroup:[group getId] withName:name error:outError];
    } 
    else {
        [Database renameGroup:[group getId] withName:name];
        return TRUE;
    }
}

-(NSArray *)getGroupContacts:(Group *)group withFilter:(NSString *)filter
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        return [_systemAddressBook getGroupContacts:[group getId] withFilter:filter];
    }
    else {
        return [Database getGroupContacts:[group getId] withFilter:filter];
    }
}

- (BOOL)addGroupContact:(Group *)group withPerson:(ABRecordRef)person error:(NSError **)outError
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        return [_systemAddressBook addGroupContact:[group getId] withPersonId:ABRecordGetRecordID(person) error:outError];
    } 
    else {
        [Database addGroupContact:[group getId] withPerson:person];
        return TRUE;
    }
}

- (BOOL)deleteGroupContact:(Group *)group withPersonId:(ABRecordID)personId error:(NSError **)outError
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        return [_systemAddressBook deleteGroupContact:[group getId] withPersonId:personId error:outError];
    }
    else {
        [Database deleteGroupContact:[group getId] withContactId:personId];
        return TRUE;
    }
}

// Accessor methods for list
- (unsigned)countOfList:(NSString *)filter {
    int count;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        count = [[_systemAddressBook getGroups:filter]count];
    } else {
        count = [[Database getGroups:filter]count];
    }
    return count;
}

- (Group *)objectInListAtIndex:(unsigned)theIndex withFilter:(NSString *)filter {
    Group *group;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
        group = [[_systemAddressBook getGroups:filter]objectAtIndex:theIndex];
    } else {
        group = [[Database getGroups:filter]objectAtIndex:theIndex];
    }
	return group;
}

@end
