/*-
 * Copyright 2012 os-cillation GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
									  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
									  target:self
									  action:@selector(handleCancel)];
    item.leftBarButtonItem = cancelButton;
	
	[detailsButton release];
	[cancelButton release];
}

- (void)handleCancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
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
