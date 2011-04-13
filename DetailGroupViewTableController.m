//
//  DetailGroupViewTableController.m
//  Groups
//
//  Created by Benjamin Mies on 03.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DetailGroupViewTableController.h"
#import "Group.h"
#import "GroupContact.h"
#import "DataController.h"
#import "PersonViewController.h"


@implementation DetailGroupViewTableController

@synthesize delegate, searchBar, group;

- (void)searchBarCancelButtonClicked:(UISearchBar *)pSearchBar {
	pSearchBar.text = @"";
    [groupContacts release];
	groupContacts = [[[[DataController alloc] init] getGroupContacts:group withFilter:pSearchBar.text] retain];
	[self.tableView reloadData];
	[pSearchBar resignFirstResponder];
	
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[groupContacts release];
	groupContacts = [[[[DataController alloc] init] getGroupContacts:group withFilter:searchText] retain];
	[self.tableView reloadData];
	
}

- (void)addGroupViewControllerDidFinish:(GroupAddViewController *)controller {
	//[self refreshData];
	if ([controller.textField.text length] > 0) {
		self.title = controller.textField.text;
		self.group.name = controller.textField.text;
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (void)showDetails:(int)personId {
	PersonViewController *personViewController = [[PersonViewController alloc] init];
	
	ABAddressBookRef ab = ABAddressBookCreate();
	ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, personId);
	
	personViewController.personViewDelegate = self;
	personViewController.displayedPerson = person;
	personViewController.allowsEditing = FALSE;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:personViewController];

	[self presentModalViewController:navController animated:YES];
	
	[personViewController release];
	[navController release];
	CFRelease(ab);
}

- (void)cancelContact:(id)sender {
	[self dismissModalViewControllerAnimated:YES];	
}

- (void)handleRename {
	GroupAddViewController *controller = [[GroupAddViewController alloc] initWithNibName:@"GroupAddViewController" bundle:nil];

	controller.delegate = self;
	controller.group = self.group;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	controller.title = NSLocalizedString(@"RenameGroupTitle", @"");
	
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
	[navController release];
}

- (void)sendMail {
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	ABAddressBookRef ab = ABAddressBookCreate();
	
	// Set up recipients
	NSMutableArray *toRecipients = [[NSMutableArray alloc] init]; 
	NSEnumerator *e = [groupContacts objectEnumerator];
	GroupContact *contact;

	while ((contact = [e nextObject])) {
		
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, [contact getId]);
		ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
		CFIndex	count = ABMultiValueGetCount(multi);
		if (multi == NULL || multi == nil || count == 0) {
			CFRelease(multi);
			continue;
		}
		NSString *address = (NSString*)ABMultiValueCopyValueAtIndex(multi, 0);
		
		if ([address length] > 0) {
			[toRecipients addObject:address];
		}		
		[address release];
		CFRelease(multi);
	} 
	
	[picker setToRecipients:toRecipients];
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
	[toRecipients release];
	[contact release];
	
	CFRelease(ab);
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)handleSendSMS {
	if (![MessageViewController canSendText]) {
		UIAlertView *alertView = [[UIAlertView alloc]
								  initWithTitle:NSLocalizedString(@"Error",@"")
								  message:NSLocalizedString(@"ErrorNoSMS",@"")
								  delegate:self 
								  cancelButtonTitle:NSLocalizedString(@"OK",@"")
								  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[self.tableView reloadData];		
		return;
	}
	NSArray *contacts = groupContacts;

	
	MessageViewController *controller = [[MessageViewController alloc] init];
	controller.messageComposeDelegate = self;
	controller.group = group;
	
	NSMutableArray *toRecipients = [[NSMutableArray alloc] init]; 
	
	GroupContact *contact = [GroupContact alloc];
	NSString *userLabel = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"phoneLabel"];

	for (int i = 0; i < [contacts count]; i++) {
		BOOL found = FALSE;
		contact = [contacts objectAtIndex:i];
		//[toRecipients addObject:contact.number];
		ABAddressBookRef ab = ABAddressBookCreate();
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, [contact getId]);
		ABMultiValueRef phoneProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
		CFIndex	count = ABMultiValueGetCount(phoneProperty);
		
		if([userLabel length] > 0) {
			for (CFIndex i=0; i < count; i++) {
				NSString *label = (NSString*) ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phoneProperty, i));
				
				if ([label isEqualToString:userLabel]) {
					
					NSString *phoneNumber = (NSString *) ABMultiValueCopyValueAtIndex(phoneProperty, i);
					[toRecipients addObject:phoneNumber];
					contact.number = phoneNumber;
					found = TRUE;
					break;
				}
			}
		}
		if (!found) {
			[toRecipients addObject:contact.number];
		}
	}
	
	controller.members = contacts;
	[controller setRecipients:toRecipients];
	[self presentModalViewController:controller animated:YES];
	
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)handleSendMail {
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self sendMail];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}
	
}

