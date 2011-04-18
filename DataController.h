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

+ (DataController *)dataController;

- (NSArray *)getGroups:(NSString *)filter;
- (unsigned)countOfList:(NSString *)filter;
- (Group *)objectInListAtIndex:(unsigned)theIndex withFilter:(NSString *)filter;
- (BOOL)deleteGroup:(Group *)group error:(NSError **)outError;
- (int)addGroup:(NSString *)name error:(NSError **)outError;
- (BOOL)renameGroup:(Group *)group withName:(NSString *)name error:(NSError **)outError;
- (NSArray *)getGroupContacts:(Group *)group withFilter:(NSString *)filter;
- (BOOL)addGroupContact:(Group *)group withPerson:(ABRecordRef)person error:(NSError **)outError;
- (BOOL)deleteGroupContact:(Group *)group withPersonId:(ABRecordID)personId error:(NSError **)outError;

@end

