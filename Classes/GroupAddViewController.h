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

@protocol GroupAddViewControllerDelegate;

@class DataController;

@interface GroupAddViewController : UIViewController {
    DataController *_dataController;
	id <GroupAddViewControllerDelegate> _delegate;
	IBOutlet UITextField *_textField;
	IBOutlet UILabel *_label;
	Group *_group;
}

@property (nonatomic, retain) DataController *dataController;
@property (nonatomic, assign) id <GroupAddViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) Group *group;

- (IBAction)done;
- (IBAction)addGroup;
- (void)updateText;

@end


@protocol GroupAddViewControllerDelegate
- (void)addGroupViewControllerDidFinish:(GroupAddViewController *)controller;
@end
