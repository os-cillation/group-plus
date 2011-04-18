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


@implementation CleanUpDuplicatesNumberController

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"DuplicatesByNumberTitle", @"");
    // TODO:OSBMI
    //[data release];
	//data = [[CustomAddressBook getDuplicateNumberData] retain];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
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
    return [data count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[data objectAtIndex:section] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	GroupContact *groupContact = [[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
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
	if ([data count] == 0) {
		return @"";
	}
	GroupContact *groupContact = [[data objectAtIndex:section] objectAtIndex:0];
	
    return groupContact.number;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GroupContact *groupContact = [[data objectAtIndex:indexPath.section] objectAtIndex: indexPath.row];
	
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
        // TODO:OSBMI
		//GroupContact *contact = [[data objectAtIndex:indexPath.section] objectAtIndex: indexPath.row];
		//ABAddressBookRef ab = ABAddressBookCreate();
		//ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, [contact getId]);
		//ABAddressBookRemoveRecord(ab, person, nil);
		//ABAddressBookSave(ab, nil);
		//[CustomAddressBook deleteCleanUpContact:[contact getId]];
        //[data release];
		//data = [[CustomAddressBook getDuplicateNumberData] retain];
		//[self.tableView reloadData];
    }   
}

- (void)dealloc {
    [data release];
    [super dealloc];
}


@end

