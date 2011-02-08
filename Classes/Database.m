//
//  Database.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "Database.h"
#import "Group.h"
#import "GroupContact.h"
#import "GroupsAppDelegate.h"



@implementation Database

+ (void)createEditableCopyOfDatabaseIfNeeded {
	NSLog(@"Creating editable copy of database...");

	BOOL success;
	NSFileManager *fileManager = [NSFileManager alloc];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
	success = [fileManager fileExistsAtPath:writableDBPath];
	if (success) return;
	[fileManager removeItemAtPath:writableDBPath error:&error];
	
	// The writeable database does not exist, so copy the default to the appropriate location
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"data.sqlite"];

	success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	if (!success) {
		//NSAssert1(0, @"Failed to create writeable database file with message'%@'.", [error localizedDescription]);
		NSLog(@"Failed to create writeable database");
	}
	
	
}

+ (sqlite3 *) getNewDBConnection {
	sqlite3 *newDBConnection;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
	// Open the database.
	if (sqlite3_open([path UTF8String], &newDBConnection) == SQLITE_OK) {
		//NSLog(@"Databases successfully opened...");
	}
	else {
		//NSLog(@"Error while openening database...");
	}
	connection = newDBConnection;
	
	sqlite3_exec(connection, "ALTER TABLE groups ADD COLUMN abGroup TINYINT(1);", NULL, NULL, NULL);
	sqlite3_exec(connection, "ALTER TABLE groupContacts ADD COLUMN abGroup TINYINT(1);", NULL, NULL, NULL);
	
	sqlite3_exec(connection, "UPDATE groups SET abGroup = 0 WHERE abGroup isNull;", NULL, NULL, NULL);
	sqlite3_exec(connection, "UPDATE groupContacts SET abGroup = 0 WHERE abGroup isNull;", NULL, NULL, NULL);

	return newDBConnection;
}

+ (sqlite3 *)getConnection {
	if (connection == nil || connection == NULL) {
		//NSLog(@"create a new database instance...");
		[Database getNewDBConnection];
		
		[self performSelectorOnMainThread:@selector(prepareGroupInfo) withObject:nil waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(prepareContactInfo) withObject:nil waitUntilDone:YES];
		[NSThread detachNewThreadSelector:@selector(prepareDuplicateInfo) toTarget:self withObject:nil];
	}
	return connection;
}

+ (void)refreshData {
	[self performSelectorOnMainThread:@selector(prepareGroupInfo) withObject:nil waitUntilDone:YES];
	[NSThread detachNewThreadSelector:@selector(prepareContactInfo) toTarget:self withObject:nil];
	[NSThread detachNewThreadSelector:@selector(prepareDuplicateInfo) toTarget:self withObject:nil];

	[[GroupsAppDelegate sharedAppDelegate] handleRefreshFinished];
}

+ (void)prepareGroupInfo{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSLog(@"prepare group info...");
	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	const char *sql;
	
	statement = nil;
	sql  = "CREATE TABLE IF NOT EXISTS groups(id INTEGER PRIMARY KEY, name TEXT, abGroup TINYINT(1));";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	statement = nil;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {

		sql  = "DELETE FROM groups WHERE abGroup=1;";
		
		if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
			NSLog(@"%s",sql);
		}
		sqlite3_step(statement);
		sqlite3_finalize(statement);
		
		
		ABAddressBookRef ab = ABAddressBookCreate();
		CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(ab);
		
		for (CFIndex i = CFArrayGetCount(groups)-1; i >= 0; i--) {
			ABRecordRef group = (ABRecordRef) CFArrayGetValueAtIndex(groups, i);
			NSString *name = (NSString*) ABRecordCopyValue(group, kABGroupNameProperty);
			ABRecordID groupId = ABRecordGetRecordID(group);

			NSString *sqlString = [[NSString alloc] initWithFormat:@"INSERT INTO groups (id, name, abGroup) VALUES (%i, ?, 1);", groupId];
			
			statement = nil;
			sql  = [sqlString cString];
			
			if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
				//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
				NSLog(@"%s",sql);
			}
			sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_step(statement);
			sqlite3_finalize(statement);
			[sqlString release];		
		}
		CFRelease(ab);
	}
	[pool release];
}

