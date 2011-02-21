//
//  SendContactViewController.m
//  GroupPlus
//
//  Created by Benjamin Mies on 21.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SendContactViewController.h"


@implementation SendContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.peoplePickerDelegate = self;
	messageController = [[MFMessageComposeViewController alloc] init];
	messageController.messageComposeDelegate = self;
	messageController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
}

//people picker delegate protocol

// Called after the user has pressed cancel
// The delegate is responsible for dismissing the peoplePicker
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	NSString *fullName;
	NSString* firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
	NSString* lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
	if ((firstName == NULL) && (lastName == NULL)) {
		fullName = (NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
	}	
	else if ((firstName == NULL) || (lastName == NULL)) {
		if (firstName == NULL) {
			fullName = lastName;
		}
		if (lastName == NULL) {
			fullName = firstName;
		}
	}
	else {
		fullName = [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
	}
	NSString *message = [NSString stringWithFormat:@"%@",fullName];
	
	NSString *phoneNumber = [NSString alloc];
	phoneNumber = @"";
	ABMultiValueRef phoneProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
	CFIndex	count = ABMultiValueGetCount(phoneProperty);
	for (CFIndex i=0; i < count; i++) {
		message = [message stringByAppendingFormat:@"\n%@: %@",(NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phoneProperty, i)), (NSString*)ABMultiValueCopyValueAtIndex(phoneProperty, i)];
	}
	
	ABMultiValueRef mailProperty = ABRecordCopyValue(person, kABPersonEmailProperty);
	count = ABMultiValueGetCount(mailProperty);
	for (CFIndex i=0; i < count; i++) {
		message = [message stringByAppendingFormat:@"\n%@: %@",(NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(mailProperty, i)), (NSString*)ABMultiValueCopyValueAtIndex(mailProperty, i)];
	}
	
	messageController.body = message;
	[self presentModalViewController:messageController animated:NO];
	return NO;
}

// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	return NO;
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
	return NO;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
//	[self dismissModalViewControllerAnimated:NO];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

@end
