//
//  GroupAddViewController.h
//  Groups
//
//  Created by Benjamin Mies on 03.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Group.h"

@protocol GroupAddViewControllerDelegate;


@interface GroupAddViewController : UIViewController {
	id <GroupAddViewControllerDelegate> delegate;
	IBOutlet UITextField *textField;
	IBOutlet UILabel *label;
	Group *group;
}

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
