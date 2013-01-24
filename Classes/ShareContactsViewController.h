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

#import <GameKit/GKSession.h>
#import <GameKit/GKPeerPickerController.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ShareContactsViewController : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate, ABPeoplePickerNavigationControllerDelegate, ABUnknownPersonViewControllerDelegate> {
	GKSession *currentSession;
	IBOutlet UIButton *connect;
	IBOutlet UIButton *sendContact;
	IBOutlet UITextView *message;
	IBOutlet UINavigationBar *navBar;
	
	GKPeerPickerController *picker;
	
	UIAlertView *currentPopUpView;
	
	ABRecordRef newPerson;
	
}

@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) IBOutlet UIButton *sendContact;
@property (nonatomic, retain) IBOutlet UIButton *connect;
@property (nonatomic, retain) IBOutlet UITextView *message;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;

- (IBAction)handleConnect;
- (IBAction)btnSendContact:(id) sender;
- (IBAction)done:(id)sender;

- (void)handleDisconnect;
- (void)sendContactData:(ABRecordRef)recordRef;
- (void)closeCurrentPopup;
- (void)updateText;


@end
