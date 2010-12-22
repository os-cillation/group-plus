//
//  PersonViewController.m
//  Group
//
//  Created by Benjamin Mies on 26.05.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PersonViewController.h"
#import "GroupsAppDelegate.h"

@implementation PersonViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	GroupsAppDelegate *delegate = [GroupsAppDelegate sharedAppDelegate];
	delegate.viewController = self;
    [super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"contactDetails", @"");
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *cancelButton =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																				   target:self action:@selector(cancelContact)];
	self.navigationItem.leftBarButtonItem = cancelButton;
		
	[cancelButton release];
}

- (void)cancelContact {
	GroupsAppDelegate *delegate = [GroupsAppDelegate sharedAppDelegate];
	delegate.viewController = nil;
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
