//
//  Group.m
//  GroupManager2
//
//  Created by Benjamin Mies on 24.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Group.h"


@implementation Group

@synthesize name, count;

- (void)setId:(ABRecordID)pId{
	groupId = pId;
}
- (ABRecordID)getId{
	return groupId ;
}


- (void)dealloc {
	[name release];
	[super dealloc];
}

@end
