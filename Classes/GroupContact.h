//
//  GroupContact.h
//  Groups
//
//  Created by Benjamin Mies on 24.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>


@interface GroupContact : NSObject {
}

+ (GroupContact *)groupContactFromPerson:(ABRecordRef)person;

@property (nonatomic, assign) int64_t uniqueId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *number;
@property (nonatomic, retain) UIImage *image;

@end