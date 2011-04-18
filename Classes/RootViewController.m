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
#import "GroupsAppDelegate.h"
#import "AddressBookProtocol.h"
#import <MessageUI/MFMessageComposeViewController.h>

@implementation RootViewController

@synthesize dataController = _dataController;
@synthesize groups = _groups;
@synthesize searchBar = _searchBar;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.dataController = [DataController dataController];
        if (!self.dataController) {
            [self release];
            return nil;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:AddressBookDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setDataController:nil];
    [self setGroups:nil];
    [self setSearchBar:nil];
    [super dealloc];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	searchBar.text = @"";
    self.groups = [self.dataController getGroups:searchBar.text];
	[searchBar resignFirstResponder];
	[self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.groups = [self.dataController getGroups:searchText];
	[self.tableView reloadData];
}

- (void)refreshData
{
    self.groups = [self.dataController getGroups:self.searchBar.text];
	[self.tableView reloadData];
}

- (void)addGroupViewControllerDidFinish:(GroupAddViewController *)controller
{
	[self refreshData];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)addGroup
{
	GroupAddViewController *controller = [[GroupAddViewController alloc] initWithNibName:@"GroupAddViewController" bundle:nil];
	
	controller.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	controller.title = NSLocalizedString (@"AddGroup", @"");
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
	[navController release];
}

- (void)cleanUp
{
	CleanUpTableViewController *detailViewController = [[CleanUpTableViewController alloc] initWithStyle:UITableViewStyleGrouped];

    // Push the detail view controller.
    [[self navigationController] pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (void)viewGroupDetails:(Group *)group
{
	DetailGroupViewTableController *detailViewController = [[DetailGroupViewTableController alloc] initWithNibName:@"DetailGroupViewTableController" bundle:nil];
    
    detailViewController.delegate = self;
	detailViewController.group = group;
    
    // Push the detail view controller.
    [[self navigationController] pushViewController:detailViewController animated:YES];
	GroupsAppDelegate *delegate = [GroupsAppDelegate sharedAppDelegate];
	delegate.groupViewController = detailViewController;
    [detailViewController release];
}

- (void)showPreferences
{
	PreferencesViewController *controller = [[PreferencesViewController alloc] initWithNibName:@"PreferencesViewController" bundle:nil];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
	[navController release];
}

- (void)showInfo
{
	AboutViewController *controller = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
	[navController release];
}

- (void)shareContacts
{
	ShareContactsViewController *controller = [[ShareContactsViewController alloc] initWithNibName:@"ShareContactsViewController" bundle:nil];
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (void)sendContactSMS
{
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

- (void) detailViewControllerDidFinish:(DetailGroupViewTableController *)controller
{
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)detailViewControllerReload:(DetailGroupViewTableController *)controller
{
	[self refreshData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString (@"Groupmanager", @"");
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                  target:self
                                  action:@selector(addGroup)];
    self.navigationItem.leftBarButtonItem = addButton;
	[addButton release];
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
								   target:self
								   action:@selector(startEdit)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
    
    self.searchBar.placeholder = NSLocalizedString(@"SearchPlaceholder", @"");
}

- (void)startEdit {
	[self.tableView setEditing:YES animated:YES];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								   target:self
								   action:@selector(stopEdit)];
    self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}

- (void)stopEdit
{
	[self.tableView setEditing:NO animated:YES];
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
								   target:self
								   action:@selector(startEdit)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
}

- (void)viewWillAppear:(BOOL)animated {
	GroupsAppDelegate *delegate = [GroupsAppDelegate sharedAppDelegate];
	delegate.groupViewController = nil;
    [super viewWillAppear:animated];
	[self refreshData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
            return [self.groups count];
		case 1:
			return 5;
		default:
			break;
	}
	return 0;
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *const CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	NSString *cellText;
	
	switch (indexPath.section) {
		case 0:
		{

			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;

			// Get the object to display and set the value in the cell.
			Group *groupAtIndex = [self.groups objectAtIndex:indexPath.row];
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
            cell.detailTextLabel.text = @"";

			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"ShareContacts", @"");
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"SendContactSMS", @"");
					if (![MFMessageComposeViewController canSendText]) {
						cell.backgroundColor = [UIColor lightGrayColor];
					}
					break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"CleanUp", @"");
					break;
				case 3:
					cell.textLabel.text = NSLocalizedString(@"Preferences", @"");
					break;
				case 4:
					cell.textLabel.text = NSLocalizedString(@"About", @"");
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return NSLocalizedString (@"Groups", @"");
		case 1:
			return NSLocalizedString (@"Other", @"");
	}
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if ([self.groups count] != 1) {
                return [NSString stringWithFormat:NSLocalizedString(@"GroupsCount", @""), [self.groups count]];
            }
            else {
                return [NSString stringWithFormat:NSLocalizedString(@"GroupCount", @""), [self.groups count]];
            }
        case 1:
            return @"";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0: {
			Group *groupAtIndex = [self.groups objectAtIndex:indexPath.row];
			[self viewGroupDetails:groupAtIndex];
			break;
		}
		case 1:
			switch (indexPath.row) {
				case 0:
					[self shareContacts];
					break;
				case 1:
					[self sendContactSMS];
					break;
				case 2:
					[self cleanUp];
					break;
				case 3:
					[self showPreferences];
					break;
				case 4:
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
    return (indexPath.section == 0);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Group *group = [self.groups objectAtIndex:indexPath.row];
        NSError *error = nil;
		if ([self.dataController deleteGroup:group error:&error]) {
            [self refreshData];
        }
        else {
            [[GroupsAppDelegate sharedAppDelegate] showErrorMessage:error];
            NSLog(@"Error deleting group %d: %@", [group getId], [error description]);
            [error release];
        }
    }   
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end

