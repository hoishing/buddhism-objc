//
//  DetailViewController.h
//  BuddhaSC
//
//  Created by hoishing on 24/9/13.
//  Copyright (c) 2013 FBM Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailVC : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *storageLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBut;

@property (strong, nonatomic) NSArray *chapters;
@property (strong, nonatomic) NSString *engName;
@property (strong, nonatomic) NSString *chiName;

-(IBAction)cancelDownload;

@end
