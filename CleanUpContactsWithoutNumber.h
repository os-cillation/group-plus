//
//  CleanUpContactsWithoutNumber.h
//  Groups
//
//  Created by Benjamin Mies on 30.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface CleanUpContactsWithoutNumber : UITableViewController <ABPersonViewControllerDelegate>{
	NSArray *data;
}

@end
