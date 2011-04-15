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

@synthesize dataController = _dataController;
@synthesize delegate = _delegate;
@synthesize textField = _textField;
@synthesize group = _group;
@synthesize label = _label;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataController = [DataController dataController];
        if (!self.dataController) {
            [self release];
            return nil;
        }
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)dealloc 
{
    [_dataController release];
	[_textField release];
	[_label release];
	[_group release];
	[super dealloc];
}

#pragma mark -
#pragma mark === Action method ===
#pragma mark -

- (IBAction)done {
	self.textField.text = self.group.name;
	[self.delegate addGroupViewControllerDidFinish:self];	
}

- (IBAction)addGroup {
	NSString *name = self.textField.text;
	if ([name length] == 0){
		[self.delegate addGroupViewControllerDidFinish:self];
	}
	else {
        if (!self.group) {
            NSError *error = nil;
            if (![self.dataController addGroup:name error:&error]) {
                [[GroupsAppDelegate sharedAppDelegate] showErrorMessage:error];
                [error release];
            }
        } 
        else {
            NSError *error = nil;
            if (![self.dataController renameGroup:self.group withName:name error:&error]) {
                [[GroupsAppDelegate sharedAppDelegate] showErrorMessage:error];
                [error release];
            }
        }
        [self.delegate addGroupViewControllerDidFinish:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self addGroup];
    return NO;
}

- (void)viewDidLoad
{
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
	
	[self.textField becomeFirstResponder];
	if (self.group) {
		self.textField.text = self.group.name;
	}
}

- (void)updateText
{
	self.label.text = NSLocalizedString(@"EnterGroupName", @"");
}

@end

