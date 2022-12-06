//
//  WebVC.h
//  BuddhaSC
//
//  Created by hoishing on 27/9/13.
//  Copyright (c) 2013 FBM Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebVC : UIViewController

@property (strong, nonatomic) NSString *filePath;
@property (weak, nonatomic) IBOutlet UIWebView *webV;

@end
