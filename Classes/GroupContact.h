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
	ABRecordID contactId;
	NSString *name;
	NSString *number;
	UIImage *image;
}

- (void)setId:(ABRecordID)pId;
- (ABRecordID)getId;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *number;
@property (nonatomic, retain) UIImage *image;

@end