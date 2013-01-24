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

- (void)updateText {
	labelUseAddressbook.text = NSLocalizedString(@"useAddressbookLabel", @"");
	labelUseAddressbook2.text = NSLocalizedString(@"useAddressbookMessage", @"");
	message1.text = NSLocalizedString(@"preferencesMessage1", @"");
	message2.text = NSLocalizedString(@"preferencesMessage2", @"");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	[scrollView scrollRectToVisible:textField.frame animated:YES];
    return YES;
}

@end
