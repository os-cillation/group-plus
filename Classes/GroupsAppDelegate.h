//
//  GroupsAppDelegate.h
//  Groups
//
//  Created by Benjamin Mies on 03.03.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "DetailGroupViewTableController.h"

@interface GroupsAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	UIViewController *viewController;
	DetailGroupViewTableController *groupViewController;
	UINavigationController *navController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) DetailGroupViewTableController *groupViewController;
@property (nonatomic, retain) UINavigationController *navController;

+ (GroupsAppDelegate *)sharedAppDelegate;
- (void)handleRefreshFinished;

@end

