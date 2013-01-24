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

#import "GroupsAppDelegate.h"
#import "RootViewController.h"
#import "CustomAddressBook.h"

#import "AboutViewController.h"


@implementation GroupsAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize viewController;
@synthesize groupViewController;
@synthesize navController;


+ (GroupsAppDelegate *)sharedAppDelegate {
    return (GroupsAppDelegate *) [UIApplication sharedApplication].delegate;
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions { 
	viewController = nil;
	groupViewController = nil;
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	if (viewController != nil && viewController != NULL) {
		[viewController.parentViewController.navigationController popViewControllerAnimated:YES];
		[viewController.parentViewController dismissModalViewControllerAnimated:YES];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	
}

- (void)dismissView {
	if (navigationController != nil && navigationController != NULL) {
		[navigationController popViewControllerAnimated:YES];
	}
}

- (void)handleRefreshFinished {
//	NSLog(@"refresh finished");
}

- (void)showErrorMessage:(NSError *)error {
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Error", @"")
                          message:[error localizedDescription]
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end

