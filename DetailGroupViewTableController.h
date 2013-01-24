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
