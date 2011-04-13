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
    
    
}

+ (int)addGroup:(NSString *)name;
+ (void)deleteGroup:(ABRecordID) groupId;
+ (void)renameGroup:(ABRecordID) groupId withName:(NSString *) name;
+ (NSArray *)getGroups:(NSString *)filter;
+ (NSArray *)getGroupContacts:(ABRecordID)groupId withFilter:(NSString *)filter;
+ (Boolean) addGroupContact:(ABRecordID)groupId withPerson:(ABRecordRef)person;
+ (void) deleteGroupContact:(ABRecordID)groupId withContactId:(ABRecordID)contactId;

@end
