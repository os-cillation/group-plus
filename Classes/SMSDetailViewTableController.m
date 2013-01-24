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

#import "SMSDetailViewTableController.h"
#import "Group.h"
#import "GroupContact.h"


@implementation SMSDetailViewTableController


@synthesize group, members;

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
    
    // Scroll the table view to the top before it appears
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
	[super viewDidLoad];
	doneButton = [[UIBarButtonItem alloc] 
				  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
				  target:self
				  action:@selector(done)];
	self.navigationItem.leftBarButtonItem = doneButton;
	self.title = group.name;
}

- (void)done {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [members count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.detailTextLabel.numberOfLines = 0;
    }

	
	GroupContact *contact = [members objectAtIndex:indexPath.row];
			
	cell.textLabel.textColor = [UIColor blackColor];
	
	if ([contact.name length] > 0) {
		cell.textLabel.text = contact.name;
	}
	else {
		cell.textLabel.textColor = [UIColor grayColor];
		cell.textLabel.text = NSLocalizedString(@"noName", @"");
	}
	
	cell.detailTextLabel.text = contact.number;

	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0;	
}

#pragma mark -
#pragma mark Section header titles

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
	switch (section) {
		case 0:
		{
			title = NSLocalizedString(@"smsDetailHeader", @"");
			break;
		}
	}
	
    return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.section) {
        case 0:
		{
            break;
		}
        default:
            break;
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
        case 0:
		{
            return NO;
		}
        default:
            break;
    }    
	return NO;
}



- (void)dealloc {
    [members release];
    [group release];
	[doneButton release];
    [super dealloc];
}

@end
