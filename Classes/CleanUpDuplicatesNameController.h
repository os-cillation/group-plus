//
//  CleanUpDuplicatesNameController.h
//  Groups
//
//  Created by Benjamin Mies on 29.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface CleanUpDuplicatesNameController : UITableViewController <ABPersonViewControllerDelegate>{
	NSArray *_data;
}

@end
