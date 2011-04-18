//
//  DetailGroupViewTableController.m
//  Groups
//
//  Created by Benjamin Mies on 03.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddressBookProtocol.h"
#import "DetailGroupViewTableController.h"
#import "Group.h"
#import "GroupContact.h"
#import "DataController.h"
#import "PersonViewController.h"


@interface DetailGroupViewTableController ()

- (void)addressBookDidChange;

@end


@implementation DetailGroupViewTableController

@synthesize dataController = _dataController;
@synthesize delegate = _delegate;
@synthesize group = _group;
@synthesize groupContacts = _groupContacts;
@synthesize searchBar = _searchBar;
@synthesize addButton = _addButton;
@synthesize editButton = _editButton;
@synthesize doneButton = _doneButton;
@synthesize backButton = _backButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataController = [DataController dataController];
        if (!self.dataController) {
            [self release];
            return nil;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookDidChange) name:AddressBookDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_groupContacts release];
    [_group release];
    [_searchBar release];
	[_backButton release];
	[_editButton release];
	[_doneButton release];
	[_addButton release];
    [super dealloc];
}

- (void)addressBookDidChange
{
    self.groupContacts = [self.dataController getGroupContacts:self.group withFilter:self.searchBar.text];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	searchBar.text = @"";
    self.groupContacts = [self.dataController getGroupContacts:self.group withFilter:searchBar.text];
	[self.tableView reloadData];
	[searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.groupContacts = [self.dataController getGroupContacts:self.group withFilter:searchText];
	[self.tableView reloadData];
	
}

- (void)addGroupViewControllerDidFinish:(GroupAddViewController *)controller
{
	if ([controller.textField.text length] > 0) {
		self.title = controller.textField.text;
		self.group.name = controller.textField.text;
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (void)showDetails:(int)personId
{
	PersonViewController *personViewController = [[PersonViewController alloc] init];
    personViewController.personViewDelegate = self;
    personViewController.displayedPerson = ABAddressBookGetPersonWithRecordID(personViewController.addressBook, personId);
    personViewController.allowsEditing = YES;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:personViewController];
    [self presentModalViewController:navController animated:YES];
    [navController release];
	[personViewController release];
}

- (void)cancelContact:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];	
}

- (void)handleRename
{
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

- (void)sendMail
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	ABAddressBookRef ab = ABAddressBookCreate();
    if (ab) {
        // Set up recipients
        NSMutableArray *toRecipients = [NSMutableArray array];
        for (GroupContact *groupContact in self.groupContacts) {
            ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, groupContact.uniqueId);
            ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
            CFIndex	count = ABMultiValueGetCount(multi);
            if (multi == NULL || multi == nil || count == 0) {
                CFRelease(multi);
                continue;
            }
            NSString *address = [(NSString *)ABMultiValueCopyValueAtIndex(multi, 0) autorelease];
            if ([address length] > 0) {
                [toRecipients addObject:address];
            }		
            CFRelease(multi);
        } 
        
        [picker setToRecipients:toRecipients];
        [self presentModalViewController:picker animated:YES];
        [picker release];
        
        CFRelease(ab);
    }
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{	
    if (error) {
        [[GroupsAppDelegate sharedAppDelegate] showErrorMessage:error];
    }
	[self dismissModalViewControllerAnimated:YES];
}

