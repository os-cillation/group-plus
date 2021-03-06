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

#import "ShareContactsViewController.h"
#import "ABRecordSerializer.h" 


@implementation ShareContactsViewController

@synthesize currentSession, connect, sendContact, message, navBar;

- (IBAction)done:(id)sender {
	[self handleDisconnect];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)handleConnect {
	[connect setHidden:YES];
	[sendContact setHidden:NO];
	picker = [[GKPeerPickerController alloc] init];
	picker.delegate = self;
	picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;  
	   
    [picker show]; 
}

- (void)handleDisconnect {
	if (self.currentSession != nil) {
		[self.currentSession disconnectFromAllPeers];
		[self.currentSession release];
		currentSession = nil;
	}
}

- (IBAction)btnSendContact:(id) sender {
	ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
	peoplePicker.peoplePickerDelegate = self;
	
	[self presentModalViewController:peoplePicker animated:YES];
	[peoplePicker release];     
}

-(void) peerPickerController:(GKPeerPickerController *)pPicker 
              didConnectPeer:(NSString *)peerID 
                   toSession:(GKSession *) session {
    self.currentSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
	pPicker.delegate = nil;
	
    [pPicker dismiss];
    [pPicker autorelease];
}

-(void) peerPickerControllerDidCancel:(GKPeerPickerController *)pPicker {
	[connect setHidden:NO];
	[sendContact setHidden:YES];
    pPicker.delegate = nil;
    [pPicker autorelease];
}



- (void)session:(GKSession *)session 
           peer:(NSString *)peerID 
 didChangeState:(GKPeerConnectionState)state {
    switch (state)
    {
        case GKPeerStateConnected:
            NSLog(@"connected");
            break;
            
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
            [self.currentSession release];
            currentSession = nil;
			[connect setHidden:NO];
			[sendContact setHidden:YES];
            break;
            
        default:
            break;
    }
}

- (void) mySendDataToPeers:(NSData *) data
{
    if (currentSession) {
        [self.currentSession sendDataToAllPeers:data 
								   withDataMode:GKSendDataReliable 
										  error:nil];    
    }
}

- (void) receiveData:(NSData *)data 
            fromPeer:(NSString *)peer 
           inSession:(GKSession *)session 
             context:(void *)context {
	
	newPerson = [ABRecordSerializer createPersonFromData:data];
	
	NSString *contactLabel = (NSString*)ABRecordCopyCompositeName(newPerson);
	NSString *messageTxt = [NSString stringWithFormat:NSLocalizedString(@"contactReceivedMessage", @""), contactLabel];
	
    [self closeCurrentPopup];
	
	currentPopUpView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"contactReceived", @"")
												  message:messageTxt
												 delegate:self
										cancelButtonTitle:NSLocalizedString(@"no", @"")
										otherButtonTitles:NSLocalizedString(@"yes", @""), nil];
	[contactLabel release];
	
	[currentPopUpView show];   
	
}

- (void)closeCurrentPopup {
	if (currentPopUpView) {
		currentPopUpView.delegate = nil;
		[currentPopUpView dismissWithClickedButtonIndex:0 animated:YES];
		[currentPopUpView release];
		currentPopUpView = nil;
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
		if (buttonIndex == 1) { // YES
			[self closeCurrentPopup];
			ABUnknownPersonViewController *addPersonViewController = [[ABUnknownPersonViewController alloc] init];
			addPersonViewController.unknownPersonViewDelegate = self;
			addPersonViewController.displayedPerson = newPerson;
			addPersonViewController.allowsActions = NO;
			addPersonViewController.allowsAddingToAddressBook = YES;
			
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addPersonViewController];
			addPersonViewController.navigationItem.title = NSLocalizedString(@"contactReceived", @"");
			UIBarButtonItem *cancelButton =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																						   target:self action:@selector(cancelContact:)];
			addPersonViewController.navigationItem.leftBarButtonItem = cancelButton;
			[self presentModalViewController:navController animated:NO];
			
			[cancelButton release];
			[addPersonViewController release];
			[navController release];
			CFRelease(newPerson);
		} else { // NO
			[self closeCurrentPopup];
		}
}

- (void)cancelContact:(id)sender {
	[self dismissModalViewControllerAnimated:NO];	
}

- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person {
	[self dismissModalViewControllerAnimated:NO];
}

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	 [super viewDidLoad];
	 [self updateText];
	 [self handleConnect];
	 navBar.topItem.title = NSLocalizedString(@"ShareContacts", @"");
 }

- (void)updateText {
	self.message.text = NSLocalizedString(@"shareContactMessage", @"");
	[connect setTitle:NSLocalizedString(@"connectButton", @"") forState:UIControlStateNormal];
	[connect setTitle:NSLocalizedString(@"connectButton", @"") forState:UIControlStateHighlighted];
	[connect setTitle:NSLocalizedString(@"connectButton", @"") forState:UIControlStateDisabled];
	[connect setTitle:NSLocalizedString(@"connectButton", @"") forState:UIControlStateSelected];
	[sendContact setTitle:NSLocalizedString(@"shareContactButton", @"") forState:UIControlStateNormal];
	[sendContact setTitle:NSLocalizedString(@"shareContactButton", @"") forState:UIControlStateHighlighted];
	[sendContact setTitle:NSLocalizedString(@"shareContactButton", @"") forState:UIControlStateDisabled];
	[sendContact setTitle:NSLocalizedString(@"shareContactButton", @"") forState:UIControlStateSelected];
}
 
//people picker delegate protocol

// Called after the user has pressed cancel
// The delegate is responsible for dismissing the peoplePicker
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[self dismissModalViewControllerAnimated:YES];
}

// Called after a person has been selected by the user.
// Return YES if you want the person to be displayed.
// Return NO  to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectionPerson:(ABRecordRef)person {
	return NO;
}

// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	[self sendContactData:person];
	[self dismissModalViewControllerAnimated:YES];
	return NO;
}

// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	return NO;
}

- (void)sendContactData:(ABRecordRef)person {
    // send the serialized contact
	[self mySendDataToPeers:[ABRecordSerializer personToData:person]]; 
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


- (void)dealloc {
    [super dealloc];
}

@end
