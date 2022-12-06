//
//  BookmarkVC.m
//  BuddhaSC
//
//  Created by hoishing on 30/9/13.
//  Copyright (c) 2013 FBM Development. All rights reserved.
//

#import "BookmarkVC.h"
#import "PlayerVC.h"
#import "Utilities.h"

@interface BookmarkVC (){
	NSUserDefaults *ud;
	NSMutableArray *bookmarks;
	BOOL editing;
}

@end

@implementation BookmarkVC

#pragma mark - Helper Methods

-(void)refreshTable{
	bookmarks = [NSMutableArray arrayWithArray:[ud arrayForKey:@"bookmarks"]];
	[self.tableView reloadData];
}

-(void)setBookmarkToUD{
	[ud setObject:bookmarks forKey:@"bookmarks"];
}

-(void)checkFileExistance{
	NSArray *originalBookmarks = [ud objectForKey:@"bookmarks"];
	NSMutableArray *tmpBookmarks = [NSMutableArray arrayWithArray:originalBookmarks];
	for (NSDictionary *dict in originalBookmarks) {
		NSString *path = dict[@"path"];
		if (![[NSFileManager defaultManager] fileExistsAtPath:path]) [tmpBookmarks removeObject:dict];		//prevent error from user deleted files from iTunes or DeleteVC
	}
	if ([tmpBookmarks count] < [originalBookmarks count]) {
		bookmarks = tmpBookmarks;
		[self setBookmarkToUD];
	}
}

-(IBAction)toggleEditingMode{
	[self setEditing:!editing animated:YES];
	self.navigationItem.rightBarButtonItem = (editing)? _editBut : _doneBut;
	editing = !editing;
}

#pragma mark - Alert View delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return bookmarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *dict = bookmarks[indexPath.row];
	cell.textLabel.text = [dict objectForKey:@"description"];
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [bookmarks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self setBookmarkToUD];
    }
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    NSDictionary *dict = bookmarks[fromIndexPath.row]; //its strong in ARC
    [bookmarks removeObjectAtIndex:fromIndexPath.row];
    [bookmarks insertObject:dict atIndex:toIndexPath.row];
	[self setBookmarkToUD];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	NSDictionary *dict = bookmarks[indexPath.row];
	PlayerVC *vc = segue.destinationViewController;
	[vc playFile:dict[@"path"] atTime:[dict[@"time"] floatValue]];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"书签", nil);
	ud = [NSUserDefaults standardUserDefaults];
	[self checkFileExistance];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.toolbarHidden = YES;
	[self refreshTable];
}

-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	self.navigationController.toolbarHidden = NO;
}

@end