+ (void)prepareContactInfo{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSLog(@"prepare contact info...");
	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	const char *sql;

	statement = nil;
	sql  = "CREATE TABLE IF NOT EXISTS groupContacts(groupId INTEGER, id INTEGER, name TEXT, number TEXT, abGroup TINYINT(1), PRIMARY KEY(groupId, id, abGroup));";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
		statement = nil;
		sql  = "DELETE FROM groupContacts WHERE abGroup=1;";
		
		if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
			NSLog(@"%s",sql);
		}
		sqlite3_step(statement);
		sqlite3_finalize(statement);
		
		
		ABAddressBookRef ab = ABAddressBookCreate();
		CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(ab);
		
		for (CFIndex i = CFArrayGetCount(groups)-1; i >= 0; i--) {
			ABRecordRef group = (ABRecordRef) CFArrayGetValueAtIndex(groups, i);
			ABRecordID groupId = ABRecordGetRecordID(group);		
			
			CFArrayRef contacts = ABGroupCopyArrayOfAllMembers(group);
			if (contacts == NULL || contacts == nil) continue;
			
			for (CFIndex j = CFArrayGetCount(contacts)-1; j >= 0; j--) {
			
				ABRecordRef	person = (ABRecordRef) CFArrayGetValueAtIndex(contacts, j);
				ABRecordID personId = ABRecordGetRecordID(person);
			
				NSString* firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
				NSString* lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);

				NSString *fullName = [NSString alloc];
				if ((firstName == NULL) && (lastName == NULL)) {
					fullName = (NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
				}	
				else if ((firstName == NULL) || (lastName == NULL)) {
					if (firstName == NULL) {
						fullName = lastName;
					}
					if (lastName == NULL) {
						fullName = firstName;
					}
				}
				else {
					fullName = [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
				}
				
				NSString *phoneNumber = [NSString alloc];
				phoneNumber = @"";
				ABMultiValueRef phoneProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
				CFIndex	count = ABMultiValueGetCount(phoneProperty);
				for (CFIndex i=0; i < count; i++) {
					NSString *label = (NSString*)ABMultiValueCopyLabelAtIndex(phoneProperty, i);
					
					if(([label isEqualToString:(NSString*)kABPersonPhoneMobileLabel]) /*|| ([label isEqualToString:kABPersonPhoneIPhoneLabel])*/) {
						phoneNumber = (NSString*)ABMultiValueCopyValueAtIndex(phoneProperty, i);
						break;
					}
				}
			
				statement = nil;

				NSString *sqlString = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO groupContacts(groupId, id, name, number, abGroup) VALUES (%i, %i, ?, ?,1);",groupId, personId];

				sql  = [sqlString cString];
				
				if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
					//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
					NSLog(@"%s",sql);
				}
				sqlite3_bind_text(statement, 1, [fullName UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 2, [phoneNumber UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_step(statement);
				sqlite3_finalize(statement);
			}
		}
	}
	[pool release];
}

+ (NSMutableArray *)getGroups:(NSString *)filter {
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	const char *sql = "SELECT * FROM groups WHERE abGroup=0 ORDER BY name COLLATE NOCASE;";
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
		sql = "SELECT * FROM groups WHERE abGroup=1 ORDER BY name COLLATE NOCASE;";
	}
	
	
	if (filter != nil && [filter length] > 0) {
		NSString *sqlString = [[NSString alloc] initWithFormat:@"SELECT * FROM groups WHERE abGroup=0 name LIKE ? ORDER BY name COLLATE NOCASE;"];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
			sqlString = [[NSString alloc] initWithFormat:@"SELECT * FROM groups WHERE abGroup=1 name LIKE ? ORDER BY name COLLATE NOCASE;"];
		}
		sql = [sqlString cString];
	}
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		filter = [[NSString alloc] initWithFormat:@"%%%@%%", filter];
		sqlite3_bind_text(statement, 1, [filter UTF8String], -1, SQLITE_TRANSIENT);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Group *group = [Group alloc];
			NSString *groupId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			[group setId:[groupId intValue]];
			const char *groupName = (const char *)sqlite3_column_text(statement,1);
			if (groupName != NULL) {
				group.name = [NSString stringWithUTF8String:groupName];
			}
			
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {

				ABAddressBookRef ab = ABAddressBookCreate();
				ABRecordRef groupRef =  ABAddressBookGetGroupWithRecordID (ab, [group getId]);
				group.count = 0;
				if (groupRef != NULL && groupRef != nil) {
					CFArrayRef member = ABGroupCopyArrayOfAllMembers (groupRef);
					if (member !=nil && member != NULL) {				
						group.count = CFArrayGetCount(member);
					}
				}

			}
			else {
				group.count = [Database getGroupContactsCount:[group getId]];
			}

			[data addObject:group];
			[group release];
		}
	}
	sqlite3_finalize(statement);
	
	return data;
}

