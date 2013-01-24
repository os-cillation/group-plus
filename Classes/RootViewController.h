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

#import "Group.h"
#import "GroupAddViewController.h"
#import "DetailGroupViewTableController.h"
#import "AboutViewController.h"
#import "ShareContactsViewController.h"
#import "SendContactViewController.h"

@class DataController;

@interface RootViewController : UITableViewController <GroupAddViewControllerDelegate, DetailGroupViewTableControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
	DataController *_dataController;
	NSArray *_groups;
    NSArray *_filteredGroups;
	IBOutlet UISearchBar *_searchBar;
}

@property (nonatomic, retain) DataController *dataController;
@property (nonatomic, copy) NSArray *groups;
@property (nonatomic, retain) NSArray *filteredGroups;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

- (void)refreshData;
- (void)showPreferences;
- (void)showInfo;
- (void)cleanUp;

@end
