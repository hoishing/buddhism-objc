//
//  BookmarkVC.h
//  BuddhaSC
//
//  Created by hoishing on 30/9/13.
//  Copyright (c) 2013 FBM Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarkVC : UITableViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBut;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBut;

-(IBAction)toggleEditingMode;

@end
