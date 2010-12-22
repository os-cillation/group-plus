//
//  GroupContact.m
//  Groups
//
//  Created by Benjamin Mies on 24.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GroupContact.h"


@implementation GroupContact

@synthesize name, number, image;

- (void)setId:(ABRecordID)pId{
	contactId = pId;
}
- (ABRecordID)getId{
	return contactId ;
}


- (void)dealloc {
	[name release];
	[super dealloc];
}

@end
