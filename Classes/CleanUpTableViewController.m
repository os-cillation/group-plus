//
//  CleanUpTableViewController.m
//  Groups
//
//  Created by Benjamin Mies on 26.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CleanUpTableViewController.h"
#import "CustomAddressBook.h"
#import "CleanUpDuplicatesNameController.h"
#import "CleanUpDuplicatesNumberController.h"
#import "CleanUpContactsWithoutNumber.h"
#import "CleanUpContactsWithoutEmail.h"
#import "CleanUpContactsWithoutFoto.h"

@implementation CleanUpTableViewController

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)prepareData {
    // TODO:OSBMI
    //[CustomAddressBook prepareDuplicateInfo];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"CleanUpTitle", @"");
	//[NSThread detachNewThreadSelector:@selector(prepareData) toTarget:self withObject:nil];
    
}


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
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    switch (indexPath.row) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"findDuplicatesByName", @"");
			break;
		case 1:
			cell.textLabel.text = NSLocalizedString(@"findDuplicatesByNumber", @"");
			break;
		/*case 2:
			cell.textLabel.text = NSLocalizedString(@"contactsWithoutNumber", @"");
			break;
		case 3:
			cell.textLabel.text = NSLocalizedString(@"contactsWithoutEmail", @"");
			break;
		case 4:
			cell.textLabel.text = NSLocalizedString(@"contactsWithoutFoto", @"");
			break;*/
		default:
			break;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
		case 0:
		{
			CleanUpDuplicatesNameController *controller = [[CleanUpDuplicatesNameController alloc] initWithStyle:UITableViewStyleGrouped];
			
			// Push the view controller.
			[[self navigationController] pushViewController:controller animated:YES];
			[controller release];
			break;
		}
		case 1:
		{
			CleanUpDuplicatesNumberController *controller = [[CleanUpDuplicatesNumberController alloc] initWithStyle:UITableViewStyleGrouped];
			
			// Push the view controller.
			[[self navigationController] pushViewController:controller animated:YES];
			[controller release];
			break;
		}
		/*case 2:
		{
			CleanUpContactsWithoutNumber *controller = [[CleanUpContactsWithoutNumber alloc] initWithStyle:UITableViewStyleGrouped];
			
			// Push the view controller.
			[[self navigationController] pushViewController:controller animated:YES];
			[controller release];
			break;
		}
		case 3:
		{
			CleanUpContactsWithoutEmail *controller = [[CleanUpContactsWithoutEmail alloc] initWithNibName:@"CleanUpContactsWithoutEmail" bundle:nil];
			
			// Push the view controller.
			[[self navigationController] pushViewController:controller animated:YES];
			[controller release];
			break;
		}
		case 4:
		{
			CleanUpContactsWithoutFoto *controller = [[CleanUpContactsWithoutFoto alloc] initWithNibName:@"CleanUpContactsWithoutFoto" bundle:nil];
			
			// Push the view controller.
			[[self navigationController] pushViewController:controller animated:YES];
			[controller release];
			break;
		}*/
		default:
			break;
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

