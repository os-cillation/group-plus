//
//  Database.h
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "AddressBookProtocol.h"
#import <sqlite3.h>

extern NSString *const CustomAddressBookErrorDomain;

@interface CustomAddressBook : NSObject <AddressBookProtocol> {
    ABAddressBookRef _addressBook;
    sqlite3 *_db;
}

+ (id)customAddressBook;

@end
