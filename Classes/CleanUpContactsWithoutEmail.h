//
//  CleanUpContactsWithoutEmail.h
//  Groups
//
//  Created by Benjamin Mies on 06.04.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface CleanUpContactsWithoutEmail : UITableViewController <ABPersonViewControllerDelegate>{
		NSArray *data;
		IBOutlet UISearchBar *searchBar;
	}
	
	@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

@end
