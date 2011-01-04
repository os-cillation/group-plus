//
//  Database.h
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <sqlite3.h>

sqlite3 *connection;

@interface Database : NSObject {

}

+ (void)createEditableCopyOfDatabaseIfNeeded;
+ (sqlite3 *)getConnection;
+ (NSMutableArray *)getGroups:(NSString *)filter;
+ (int)addGroup:(ABRecordID)groupId withName:(NSString *)name;
+ (void)deleteGroup:(ABRecordID) groupId;
+ (NSMutableArray *)getGroupContacts:(ABRecordID)groupId withFilter:(NSString *)filter;
+ (int)getGroupContactsCount:(ABRecordID)groupId;
+ (void)addGroupContact:(ABRecordID) groupId withContactId:(ABRecordID) contactId withName:(NSString *)name withNumber:(NSString *)number;
+ (void)deleteGroupContact:(ABRecordID) groupId withContactId:(ABRecordID) contactId;

+ (void)refreshData;
+ (void)prepareGroupInfo;
+ (void)prepareContactInfo;
+ (void)prepareDuplicateInfo;
+ (NSMutableArray *)getDuplicateNameData;
+ (NSMutableArray *)getDuplicateNumberData;
+ (NSMutableArray *)getWithoutNumberData;
+ (NSMutableArray *)getWithoutEmailData:(NSString *)filter;
+ (NSMutableArray *)getWithoutFotoData:(NSString *)filter;
+ (void)deleteCleanUpContact:(int)contactId;

@end
