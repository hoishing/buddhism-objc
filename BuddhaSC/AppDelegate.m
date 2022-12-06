//
//  AppDelegate.m
//  BuddhaSC
//
//  Created by hoishing on 24/9/13.
//  Copyright (c) 2013 FBM Development. All rights reserved.
//

#import "AppDelegate.h"
#import "Utilities.h"

@implementation AppDelegate

#pragma mark - App Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//don't backup to iCloud
	[[Utilities docURL:nil] setResourceValue: [NSNumber numberWithBool: YES]
									  forKey: NSURLIsExcludedFromBackupKey error:nil];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
		splitViewController.delegate = self;
	}
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Split view

- (BOOL)splitViewController: (UISplitViewController*)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}


@end
