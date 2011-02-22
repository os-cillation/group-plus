//
//  AboutViewController.m
//  Groups
//
//  Created by Benjamin Mies on 04.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

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
	
	if (self = [super initWithNibName:nibName bundle:nibBundle]) {
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
    [super dealloc];
	[scrollView release];
}

@end
