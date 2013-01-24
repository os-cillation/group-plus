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

#import "CleanUpDuplicatesNameController.h"
#import "AddressBookProtocol.h"
#import "GroupContact.h"
#import "DataController.h"
#import "PersonViewController.h"

@interface CleanUpDuplicatesNameController ()

@property (nonatomic, retain) NSArray *data;

- (void)reloadData;

@end


@implementation CleanUpDuplicatesNameController

@synthesize data = _data;

- (void)reloadData
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    if (addressBook) {
        NSArray *persons = [(NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook) autorelease];
        NSMutableDictionary *groupContactsByName = [NSMutableDictionary dictionary];
        for (CFIndex i = 0; i < [persons count]; ++i) {
            GroupContact *groupContact = [GroupContact groupContactFromPerson:[persons objectAtIndex:i]];
            if (groupContact) {
                NSString *groupContactName = groupContact.name;
                if (!groupContactName) {
                    groupContactName = @"";
                }
                NSMutableArray *groupContacts = [groupContactsByName objectForKey:groupContactName];
                if (!groupContacts) {
                    groupContacts = [NSMutableArray array];
                }
                [groupContacts addObject:groupContact];
                [groupContactsByName setObject:groupContacts forKey:groupContactName];
            }
        }
        NSMutableArray *data = [NSMutableArray array];
        for (NSString *groupContactName in groupContactsByName) {
            NSArray *groupContacts = [groupContactsByName objectForKey:groupContactName];
            if ([groupContacts count] > 1) {
                [data addObject:groupContacts];
            }
        }
        self.data = data;
        [self.tableView reloadData];
        CFRelease(addressBook);
    }
}

- (void)dealloc {
    self.data = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"DuplicatesByNameTitle", @"");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:AddressBookDidChangeNotification object:nil];
    [self reloadData];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.data = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.data count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return [[self.data objectAtIndex:section] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	GroupContact *contact = [[self.data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	cell.textLabel.textColor = [UIColor blackColor];
	
	if ([contact.name length] > 0) {
	cell.textLabel.text = contact.name;
	}
	else {
		cell.textLabel.textColor = [UIColor grayColor];
		cell.textLabel.text = NSLocalizedString(@"noName", @"");
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GroupContact *groupContact = [[self.data objectAtIndex:indexPath.section] objectAtIndex: indexPath.row];

    PersonViewController *personViewController = [[PersonViewController alloc] init];
	
	ABAddressBookRef ab = ABAddressBookCreate();
    if (ab) {
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, groupContact.uniqueId);
        
        personViewController.personViewDelegate = self;
        personViewController.displayedPerson = person;
        personViewController.allowsEditing = NO;
        CFRelease(ab);
	}
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:personViewController];
	
	[self presentModalViewController:navController animated:YES];
	
	[personViewController release];
	[navController release];
}

- (void)cancelContact:(id)sender {
	[self dismissModalViewControllerAnimated:YES];	
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
	return YES;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GroupContact *groupContact = [[self.data objectAtIndex:indexPath.section] objectAtIndex: indexPath.row];
        ABAddressBookRef addressBook = ABAddressBookCreate();
        if (addressBook) {
            ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, groupContact.uniqueId);
            if (person) {
                NSError *error = nil;
                if (!ABAddressBookRemoveRecord(addressBook, person, (CFErrorRef *)&error) || !ABAddressBookSave(addressBook, (CFErrorRef *)&error)) {
                    [[GroupsAppDelegate sharedAppDelegate] showErrorMessage:error];
                    [error release];
                }
            }
            CFRelease(addressBook);
        }
    }   
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end

