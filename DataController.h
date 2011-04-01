//
//  DataController.h
//  GroupManager2
//
//  Created by Benjamin Mies on 24.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class Group;


@interface DataController : NSObject {
}

- (NSArray *)getGroups:(NSString *)filter;
- (unsigned)countOfList:(NSString *)filter;
- (Group *)objectInListAtIndex:(unsigned)theIndex withFilter:(NSString *)filter;
- (void)deleteGroup:(Group *)group;



@end

