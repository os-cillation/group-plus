//
//  DataController.m
//  GroupManager2
//
//  Created by Benjamin Mies on 24.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "DataController.h"
#import "Group.h"
#import "CustomAddressBook.h"
#import "SystemAddressBook.h"


@interface DataController ()

@property (nonatomic, retain) id<AddressBookProtocol> addressBook;

- (void)defaultsChanged;

@end


static DataController *sharedDataController = nil;


@implementation DataController

@synthesize addressBook;

- (id)init
{
    self = [super init];
    if (self) {
        // setup the backing address book
        [self defaultsChanged];
        if (!self.addressBook) {
            [self release];
            return nil;
        }
        
        // register to get notified of changes to the user defaults
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    if (sharedDataController == self)
        sharedDataController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setAddressBook:nil];
    [super dealloc];
}

- (void)defaultsChanged
{
    id<AddressBookProtocol> newAddressBook = [[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"] ? [SystemAddressBook systemAddressBook] : [CustomAddressBook customAddressBook];
    if (self.addressBook != newAddressBook) {
        // setup the new address book
        self.addressBook = newAddressBook;
        
        // notify all observers that the address book did change
        [[NSNotificationCenter defaultCenter] postNotificationName:AddressBookDidChangeNotification object:nil];
    }
}

+ (DataController *)dataController
{
    if (!sharedDataController)
        sharedDataController = [[[DataController alloc] init] autorelease];
    return sharedDataController;
}

- (NSArray *)getGroups:(NSString *)filter
{
    return [self.addressBook getGroups:filter];
}

- (BOOL)deleteGroup:(Group *)group error:(NSError **)outError
{
    return [self.addressBook deleteGroup:[group getId] error:outError];
}

-(int)addGroup:(NSString *)name error:(NSError **)outError
{
    return [self.addressBook addGroup:name error:outError];
}

- (BOOL)renameGroup:(Group *)group withName:(NSString *)name error:(NSError **)outError
{
    return [self.addressBook renameGroup:[group getId] withName:name error:outError];
}

-(NSArray *)getGroupContacts:(Group *)group withFilter:(NSString *)filter
{
    return [self.addressBook getGroupContacts:[group getId] withFilter:filter];
}

- (BOOL)addGroupContact:(Group *)group withPerson:(ABRecordRef)person error:(NSError **)outError
{
    return [self.addressBook addGroupContact:[group getId] withPersonId:ABRecordGetRecordID(person) error:outError];
}

- (BOOL)deleteGroupContact:(Group *)group withPersonId:(ABRecordID)personId error:(NSError **)outError
{
    return [self.addressBook deleteGroupContact:[group getId] withPersonId:personId error:outError];
}

// Accessor methods for list
- (unsigned)countOfList:(NSString *)filter {
    return [[self.addressBook getGroups:filter] count];
}

- (Group *)objectInListAtIndex:(unsigned)theIndex withFilter:(NSString *)filter {
    return [[self.addressBook getGroups:filter] objectAtIndex:theIndex];
}

@end
