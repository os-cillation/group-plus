//
//  RootViewController.m
//  Groups
//
//  Created by Benjamin Mies on 03.03.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"
#import "DataController.h"
#import "PreferencesViewController.h"
#import "CleanUpTableViewController.h"
#import "Database.h"
#import "GroupsAppDelegate.h"
#import <MessageUI/MFMessageComposeViewController.h>

@implementation RootViewController

@synthesize dataController, searchBar;

- (void) initDataController {
	DataController *controller = [[DataController alloc] init];
    self.dataController = controller;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)pSearchBar {
	pSearchBar.text = @"";
	groups = [dataController getGroups:pSearchBar.text];
	[searchBar resignFirstResponder];
	[self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)pSearchBar textDidChange:(NSString *)searchText {
	groups = [dataController getGroups:searchText];
	[self.tableView reloadData];
}

- (void) refreshData {
	[self.tableView reloadData];
}

- (void)addGroupViewControllerDidFinish:(GroupAddViewController *)controller {
	[self refreshData];
	[self dismissModalViewControllerAnimated:YES];
}


- (void)addGroup {
	GroupAddViewController *controller = [[GroupAddViewController alloc] initWithNibName:@"GroupAddViewController" bundle:nil];
	
	controller.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	controller.title = NSLocalizedString (@"AddGroup", @"");
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
	[navController release];
}

- (void)cleanUp {
	CleanUpTableViewController *detailViewController = [[CleanUpTableViewController alloc] initWithStyle:UITableViewStyleGrouped];

    // Push the detail view controller.
    [[self navigationController] pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (void)viewGroupDetails:(Group *)group {
	DetailGroupViewTableController *detailViewController = [[DetailGroupViewTableController alloc] initWithNibName:@"DetailGroupViewTableController" bundle:nil];
    
    detailViewController.delegate = self;
	detailViewController.group = group;
    
    // Push the detail view controller.
    [[self navigationController] pushViewController:detailViewController animated:YES];
    //[detailViewController release];
	GroupsAppDelegate *delegate = [GroupsAppDelegate sharedAppDelegate];
	delegate.groupViewController= detailViewController;
}

- (void)showPreferences {
	PreferencesViewController *controller = [[PreferencesViewController alloc] initWithNibName:@"PreferencesViewController" bundle:nil];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
	[navController release];
}

- (void)showInfo {
	AboutViewController *controller = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
	[navController release];
}

- (void)shareContacts {
	ShareContactsViewController *controller = [[ShareContactsViewController alloc] initWithNibName:@"ShareContactsViewController" bundle:nil];
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (void)sendContactSMS {
	if ([MFMessageComposeViewController canSendText]) {
		SendContactViewController *controller = [[SendContactViewController alloc] initWithNibName:@"SendContactViewController" bundle:nil];
		controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:controller animated:YES];

		[controller release];
	}
	else {
		UIAlertView *alertView = [[UIAlertView alloc]
			initWithTitle:NSLocalizedString(@"Error",@"")
			message:NSLocalizedString(@"ErrorNoSMS",@"")
			delegate:self 
			cancelButtonTitle:NSLocalizedString(@"OK",@"")
			otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[self.tableView reloadData];
	}
}

- (void) detailViewControllerDidFinish:(DetailGroupViewTableController *)controller {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)detailViewControllerReload:(DetailGroupViewTableController *)controller  {
	[self refreshData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self initDataController];
	
	self.title = NSLocalizedString (@"Groupmanager", @"");
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
								   target:self
								   action:@selector(startEdit)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
}

- (void)startEdit {
	[self.tableView setEditing:YES animated:YES];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								   target:self
								   action:@selector(stopEdit)];
    self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								   target:self
								   action:@selector(addGroup)];
    self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
}

- (void)stopEdit {
	[self.tableView setEditing:NO animated:YES];
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
								   target:self
								   action:@selector(startEdit)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
	self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	GroupsAppDelegate *delegate = [GroupsAppDelegate sharedAppDelegate];
	delegate.groupViewController = nil;
    [super viewWillAppear:animated];
	groups = [dataController getGroups:searchBar.text];
	[self refreshData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [dataController countOfList:searchBar.text];
		case 1:
			return 6;
		default:
			break;
	}
	return 0;
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	NSString *cellText;
	
	switch (indexPath.section) {
		case 0:
		{

			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;

			// Get the object to display and set the value in the cell.
			Group *groupAtIndex = [groups objectAtIndex:indexPath.row];
			cellText = groupAtIndex.name;
			
			cell.textLabel.text = cellText;
			int count = groupAtIndex.count;
			if (count != 1) {
				cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%i %@", count, NSLocalizedString(@"Members", @"")];
			}
			else {
				cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%i %@", count, NSLocalizedString(@"Member", @"")];
			}
			 
			return cell;
		}
		case 1:

			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.backgroundColor = [UIColor whiteColor];

			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"AddGroup", @"");
					cell.detailTextLabel.text = @"";
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"ShareContacts", @"");
					cell.detailTextLabel.text = @"";
					break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"SendContactSMS", @"");
					if (![MFMessageComposeViewController canSendText]) {
						cell.backgroundColor = [UIColor lightGrayColor];
					}
					cell.detailTextLabel.text = @"";
					break;
				case 3:
					cell.textLabel.text = NSLocalizedString(@"CleanUp", @"");
					cell.detailTextLabel.text = @"";
					break;
				case 4:
					cell.textLabel.text = NSLocalizedString(@"Preferences", @"");
					cell.detailTextLabel.text = @"";
					break;
				case 5:
					cell.textLabel.text = NSLocalizedString(@"About", @"");
					cell.detailTextLabel.text = @"";
					break;
				default:
					break;
			}
			
			return cell;
		default:
			break;
	}
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = [NSString alloc];
	switch (section) {
		case 0:
			title = NSLocalizedString (@"Groups", @"");
			break;
		case 1:
			title = NSLocalizedString (@"Other", @"");
			break;
		default:
			break;
	}	
	
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if ( section == 1) {
		return @"";
	}
	NSString *title = [NSString alloc];
	int count = [groups count];
	if (count != 1) {
		title = [[NSString alloc] initWithFormat:NSLocalizedString(@"GroupsCount", @""), count];
	}
	else {
		title = [[NSString alloc] initWithFormat:NSLocalizedString(@"GroupCount", @""), count];
	}
    return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
		{
			Group *groupAtIndex = [groups objectAtIndex:indexPath.row];
/*
			ABAddressBookRef ab = ABAddressBookCreate();
			ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(ab, [groupAtIndex getId]);
			if (groupRef == nil || groupRef == NULL) {
				[Database deleteGroup:[groupAtIndex getId]];
				groups = [dataController getGroups:searchBar.text];
				[self refreshData];
				[self.tableView reloadData];
				UIAlertView *alert = [[UIAlertView alloc]
									  initWithTitle:NSLocalizedString(@"Info", @"")
									  message:NSLocalizedString(@"GroupDeleted", @"") 
									  delegate:nil
									  cancelButtonTitle:NSLocalizedString(@"OK", @"")
									  otherButtonTitles:nil];
				[alert show];
				[alert release];
				return;
			}
*/
			[self viewGroupDetails:groupAtIndex];
			break;
		}
		case 1:
			switch (indexPath.row) {
				case 0:
					[self addGroup];
					break;
				case 1:
					[self shareContacts];
					break;
				case 2:
					[self sendContactSMS];
					break;
				case 3:
					[self cleanUp];
					break;
				case 4:
					[self showPreferences];
					break;
				case 5:
					[self showInfo];
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}	
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			return YES;
		case 1:
			return NO;
		default:
			break;
	}	
	return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		Group *groupAtIndex = [dataController objectInListAtIndex:indexPath.row withFilter:searchBar.text];
		[dataController deleteGroup:groupAtIndex];
		groups = [dataController getGroups:searchBar.text];
		[self refreshData];
		[self.tableView reloadData];
    }   
}

- (void)dealloc {
	//[dataController release];
    [super dealloc];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end

