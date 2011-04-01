//
//  SMSDetailViewTableController.h
//  Group
//
//  Created by Benjamin Mies on 08.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>


@class Group;

@interface SMSDetailViewTableController : UITableViewController {
	NSArray *members;
	Group *group;
	UIBarButtonItem *doneButton;
}

@property(nonatomic, retain) Group *group;
@property(nonatomic, retain) NSArray *members;


@end

