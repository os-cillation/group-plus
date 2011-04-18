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

@class DataController;
@class Group;

@interface DetailGroupViewTableController : UITableViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate, GroupAddViewControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
	id <DetailGroupViewTableControllerDelegate> _delegate;
    DataController *_dataController;
	NSArray *_groupContacts;
	NSArray *_filteredGroupContacts;
	Group *_group;
	IBOutlet UISearchBar *_searchBar;
	UIBarButtonItem *_backButton;
	UIBarButtonItem *_editButton;
	UIBarButtonItem *_doneButton;
	UIBarButtonItem *_addButton;
}

@property (nonatomic, retain) DataController *dataController;
@property (nonatomic, assign) id <DetailGroupViewTableControllerDelegate> delegate;
@property (nonatomic, retain) Group *group;
@property (nonatomic, copy) NSArray *groupContacts;
@property (nonatomic, copy) NSArray *filteredGroupContacts;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) UIBarButtonItem *backButton;
@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;
@property (nonatomic, retain) UIBarButtonItem *addButton;

- (void)showDetails:(int)personId;
- (void)handleSendMail;
- (void)sendMail;
- (void)launchMailAppOnDevice;

@end

@protocol DetailGroupViewTableControllerDelegate
- (void)detailViewControllerDidFinish:(DetailGroupViewTableController *)controller;
- (void)detailViewControllerReload:(DetailGroupViewTableController *)controller;
@end
