//
//  MessageViewController.h
//  GroupSMS
//
//  Created by Benjamin Mies on 14.04.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "Group.h"


@interface MessageViewController : MFMessageComposeViewController <UIActionSheetDelegate> {
	Group *group;
	NSArray *members;
}

@property (nonatomic, retain) Group *group;
@property (nonatomic, copy) NSArray *members;

@end
