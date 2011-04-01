//
//  DetailGroupViewTableController.h
//  Groups
//
//  Created by Benjamin Mies on 03.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupAddViewController.h"
#import "MessageViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@protocol DetailGroupViewTableControllerDelegate;

@class Group;

@interface DetailGroupViewTableController : UITableViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate, GroupAddViewControllerDelegate, UISearchBarDelegate> {
	id <DetailGroupViewTableControllerDelegate> delegate;
	NSArray *groupContacts;
	Group *group;
	IBOutlet UISearchBar *searchBar;
	UIBarButtonItem *backButton;
	UIBarButtonItem *editButton;
	UIBarButtonItem *doneButton;
	UIBarButtonItem *addButton;
}

@property (nonatomic, assign) id <DetailGroupViewTableControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic, retain) Group *group;

- (void)showDetails:(int)personId;
- (void)handleSendMail;
- (void)sendMail;
- (void)launchMailAppOnDevice;

@end

@protocol DetailGroupViewTableControllerDelegate
- (void)detailViewControllerDidFinish:(DetailGroupViewTableController *)controller;
- (void)detailViewControllerReload:(DetailGroupViewTableController *)controller;
@end
