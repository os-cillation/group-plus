//
//  PreferencesViewController.h
//  GroupPlus
//
//  Created by Benjamin Mies on 15.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface PreferencesViewController : UIViewController {
	IBOutlet UITextField *labelText;
	IBOutlet UITextView *message1;
	IBOutlet UITextView *message2;
}

@property (nonatomic, retain) IBOutlet UITextField *labelText;
@property (nonatomic, retain) IBOutlet UITextView *message1;
@property (nonatomic, retain) IBOutlet UITextView *message2;

- (void)updateText;

@end
