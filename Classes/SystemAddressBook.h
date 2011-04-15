//
//  SystemAdressBook.h
//  GroupPlus
//
//  Created by Dennis on 13.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>


@interface SystemAddressBook : NSObject {
    ABAddressBookRef _addressBook;
}

- (int)addGroup:(NSString *)name error:(NSError **)outError;
- (BOOL)deleteGroup:(ABRecordID)groupId error:(NSError **)outError;
- (BOOL)renameGroup:(ABRecordID)groupId withName:(NSString *)name error:(NSError **)outError;
- (NSArray *)getGroups:(NSString *)filter;
- (NSArray *)getGroupContacts:(ABRecordID)groupId withFilter:(NSString *)filter;
- (BOOL)addGroupContact:(ABRecordID)groupId withPersonId:(ABRecordID)personId error:(NSError **)outError;
- (BOOL)deleteGroupContact:(ABRecordID)groupId withPersonId:(ABRecordID)personId error:(NSError **)outError;

@end
