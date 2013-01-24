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

#import "Group.h"


@implementation Group

@synthesize name, count;

- (void)dealloc
{
	[name release];
	[super dealloc];
}

- (void)setId:(ABRecordID)pId{
	groupId = pId;
}

- (ABRecordID)getId{
	return groupId ;
}

- (NSComparisonResult)compareByName:(Group *)group
{
    return [self.name compare:group.name];
}

@end
