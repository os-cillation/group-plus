//
//  RootViewController.h
//  Groups
//
//  Created by Benjamin Mies on 03.03.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Group.h"
#import "GroupAddViewController.h"
#import "DetailGroupViewTableController.h"
#import "AboutViewController.h"
#import "ShareContactsViewController.h"
#import "SendContactViewController.h"

@class DataController;

@interface RootViewController : UITableViewController <GroupAddViewControllerDelegate, DetailGroupViewTableControllerDelegate, UISearchBarDelegate> {
	DataController *dataController;
	NSArray *groups;
	IBOutlet UISearchBar *searchBar;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;


- (void)refreshData;
- (void)showPreferences;
- (void)showInfo;
- (void)cleanUp;


@property (nonatomic, retain) DataController *dataController;

@end
