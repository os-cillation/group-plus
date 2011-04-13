//
//  DataController.h
//  GroupManager2
//
//  Created by Benjamin Mies on 24.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <AddressBook/AddressBook.h>

@class Group;


@interface DataController : NSObject {
}

- (NSArray *)getGroups:(NSString *)filter;
- (unsigned)countOfList:(NSString *)filter;
- (Group *)objectInListAtIndex:(unsigned)theIndex withFilter:(NSString *)filter;
- (void)deleteGroup:(Group *)group;
- (int)addGroup:(NSString *) name;
- (void)renameGroup:(Group *)group withName:(NSString *)name;
- (NSArray *)getGroupContacts:(Group *) group withFilter:(NSString *)filter;
- (Boolean)addGroupContact:(Group *) group withPerson:(ABRecordRef) person;
- (void)deleteGroupContact:(Group *) group withPersonId:(ABRecordID) personId;



@end

