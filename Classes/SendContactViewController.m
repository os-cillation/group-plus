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
    // determine the person's full name
    NSString *personName = nil;
    NSString *personFirstName = [(NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty) autorelease];
    NSString *personLastName = [(NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty) autorelease];
    if (personFirstName && personLastName) {
        if (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst) {
            personName = [NSString stringWithFormat:@"%@ %@", personFirstName, personLastName];
        }
        else {
            personName = [NSString stringWithFormat:@"%@ %@", personLastName, personFirstName];
        }
    }
    else if (personFirstName) {
        personName = personFirstName;
    }
    else if (personLastName) {
        personName = personLastName;
    }
    else {
        personName = [(NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty) autorelease];
    }
	NSString *message = [NSString stringWithFormat:@"%@", personName];
	
	ABMultiValueRef phones = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (phones) {
        for (CFIndex i=0; i < ABMultiValueGetCount(phones); ++i) {
            NSString *label = [(NSString *)ABMultiValueCopyLabelAtIndex(phones, i) autorelease];
            NSString *value = [(NSString *)ABMultiValueCopyValueAtIndex(phones, i) autorelease];
            message = [message stringByAppendingFormat:@"\n%@: %@", [(NSString *)ABAddressBookCopyLocalizedLabel((CFStringRef)label) autorelease], value];
        }
        CFRelease(phones);
    }
	
	ABMultiValueRef emails = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonEmailProperty);
    if (emails) {
        for (CFIndex i=0; i < ABMultiValueGetCount(emails); ++i) {
            NSString *label = [(NSString *)ABMultiValueCopyLabelAtIndex(emails, i) autorelease];
            NSString *value = [(NSString *)ABMultiValueCopyValueAtIndex(emails, i) autorelease];
            message = [message stringByAppendingFormat:@"\n%@: %@", [(NSString *)ABAddressBookCopyLocalizedLabel((CFStringRef)label) autorelease], value];
        }
        CFRelease(emails);
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