+ (int)addGroup:(ABRecordID) groupId withName:(NSString *)name {
	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	
	if (groupId > 0) {
		NSString *sqlString = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO groups (id, name, abGroup) VALUES (%i, ?, 0);", groupId];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
			sqlString = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO groups (id, name, abGroup) VALUES (%i, ?, 1);", groupId];
		}
		
		const char *sql = [sqlString cString];
		
		if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
			NSLog(@"%s",sql);
		}
		sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
		
		sqlite3_step(statement);
		sqlite3_finalize(statement);
		return groupId;
	}
	else {
		NSString *sqlString = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO groups (name, abGroup) VALUES (?,0);"];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) {
			sqlString = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO groups (name, abGroup) VALUES (?,1);"];
		}
		const char *sql = [sqlString cString];
		
		if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
			NSLog(@"%s",sql);
		}
		sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
		
		sqlite3_step(statement);
		sqlite3_finalize(statement);
		return sqlite3_last_insert_rowid(db);
	}

}

+ (void)deleteGroup:(ABRecordID) groupId {
	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	
	NSString *sqlString = [[NSString alloc] initWithFormat:@"DELETE FROM groups WHERE id=%i;", groupId];
	
	const char *sql = [sqlString cString];
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	sqlString = [[NSString alloc] initWithFormat:@"DELETE FROM groupContacts WHERE groupId=%i;", groupId];
	
	sql = [sqlString cString];
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	
	sqlite3_step(statement);
	sqlite3_finalize(statement);
}

+ (int)getGroupContactsCount:(ABRecordID)groupId {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	NSString *sqlString;
	
	sqlString = [[NSString alloc] initWithFormat:@"SELECT count(*) FROM groupContacts WHERE groupId=%i ORDER BY name;", groupId]; 
	
	const char* sql = [sqlString cString];
	
	int count = 0;
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSString *countString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			count = [countString intValue];
		}
	}
	sqlite3_finalize(statement);
	return count;
}

+ (NSMutableArray *)getGroupContacts:(ABRecordID)groupId withFilter:(NSString *)filter {
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	NSString *sqlString;
	
	if (filter == nil || [filter length] == 0) {
		sqlString = [[NSString alloc] initWithFormat:@"SELECT * FROM groupContacts WHERE groupId=%i ORDER BY name;", groupId]; 
	}
	else {
		sqlString = [[NSString alloc] initWithFormat:@"SELECT * FROM groupContacts WHERE groupId=%i AND name LIKE ? ORDER BY name;", groupId]; 
	}

	const char* sql = [sqlString cString];
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		filter = [[NSString alloc] initWithFormat:@"%%%@%%", filter];
		sqlite3_bind_text(statement, 1, [filter UTF8String], -1, SQLITE_TRANSIENT);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			GroupContact *contact = [GroupContact alloc];
			NSString *contactId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 1)];
			
			ABAddressBookRef ab = ABAddressBookCreate();
			ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab, [contactId intValue]);
			[contact setId:[contactId intValue]];

			contact.number = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 3)];

			const char *name = (const char *)sqlite3_column_text(statement,2);
			if (name != NULL) {
				contact.name = [NSString stringWithUTF8String:name];
			}
			if (personRef) {
				[data addObject:contact];
			}
			else {
				[Database deleteGroupContact:groupId withContactId:[contactId intValue]];
			}

			[contact release];
		}
	}
	sqlite3_finalize(statement);
	
	return data;
}

+ (void)addGroupContact:(ABRecordID) groupId withContactId:(ABRecordID) contactId withName:(NSString *)name withNumber:(NSString *) number {
	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	
	NSString *sqlString = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO groupContacts (groupId,id, name, number, abGroup) VALUES (%i, %i, ?, ?, %i);", groupId, contactId, ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAddressbook"]) ? 1 : 0];
	
	const char *sql = [sqlString cString];
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 2, [number UTF8String], -1, SQLITE_TRANSIENT);
	
	sqlite3_step(statement);
	sqlite3_finalize(statement);
}

+ (void)deleteGroupContact:(ABRecordID) groupId withContactId:(ABRecordID) contactId {
	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	
	NSString *sqlString = [[NSString alloc] initWithFormat:@"DELETE FROM groupContacts WHERE groupId=%i AND id=%i;", groupId, contactId];
	
	const char *sql = [sqlString cString];
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	
	sqlite3_step(statement);
	sqlite3_finalize(statement);
}

