//
//  SendContactViewController.h
//  GroupPlus
//
//  Created by Benjamin Mies on 21.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MFMessageComposeViewController.h>


@interface SendContactViewController : ABPeoplePickerNavigationController <ABPeoplePickerNavigationControllerDelegate, MFMessageComposeViewControllerDelegate> {
	MFMessageComposeViewController *messageController;
}

@end