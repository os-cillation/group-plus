//
//  SystemAdressBook.h
//  GroupPlus
//
//  Created by Dennis on 13.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "AddressBookProtocol.h"

@interface SystemAddressBook : NSObject <AddressBookProtocol> {
    ABAddressBookRef _addressBook;
}

+ (SystemAddressBook *)systemAddressBook;

@end
