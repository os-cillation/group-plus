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

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface PreferencesViewController : UIViewController {
	IBOutlet UIScrollView *scrollView;
	IBOutlet UILabel *labelUseAddressbook;
	IBOutlet UILabel *labelUseAddressbook2;
	IBOutlet UISwitch *switchUseAddressbook;
	IBOutlet UITextField *labelText;
	IBOutlet UITextView *message1;
	IBOutlet UITextView *message2;
}

@property (nonatomic, retain) IBOutlet UITextField *labelText;
@property (nonatomic, retain) IBOutlet UITextView *message1;
@property (nonatomic, retain) IBOutlet UITextView *message2;

- (void)updateText;

@end
