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

#import "AboutViewController.h"


@implementation AboutViewController


@synthesize scrollView, textView;


#pragma mark -
#pragma mark === Action method ===
#pragma mark -

- (IBAction)done {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)openGroupMessage {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=377177900&amp;amp;amp;amp;mt=8"]];
}

- (IBAction)openLentManager {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=370136323&amp;amp;amp;amp;mt=8"]];
}

#pragma mark -
#pragma mark === View configuration ===
#pragma mark -

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    self = [super initWithNibName:nibName bundle:nibBundle];
	if (self) {
		self.wantsFullScreenLayout = YES;
	}
	return self;
}

- (void)viewDidLoad {
	self.scrollView.contentSize = CGSizeMake(320, 700);
	self.title = NSLocalizedString(@"About", @"");
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
								  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								  target:self
								  action:@selector(done)];
    self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
	[super viewDidLoad];
	
	textView.text = NSLocalizedString(@"aboutText", @"");
	labelProducts.text = NSLocalizedString(@"otherProducts", @"");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[scrollView release];
    [textView release];
    [labelProducts release];
    [super dealloc];
}

@end
