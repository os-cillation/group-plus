//
//  Group.h
//  GroupManager2
//
//  Created by Benjamin Mies on 24.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>


@interface Group : NSObject {
	ABRecordID groupId;
	NSString *name;
	int count;
}

- (void)setId:(ABRecordID)pId;
- (ABRecordID)getId;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) int count;


@end