-(void)launchMailAppOnDevice {
	NSString *recipients = @"mailto:";
	NSArray *contacts = groupContacts;
	
	ABAddressBookRef book = ABAddressBookCreate();
    if (book) {
        for (int i = 0; i < [contacts count]; i++) {
            GroupContact *contact = [contacts objectAtIndex:i];
            ABRecordRef person = ABAddressBookGetPersonWithRecordID(book, [contact getId]);
            if (person) {
                ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
                if (emails) {
                    if (ABMultiValueGetCount(emails) > 0) {
                        NSString *address = [(NSString *)ABMultiValueCopyValueAtIndex(emails, 0) autorelease];
                        if (address && [address length]) {
                            if (i == 0){
                                recipients = [recipients stringByAppendingString:address];
                            }
                            else {
                                recipients = [recipients stringByAppendingString:@","];
                                recipients = [recipients stringByAppendingString:address];
                            }
                        }
                    }
                    CFRelease(emails);
                }
            }
        }  
        
        CFRelease(book);
    }
	
	NSString *body = @"";
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)viewWillAppear:(BOOL)animated {
    [groupContacts release];
	groupContacts = [[[[DataController alloc] init] getGroupContacts:group withFilter:searchBar.text] retain];;
	
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)startEdit {
	[self.tableView setEditing:YES animated:YES];

    self.navigationItem.leftBarButtonItem = doneButton;
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)stopEdit {
	[self.tableView setEditing:NO animated:YES];
	
    self.navigationItem.rightBarButtonItem = editButton;
	self.navigationItem.leftBarButtonItem = backButton;
}

- (void)addMember {
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

//people picker delegate protocol

// Called after the user has pressed cancel
// The delegate is responsible for dismissing the peoplePicker
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[self dismissModalViewControllerAnimated:YES];
}

// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    if (![[[DataController alloc] init] addGroupContact:group withPerson:person]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Error", @"")
                              message:NSLocalizedString(@"MemberNotAddedMessage", @"") 
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
	
	[self.delegate detailViewControllerReload:self];
    [groupContacts release];
	groupContacts = [[[[DataController alloc] init] getGroupContacts:group withFilter:searchBar.text] retain];
	[self.tableView reloadData];
	
	[self dismissModalViewControllerAnimated:YES];
	return NO;
}

// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	return NO;
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
	return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
	[super viewDidLoad];
	backButton = self.navigationItem.leftBarButtonItem;
	editButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
								   target:self
								   action:@selector(startEdit)];
	doneButton = [[UIBarButtonItem alloc] 
				 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
				 target:self
				 action:@selector(stopEdit)];
	addButton = [[UIBarButtonItem alloc] 
				  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
				  target:self
				  action:@selector(addMember)];
	self.title = group.name;
	self.navigationItem.rightBarButtonItem = editButton;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([searchBar.text length] > 0) {
		return 1;
	}
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([searchBar.text length] > 0) {
		return [groupContacts count];
	}
	switch (section) {
		case 0:
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				// The device is an iPad running iPhone 3.2 or later.
				return 3;
			}
			else {
				// The device is an iPhone or iPod touch.
				return 4;
			}
			
		case 1:
			return [groupContacts count];
	}

	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    }
	cell.backgroundColor = [UIColor whiteColor];
	cell.textLabel.textColor = [UIColor blackColor];
	NSString *cellText = [NSString alloc];

	if ([searchBar.text length] == 0) {
		switch (indexPath.section) {
			case 0:
			{
				switch (indexPath.row) {
					case 0:
						cellText = NSLocalizedString(@"RenameGroup", @"");
						break;
					case 1:
						cellText = NSLocalizedString(@"AddMember", @"");
						break;
					case 2:
						cellText = NSLocalizedString(@"SendMail", @"");
						break;
					case 3:
						cellText = NSLocalizedString(@"SendSMS", @"");
						if (![MessageViewController canSendText]) {
							cell.backgroundColor = [UIColor lightGrayColor];
						}
						break;
					default:
						break;
				}
				break;
			}
			case 1:
			{
				GroupContact *groupContact = [groupContacts objectAtIndex:indexPath.row];
				

				if ([groupContact.name length] > 0) {
					cellText = groupContact.name;
				}
				else {
					cell.textLabel.textColor = [UIColor grayColor];
					cellText = NSLocalizedString(@"noName", @"");
				}
				break;
			}
			default:
				break;
		}
	}
	else {
		GroupContact *groupContact = [groupContacts objectAtIndex:indexPath.row];
		
		if ([groupContact.name length] > 0) {
			cellText = groupContact.name;
		}
		else {
			cellText = NSLocalizedString(@"noName", @"");
		}

	}

    
	cell.textLabel.text = cellText;
    return cell;
}


#pragma mark -
#pragma mark Section header titles

/*
 HIG note: In this case, since the content of each section is obvious, there's probably no need to provide a title, but the code is useful for illustration.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([searchBar.text length] > 0) {
		return NSLocalizedString(@"MembersTitle", @"");
	}
    NSString *title = [NSString alloc];
	switch (section) {
		case 0:
		{
			title = @"";
			break;
		}
		case 1:
		{
			title = NSLocalizedString(@"MembersTitle", @"");
			break;
		}
	}
	
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if ( (section == 0) && ([searchBar.text length] == 0) ) {
		return @"";
	}
	NSString *title = [NSString alloc];
	int count = [groupContacts count];
	if (count != 1) {
		title = [[NSString alloc] initWithFormat:@"%i %@", count, NSLocalizedString(@"Members", @"")];
	}
	else {
		title = [[NSString alloc] initWithFormat:@"%i %@", count, NSLocalizedString(@"Member", @"")];
	}
    return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([searchBar.text length] > 0) {
		GroupContact *groupContact = [groupContacts objectAtIndex:indexPath.row];		
		[self showDetails:[groupContact getId]];	
		return;
	}
	
	switch (indexPath.section) {
        case 0:
		{
			switch (indexPath.row) {
				case 0:
					[self handleRename];
					break;
				case 1:
					[self addMember];
					break;
				case 2:
					[self handleSendMail];
					break;
				case 3:
					[self handleSendSMS];
					break;
				default:
					break;
			}
            
            break;
		}
        case 1:
		{
			GroupContact *groupContact = [groupContacts objectAtIndex:indexPath.row];
			[self showDetails:[groupContact getId]];
            break;
		}
        default:
            break;
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([searchBar.text length] > 0) {
		return YES;
	}
	switch (indexPath.section) {
        case 0:
		{
            return NO;
		}
        case 1:
		{
			return YES;
		}
        default:
            break;
    }    
	return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
	
		GroupContact *groupContact = [groupContacts objectAtIndex:indexPath.row];
        
        [[[DataController alloc] init] deleteGroupContact:group withPersonId:[groupContact getId]];
		[groupContacts release];
		groupContacts = [[[[DataController alloc] init] getGroupContacts:group withFilter:searchBar.text] retain];
		[self.delegate detailViewControllerReload:self];
		[self.tableView reloadData];
    }   
}

- (void)dealloc {
    [groupContacts release];
    [group release];
    [searchBar release];
	[backButton release];
	[editButton release];
	[doneButton release];
	[addButton release];
    [super dealloc];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end

