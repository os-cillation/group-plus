//
//  PreferencesViewController.m
//  GroupPlus
//
//  Created by Benjamin Mies on 15.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PreferencesViewController.h"
#import <AddressBook/AddressBook.h>
#import "CustomAddressBook.h"


@implementation PreferencesViewController

@synthesize labelText, message1, message2;


- (void)handleCancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)handleSave {
	[[NSUserDefaults standardUserDefaults] setBool:switchUseAddressbook.on forKey:@"UseAddressbook"];
	[[NSUserDefaults standardUserDefaults] setObject:labelText.text forKey:@"phoneLabel"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	scrollView.contentSize = CGSizeMake(320, 550);
	self.title = NSLocalizedString(@"Preferences", @"");
	
	switchUseAddressbook.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"];
	
	labelText.text = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"phoneLabel"];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
								   target:self
								   action:@selector(handleCancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] 
									 initWithBarButtonSystemItem:UIBarButtonSystemItemSave
									 target:self
									 action:@selector(handleSave)];
    self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self updateText];
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

- (void)updateText {
	labelUseAddressbook.text = NSLocalizedString(@"useAddressbookLabel", @"");
	labelUseAddressbook2.text = NSLocalizedString(@"useAddressbookMessage", @"");
	message1.text = NSLocalizedString(@"preferencesMessage1", @"");
	message2.text = NSLocalizedString(@"preferencesMessage2", @"");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	[scrollView scrollRectToVisible:textField.frame animated:YES];
    return YES;
}

@end