+ (void)prepareDuplicateInfo {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSLog(@"prepare duplicate info...");
	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	NSString *sqlString;
	const char *sql;
	
	statement = nil;
	sql  = "DROP TABLE IF EXISTS contactDuplicateName;";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
	//	NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	statement = nil;
	sql  = "CREATE TABLE IF NOT EXISTS contactDuplicateName(id INTEGER, name TEXT, numberCount INTEGER, foto TINYINT(1), email INTEGER);";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
	//	NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	statement = nil;
	sql  = "CREATE TABLE IF NOT EXISTS contactDuplicateNumber(id INTEGER, name TEXT, number TEXT);";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
	//	NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	statement = nil;
	sql  = "DELETE FROM contactDuplicateNumber;";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
	//	NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	
	
	ABAddressBookRef ab = ABAddressBookCreate();
	CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(ab);
	
	for (CFIndex i = CFArrayGetCount(contacts)-1; i >= 0; i--) {

		ABRecordRef	person = (ABRecordRef) CFArrayGetValueAtIndex(contacts, i);
		ABRecordID personId = ABRecordGetRecordID(person);
			
		NSString* firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
		NSString* lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
			
		NSString *fullName = [NSString alloc];
		if ((firstName == NULL) && (lastName == NULL)) {
			fullName = (NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
		}	
		else if ((firstName == NULL) || (lastName == NULL)) {
			if (firstName == NULL) {
				fullName = lastName;
			}
			if (lastName == NULL) {
				fullName = firstName;
			}
		}
		else {
			fullName = [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
		}
		if (!fullName) {
			continue;
		}
		
		ABMultiValueRef phoneProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
		CFIndex	count = ABMultiValueGetCount(phoneProperty);
		//ABMultiValueRef emailProperty = ABRecordCopyValue(person, kABPersonEmailProperty);
		//CFIndex emailCount = ABMultiValueGetCount(emailProperty);
		int emailCount = 0;
		
		statement = nil;

		sqlString = [[NSString alloc] initWithFormat:@"INSERT OR IGNORE INTO contactDuplicateName(id, name, numberCount, foto, email) VALUES (%i, ?, %i, 0, %i);",personId, count, emailCount];
		
		sql  = [sqlString cString];
		
		if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
			NSLog(@"%s",sql);
		}
		else {
			sqlite3_bind_text(statement, 1, [fullName UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_step(statement);
		}

		
		sqlite3_finalize(statement);


		for (CFIndex i=0; i < count; i++) {
			
			NSString *phoneNumber = (NSString*)ABMultiValueCopyValueAtIndex(phoneProperty, i);
			phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
			phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+49" withString:@"0"];
			statement = nil;
			sqlString = [[NSString alloc] initWithFormat:@"INSERT OR IGNORE INTO contactDuplicateNumber(id, name, number) VALUES (%i, ?, ?);",personId];

			sql  = [sqlString cString];
			
			if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
				//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
				NSLog(@"%s",sql);
			}
			sqlite3_bind_text(statement, 1, [fullName UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statement, 2, [phoneNumber UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_step(statement);
			sqlite3_finalize(statement);
		}			
	}
	[pool release];
}

+ (NSMutableArray *)getDuplicateNameData {
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	const char* sql = "SELECT * FROM contactDuplicateName GROUP BY name HAVING count(*) > 1 ORDER BY name;"; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSMutableArray *sectionData = [[NSMutableArray alloc] init];


			NSString *name = [[NSString alloc] init];
			const char *tmpName = (const char *)sqlite3_column_text(statement,1);
			if (tmpName != NULL) {
				name = [NSString stringWithUTF8String:tmpName];
			}
			
			sqlite3_stmt *statement = nil;
			
			NSString *sqlString = [[NSString alloc] initWithFormat:@"SELECT id FROM contactDuplicateName WHERE name = ?;"];
			sql = [sqlString cString]; 
			
			if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
				//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
				NSLog(@"%s",sql);
			}
			else {
				sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
				while (sqlite3_step(statement) == SQLITE_ROW) {
					GroupContact *contact = [GroupContact alloc];
					
					NSString *contactId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
					[contact setId:[contactId intValue]];
					contact.name = name;
					
					[sectionData addObject:contact];
					[contact release];
				}
			}
			sqlite3_finalize(statement);
			//if ([sectionData count] > 0) {
				[data addObject:sectionData];
			//}
		}
	}
	sqlite3_finalize(statement);
	
	return data;
}

+ (NSMutableArray *)getDuplicateNumberData {
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	
	const char* sql = "SELECT * FROM contactDuplicateNumber GROUP BY number HAVING count(*) > 1 ORDER BY name;"; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSMutableArray *sectionData = [[NSMutableArray alloc] init];
			
			
			NSString *number = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 2)];
			
			sqlite3_stmt *statement = nil;
			
			NSString *sqlString = [[NSString alloc] initWithFormat:@"SELECT id, name FROM contactDuplicateNumber WHERE number = ?;"];
			sql = [sqlString cString]; 
			
			if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
				//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
				NSLog(@"%s",sql);
			}
			else {
				sqlite3_bind_text(statement, 1, [number UTF8String], -1, SQLITE_TRANSIENT);
				while (sqlite3_step(statement) == SQLITE_ROW) {
					GroupContact *contact = [GroupContact alloc];
					
					NSString *contactId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
					[contact setId:[contactId intValue]];
					
					const char *name = (const char *)sqlite3_column_text(statement,1);
					if (name != NULL) {
						contact.name = [NSString stringWithUTF8String:name];
					}
					
					contact.number = number;
					
					[sectionData addObject:contact];
					[contact release];
				}
			}
			sqlite3_finalize(statement);
			//if ([sectionData count] > 0) {
				[data addObject:sectionData];
			//}
		}
	}
	sqlite3_finalize(statement);
	
	return data;
}

