//
//  AddressBookProtocol.h
//  GroupPlus
//
//  Created by Benedikt Meurer on 4/15/11.
//  Copyright 2011 Universität Siegen. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const AddressBookDidChangeNotification;

@protocol AddressBookProtocol <NSObject>

- (int64_t)addGroup:(NSString *)name error:(NSError **)outError;
- (BOOL)deleteGroup:(int64_t)groupId error:(NSError **)outError;
- (BOOL)renameGroup:(int64_t)groupId withName:(NSString *)name error:(NSError **)outError;
- (NSArray *)getGroups:(NSString *)filter;
- (NSArray *)getGroupContacts:(int64_t)groupId withFilter:(NSString *)filter;
- (BOOL)addGroupContact:(int64_t)groupId withPersonId:(int64_t)personId error:(NSError **)outError;
- (BOOL)deleteGroupContact:(int64_t)groupId withPersonId:(int64_t)personId error:(NSError **)outError;

@end
