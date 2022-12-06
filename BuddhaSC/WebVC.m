//
//  WebVC.m
//  BuddhaSC
//
//  Created by hoishing on 27/9/13.
//  Copyright (c) 2013 FBM Development. All rights reserved.
//

#import "WebVC.h"

@interface WebVC ()

@end

@implementation WebVC


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = [_filePath lastPathComponent];
	NSURL *url = [NSURL fileURLWithPath:_filePath];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[_webV loadRequest:request];
}


- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	self.navigationController.toolbarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	self.navigationController.toolbarHidden = NO;
}


@end
