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

#import <AddressBook/AddressBook.h>

@class Group;

@interface DataController : NSObject {

}

+ (DataController *)dataController;

- (NSArray *)getGroups:(NSString *)filter;
- (BOOL)deleteGroup:(Group *)group error:(NSError **)outError;
- (int)addGroup:(NSString *)name error:(NSError **)outError;
- (BOOL)renameGroup:(Group *)group withName:(NSString *)name error:(NSError **)outError;
- (NSArray *)getGroupContacts:(Group *)group withFilter:(NSString *)filter;
- (BOOL)addGroupContact:(Group *)group withPerson:(ABRecordRef)person error:(NSError **)outError;
- (BOOL)deleteGroupContact:(Group *)group withPersonId:(ABRecordID)personId error:(NSError **)outError;

@end

