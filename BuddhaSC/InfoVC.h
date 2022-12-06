//
//  InfoVC.h
//  BuddhaSC
//
//  Created by hoishing on 29/9/13.
//  Copyright (c) 2013 FBM Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoVC : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *mandarinCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cantoneseCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *amtbCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *hwadzanCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *jingZongCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *commentCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *copyrightCell;

- (IBAction)dismiss:(id)sender;

@end
