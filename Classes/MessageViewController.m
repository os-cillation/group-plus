//
//  MessageViewController.m
//  GroupSMS
//
//  Created by Benjamin Mies on 14.04.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MessageViewController.h"
#import "SMSDetailViewTableController.h"


@implementation MessageViewController

@synthesize group, members;

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	UINavigationItem *item = self.navigationBar.topItem;
	item.title = group.name;
	UIBarButtonItem *detailsButton = [[UIBarButtonItem alloc] 
									  initWithTitle:NSLocalizedString(@"details", @"")
									  style:UIBarButtonItemStylePlain 
									  target:self
									  action:@selector(viewDetails)];
    item.rightBarButtonItem = detailsButton;
}

- (void)viewDetails {
	SMSDetailViewTableController *controller = [[SMSDetailViewTableController alloc] initWithStyle:UITableViewStyleGrouped];
	controller.group = self.group;
	controller.members = members;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	controller.navigationItem.title = NSLocalizedString(@"contactDetails", @"");
	
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
	[navController release];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
