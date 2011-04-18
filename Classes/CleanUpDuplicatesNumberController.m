//
//  CleanUpDuplicatesNumberController.m
//  Groups
//
//  Created by Benjamin Mies on 29.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CleanUpDuplicatesNumberController.h"
#import "CustomAddressBook.h"
#import "GroupContact.h"
#import "PersonViewController.h"


@interface CleanUpDuplicatesNumberController ()

@property (nonatomic, retain) NSArray *data;

- (void)reloadData;

@end


@implementation CleanUpDuplicatesNumberController

@synthesize data = _data;

- (void)reloadData
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    if (addressBook) {
        NSArray *persons = [(NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook) autorelease];
        NSMutableDictionary *groupContactsByNumber = [NSMutableDictionary dictionary];
        for (CFIndex i = 0; i < [persons count]; ++i) {
            GroupContact *groupContact = [GroupContact groupContactFromPerson:[persons objectAtIndex:i]];
            if (groupContact && groupContact.number) {
                NSMutableArray *groupContacts = [groupContactsByNumber objectForKey:groupContact.number];
                if (!groupContacts) {
                    groupContacts = [NSMutableArray array];
                }
                [groupContacts addObject:groupContact];
                [groupContactsByNumber setObject:groupContacts forKey:groupContact.number];
            }
        }
        NSMutableArray *data = [NSMutableArray array];
        for (NSString *groupContactNumber in groupContactsByNumber) {
            NSArray *groupContacts = [groupContactsByNumber objectForKey:groupContactNumber];
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
	self.title = NSLocalizedString(@"DuplicatesByNumberTitle", @"");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:AddressBookDidChangeNotification object:nil];
    [self reloadData];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)viewDidUnload {
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
    
	GroupContact *groupContact = [[self.data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	cell.textLabel.textColor = [UIColor blackColor];
	
	if ([groupContact.name length] > 0) {
        cell.textLabel.text = groupContact.name;
	}
	else {
		cell.textLabel.textColor = [UIColor grayColor];
		cell.textLabel.text = NSLocalizedString(@"noName", @"");
	}
	
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([self.data count] == 0) {
		return @"";
	}
	GroupContact *groupContact = [[self.data objectAtIndex:section] objectAtIndex:0];
	
    return groupContact.number;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GroupContact *groupContact = [[self.data objectAtIndex:indexPath.section] objectAtIndex: indexPath.row];
	
    PersonViewController *personViewController = [[PersonViewController alloc] init];
	
	ABAddressBookRef ab = ABAddressBookCreate();
	ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, groupContact.uniqueId);
	
	personViewController.personViewDelegate = self;
	personViewController.displayedPerson = person;
	personViewController.allowsEditing = NO;
	
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


@end

