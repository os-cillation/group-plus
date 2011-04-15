//
//  GroupAddViewController.h
//  Groups
//
//  Created by Benjamin Mies on 03.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

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
