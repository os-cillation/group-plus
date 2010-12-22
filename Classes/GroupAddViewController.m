//
//  GroupAddViewController.m
//  Groups
//
//  Created by Benjamin Mies on 03.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GroupAddViewController.h"
#import "Database.h"
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
		ABAddressBookRef ab = ABAddressBookCreate();
		
		ABRecordRef groupRef;
		if (group == nil) {
			groupRef = ABGroupCreate();
			ABRecordSetValue(groupRef, kABGroupNameProperty, nameString, nil);
			ABAddressBookAddRecord(ab, groupRef, nil);
		}
		else {
			groupRef = ABAddressBookGetGroupWithRecordID(ab, [group getId]);
			if (groupRef == nil || groupRef == NULL) {
				groupRef = ABGroupCreate();
				ABRecordSetValue(groupRef, kABGroupNameProperty, nameString, nil);
				ABAddressBookAddRecord(ab, groupRef, nil);
			}
			else {
				ABRecordSetValue(groupRef, kABGroupNameProperty, nameString, nil);
			}
			
			//[Database deleteGroup:[group getId]];
		}
		ABAddressBookSave(ab, nil);
		
		ABRecordID groupId = ABRecordGetRecordID(groupRef);
// 		int groupId = 0;
		if (group != nil) {
			groupId = [group getId];
		}
		[Database addGroup:groupId withName:nameString];
		
		[self.delegate addGroupViewControllerDidFinish:self];
	}
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	
	if (self = [super initWithNibName:nibName bundle:nibBundle]) {
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
	if (group != nil) {
		self.textField.text = group.name;
	}
}

- (void)updateText {
	self.label.text = NSLocalizedString(@"EnterGroupName", @"");
}


- (void)dealloc {
	[super dealloc];
	[textField release];
	[label release];
	[group release];
}


@end

