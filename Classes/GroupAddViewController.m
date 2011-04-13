//
//  GroupAddViewController.m
//  Groups
//
//  Created by Benjamin Mies on 03.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GroupAddViewController.h"
#import "DataController.h"
#import <AddressBook/AddressBook.h>


@implementation GroupAddViewController

@synthesize delegate, textField, group, label;

#pragma mark -
#pragma mark === Action method ===
#pragma mark -

- (IBAction)done {
	textField.text = group.name;
	[self.delegate addGroupViewControllerDidFinish:self];	
}

- (IBAction)addGroup {
	NSString *nameString = textField.text;
	if ([nameString length] == 0){
		[self.delegate addGroupViewControllerDidFinish:self];
		return;
	}
	else {
        if (group == nil) {
            [[[DataController alloc] init] addGroup:nameString];
        } else {
            [[[DataController alloc] init] renameGroup: group withName: nameString];
        }
        [self.delegate addGroupViewControllerDidFinish:self];
    }
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (self) {
		self.wantsFullScreenLayout = YES;
	}
	return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self addGroup];
    return NO;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self updateText];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
								   target:self
								   action:@selector(done)];
    self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] 
									 initWithBarButtonSystemItem:UIBarButtonSystemItemSave
									 target:self
									 action:@selector(addGroup)];
    self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	[textField becomeFirstResponder];
	if (group) {
		self.textField.text = group.name;
	}
}

- (void)updateText {
	self.label.text = NSLocalizedString(@"EnterGroupName", @"");
}


- (void)dealloc {
	[textField release];
	[label release];
	[group release];
	[super dealloc];
}


@end