- (void)handleSendSMS
{
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
    
	MessageViewController *controller = [[MessageViewController alloc] init];
	controller.messageComposeDelegate = self;
	controller.group = self.group;
	
	NSMutableArray *toRecipients = [NSMutableArray array];
	
	NSString *userLabel = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"phoneLabel"];

    ABAddressBookRef ab = ABAddressBookCreate();
    for (GroupContact *groupContact in self.groupContacts) {
		BOOL found = FALSE;
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, groupContact.uniqueId);
		ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if (phones) {
            if([userLabel length] > 0) {
                for (CFIndex i=0; i < ABMultiValueGetCount(phones); i++) {
                    NSString *label = [(NSString*) ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phones, i)) autorelease];
                    if ([label isEqualToString:userLabel]) {
                        NSString *phoneNumber = [(NSString *) ABMultiValueCopyValueAtIndex(phones, i) autorelease];
                        [toRecipients addObject:phoneNumber];
                        groupContact.number = phoneNumber;
                        found = TRUE;
                        break;
                    }
                }
            }
            if (!found && groupContact.number) {
                [toRecipients addObject:groupContact.number];
            }
            CFRelease(phones);
        }
	}
    CFRelease(ab);
	
	controller.members = self.groupContacts;
	[controller setRecipients:toRecipients];
	[self presentModalViewController:controller animated:YES];
    [controller release];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
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
	
	ABAddressBookRef book = ABAddressBookCreate();
    if (book) {
        for (GroupContact *groupContact in self.groupContacts) {
            ABRecordRef person = ABAddressBookGetPersonWithRecordID(book, groupContact.uniqueId);
            if (person) {
                ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
                if (emails) {
                    if (ABMultiValueGetCount(emails) > 0) {
                        NSString *address = [(NSString *)ABMultiValueCopyValueAtIndex(emails, 0) autorelease];
                        if (address && [address length]) {
                            if ([recipients isEqualToString:@"mailto:"]) {
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

- (void)viewWillAppear:(BOOL)animated
{
	self.groupContacts = [self.dataController getGroupContacts:self.group withFilter:self.searchBar.text];
	
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)startEdit
{
	[self.tableView setEditing:YES animated:YES];

    self.navigationItem.leftBarButtonItem = self.doneButton;
    self.navigationItem.rightBarButtonItem = self.addButton;
}

- (void)stopEdit
{
	[self.tableView setEditing:NO animated:YES];
	
    self.navigationItem.rightBarButtonItem = self.editButton;
	self.navigationItem.leftBarButtonItem = self.backButton;
}

- (void)addMember
{
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
    
    NSError *error = nil;
    if (![self.dataController addGroupContact:self.group withPerson:person error:&error]) {
        [[GroupsAppDelegate sharedAppDelegate] showErrorMessage:error];
        [error release];
    }
	
	[self.delegate detailViewControllerReload:self];
    self.groupContacts = [self.dataController getGroupContacts:self.group withFilter:self.searchBar.text];
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

- (void)viewDidLoad {
	[super viewDidLoad];
	self.backButton = self.navigationItem.leftBarButtonItem;
	self.editButton = [[UIBarButtonItem alloc] 
                       initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                       target:self
                       action:@selector(startEdit)];
	self.doneButton = [[UIBarButtonItem alloc] 
                       initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                       target:self
                       action:@selector(stopEdit)];
	self.addButton = [[UIBarButtonItem alloc] 
                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                      target:self
                      action:@selector(addMember)];
	self.title = self.group.name;
	self.navigationItem.rightBarButtonItem = self.editButton;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([self.searchBar.text length] > 0) {
		return 1;
	}
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([self.searchBar.text length] > 0) {
		return [self.groupContacts count];
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
			return [self.groupContacts count];
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

	if ([self.searchBar.text length] == 0) {
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
				GroupContact *groupContact = [self.groupContacts objectAtIndex:indexPath.row];
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
		GroupContact *groupContact = [self.groupContacts objectAtIndex:indexPath.row];
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
	if ([self.searchBar.text length] > 0) {
		return NSLocalizedString(@"MembersTitle", @"");
	}
    NSString *title;
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
	if ( (section == 0) && ([self.searchBar.text length] == 0) ) {
		return @"";
	}
	NSString *title;
	int count = [self.groupContacts count];
	if (count != 1) {
		title = [NSString stringWithFormat:@"%i %@", count, NSLocalizedString(@"Members", @"")];
	}
	else {
		title = [NSString stringWithFormat:@"%i %@", count, NSLocalizedString(@"Member", @"")];
	}
    return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.searchBar.text length] > 0) {
		GroupContact *groupContact = [self.groupContacts objectAtIndex:indexPath.row];		
		[self showDetails:groupContact.uniqueId];	
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
			GroupContact *groupContact = [self.groupContacts objectAtIndex:indexPath.row];
			[self showDetails:groupContact.uniqueId];
            break;
		}
        default:
            break;
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.searchBar.text length] > 0) {
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
	
		GroupContact *groupContact = [self.groupContacts objectAtIndex:indexPath.row];
        
        NSError *error = nil;
        if (![self.dataController deleteGroupContact:self.group withPersonId:groupContact.uniqueId error:&error]) {
            [[GroupsAppDelegate sharedAppDelegate] showErrorMessage:error];
            [error release];
        }
        else {
            self.groupContacts = [self.dataController getGroupContacts:self.group withFilter:self.searchBar.text];
            [self.delegate detailViewControllerReload:self];
            [self.tableView reloadData];
        }
    }   
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end

