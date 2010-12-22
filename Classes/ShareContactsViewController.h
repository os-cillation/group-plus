//
//  ShareContacts.h
//  Groups
//
//  Created by Benjamin Mies on 04.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

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
