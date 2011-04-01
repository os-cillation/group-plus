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

@interface Database : NSObject {

}

+ (void)createEditableCopyOfDatabaseIfNeeded;
+ (sqlite3 *)getConnection;
+ (NSArray *)getGroups:(NSString *)filter;
+ (int)addGroup:(ABRecordID)groupId withName:(NSString *)name;
+ (void)deleteGroup:(ABRecordID) groupId;
+ (NSArray *)getGroupContacts:(ABRecordID)groupId withFilter:(NSString *)filter;
+ (int)getGroupContactsCount:(ABRecordID)groupId;
+ (void)addGroupContact:(ABRecordID) groupId withContactId:(ABRecordID) contactId withName:(NSString *)name withNumber:(NSString *)number;
+ (void)deleteGroupContact:(ABRecordID) groupId withContactId:(ABRecordID) contactId;

+ (void)refreshData;
+ (void)prepareGroupInfo;
+ (void)prepareContactInfo;
+ (void)prepareDuplicateInfo;
+ (NSArray *)getDuplicateNameData;
+ (NSArray *)getDuplicateNumberData;
+ (NSArray *)getWithoutNumberData;
+ (NSArray *)getWithoutEmailData:(NSString *)filter;
+ (NSArray *)getWithoutFotoData:(NSString *)filter;
+ (void)deleteCleanUpContact:(int)contactId;

@end