+ (NSMutableArray *)getWithoutNumberData {
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	
	const char* sql = "SELECT * FROM contactDuplicateName WHERE numberCount=0 ORDER BY name;"; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {		
			GroupContact *contact = [GroupContact alloc];
			NSString *contactId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			[contact setId:[contactId intValue]];
			
			const char *name = (const char *)sqlite3_column_text(statement,1);
			if (name != NULL) {
				contact.name = [NSString stringWithUTF8String:name];
			}
					
			[data addObject:contact];
			[contact release];

		}
	}
	sqlite3_finalize(statement);
	
	return data;
}

+ (NSMutableArray *)getWithoutEmailData:(NSString *)filter {
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	const char* sql;
	
	if (filter != nil && [filter length] != 0) {
		NSString *sqlString = [[NSString alloc] initWithFormat:@"SELECT * FROM contactDuplicateName WHERE email=0 AND name LIKE ? ORDER BY name;"];
		sql = [sqlString cString]; 
	}
	else {
		sql = "SELECT * FROM contactDuplicateName WHERE email=0 ORDER BY name;"; 
	}
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"error preparing statement...");
		NSLog(@"%s",sql);
	}
	else {
		filter = [[NSString alloc] initWithFormat:@"%%%@%%", filter];
		sqlite3_bind_text(statement, 1, [filter UTF8String], -1, SQLITE_TRANSIENT);
		while (sqlite3_step(statement) == SQLITE_ROW) {		
			GroupContact *contact = [GroupContact alloc];
			NSString *contactId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			[contact setId:[contactId intValue]];
			
			const char *name = (const char *)sqlite3_column_text(statement,1);
			if (name != NULL) {
				contact.name = [NSString stringWithUTF8String:name];
			}
			
			[data addObject:contact];
			[contact release];
			
		}
	}
	sqlite3_finalize(statement);
	
	return data;
}

+ (NSMutableArray *)getWithoutFotoData:(NSString *)filter {
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	const char* sql;
	
	if (filter != nil && [filter length] != 0) {
		NSString *sqlString = [[NSString alloc] initWithFormat:@"SELECT * FROM contactDuplicateName WHERE foto=0 AND name LIKE ? ORDER BY name;"];
		sql = [sqlString cString]; 
	}
	else {
		sql = "SELECT * FROM contactDuplicateName WHERE foto=0 ORDER BY name;"; 
	}
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSLog(@"error preparing statement...");
		NSLog(@"%s",sql);
	}
	else {
		filter = [[NSString alloc] initWithFormat:@"%%%@%%", filter];
		sqlite3_bind_text(statement, 1, [filter UTF8String], -1, SQLITE_TRANSIENT);
		while (sqlite3_step(statement) == SQLITE_ROW) {		
			GroupContact *contact = [GroupContact alloc];
			NSString *contactId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			[contact setId:[contactId intValue]];
			
			const char *name = (const char *)sqlite3_column_text(statement,1);
			if (name != NULL) {
				contact.name = [NSString stringWithUTF8String:name];
			}
			
			[data addObject:contact];
			[contact release];
			
		}
	}
	sqlite3_finalize(statement);
	
	return data;
}

+ (void)deleteCleanUpContact:(int)contactId {
	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	const char *sql;
	NSString *sqlString;
	
	sqlString = [[NSString alloc] initWithFormat:@"DELETE FROM contactDuplicateName WHERE id=%i;", contactId]; 
	sql = [sqlString cString];
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	statement = nil;
	
	sqlString = [[NSString alloc] initWithFormat:@"DELETE FROM contactDuplicateNumber WHERE id=%i;", contactId]; 
	sql = [sqlString cString];
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);	
}

@end
