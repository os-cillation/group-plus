//
//  CleanUpContactsWithoutNumber.m
//  Groups
//
//  Created by Benjamin Mies on 30.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CleanUpContactsWithoutNumber.h"
#import "Database.h"
#import "GroupContact.h"


@implementation CleanUpContactsWithoutNumber

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"contactsWithoutNumberTitle", @"");
    [data release];
    data = [[Database getWithoutNumberData] retain];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [data count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	GroupContact *contact = [data objectAtIndex:indexPath.row];
	cell.textLabel.text = contact.name;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GroupContact *contact = [data objectAtIndex:indexPath.row];
	
    ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
	
	ABAddressBookRef ab = ABAddressBookCreate();
	ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, [contact getId]);
	
	personViewController.personViewDelegate = self;
	personViewController.displayedPerson = person;
	personViewController.allowsEditing = YES;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:personViewController];
	personViewController.navigationItem.title = @"Kontaktdetails";
	UIBarButtonItem *cancelButton =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																				   target:self action:@selector(cancelContact:)];
	personViewController.navigationItem.leftBarButtonItem = cancelButton;
	
	[self presentModalViewController:navController animated:YES];
	
	[cancelButton release];
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
		GroupContact *contact = [data objectAtIndex: indexPath.row];
		ABAddressBookRef ab = ABAddressBookCreate();
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, [contact getId]);
		ABAddressBookRemoveRecord(ab, person, nil);
		ABAddressBookSave(ab, nil);
		[Database deleteCleanUpContact:[contact getId]];
        [data release];
		data = [[Database getWithoutNumberData] retain];
		[self.tableView reloadData];
    }   
}

- (void)dealloc {
    [super dealloc];
}


@end

