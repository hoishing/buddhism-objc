//
//  RecycleVC.m
//  BuddhaSC
//
//  Created by hoishing on 1/10/13.
//  Copyright (c) 2013 FBM Development. All rights reserved.
//

#import "RecycleVC.h"
#import "Utilities.h"

@interface RecycleVC (){
	NSFileManager *fm;
	NSArray *folderArr;
}

@end

@implementation RecycleVC

#pragma mark - Helper Methods

-(void)prepareFolderArr{
	NSString *docPath = [Utilities docPath];
	NSArray *folders = [fm contentsOfDirectoryAtPath:docPath error:nil];
	NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:folders.count];
	for (NSString *folder in folders) {
		NSString *path = [docPath stringByAppendingPathComponent:folder];
		NSNumber *size = [NSNumber numberWithUnsignedLongLong:[Utilities folderSize:path]];
		[tmpArr addObject:@{@"size": size, @"path": path}];
	}
	
	NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"size" ascending:NO];
	[tmpArr sortUsingDescriptors:@[sorter]];
	folderArr = tmpArr;
}


-(void)removeFolderAtRow:(NSInteger)row{
	NSDictionary *dict = folderArr[row];
	[fm removeItemAtPath:dict[@"path"] error:nil];
	[self prepareFolderArr];
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return folderArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
	NSDictionary *dict = folderArr[indexPath.row];
	unsigned long long bytes = [[dict objectForKey:@"size"] unsignedLongLongValue];
	NSString *sizeStr = [Utilities byteToMb:bytes withDecimalPlaces:1];
	
    cell.textLabel.text = [dict[@"path"] lastPathComponent];
    cell.detailTextLabel.text = sizeStr;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self removeFolderAtRow:indexPath.row];
    }
}

#pragma mark - IBActions

- (IBAction)dismiss:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"删除离线档案", nil);
	fm = [NSFileManager defaultManager];
	[self prepareFolderArr];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setEditing:YES animated:YES];
	self.navigationController.toolbarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	self.navigationController.toolbarHidden = NO;
}


@end
