//
//  InfoVC.m
//  BuddhaSC
//
//  Created by hoishing on 29/9/13.
//  Copyright (c) 2013 FBM Development. All rights reserved.
//

#import "InfoVC.h"
#import "Utilities.h"

@interface InfoVC (){
	NSUserDefaults *ud;
}

@end

@implementation InfoVC

#pragma mark - Subroutines

-(void)prepareCellForSelectedLang{
	NSString *lang = [ud stringForKey:@"audioLang"];
	_mandarinCell.accessoryType = _cantoneseCell.accessoryType = UITableViewCellAccessoryNone;
	UITableViewCell *cell = ([lang isEqualToString:@"Mandarin"])? _mandarinCell : _cantoneseCell;
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark - Table view

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section) {
        case 0: sectionName = NSLocalizedString(@"有声书语言", nil); break;
		case 1: sectionName = NSLocalizedString(@"更多佛学讲座", nil); break;
        case 2: sectionName = @"App Development"; break;
		case 3: sectionName = @"© Copyright"; break;
        default: sectionName = @""; break;
    }
    return sectionName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			{
				UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
				if (cell.accessoryType != UITableViewCellAccessoryCheckmark) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"变更有声书语言", nil)
																	message:NSLocalizedString(@"所有离线档案将被删除", nil)
																   delegate:self
														  cancelButtonTitle:@"取消"
														  otherButtonTitles:@"OK", nil];
					[alert show];
				}
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0: [Utilities openSiteFromGlobal:@"amtb"]; break;
				case 1: [Utilities openSiteFromGlobal:@"hwaDzan"]; break;
				case 2: [Utilities openSiteFromGlobal:@"jingZong"]; break;
				default: break;
			}
			break;
		case 2:
			switch (indexPath.row) {
				case 0: [Utilities openSiteFromGlobal:@"fbm"]; break;
				case 1: [Utilities open_iTunesComment:[Utilities globals:@"appID"]]; break;
				default: break;
			}
			break;
		default:
			break;
	}
}

#pragma mark - IBActions

- (IBAction)dismiss:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != alertView.cancelButtonIndex) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		NSString *audioLang = (indexPath.row == 0)? @"Mandarin" : @"Cantonese";
		[ud setObject:audioLang forKey:@"audioLang"];
		[self prepareCellForSelectedLang];
	}
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	ud = [NSUserDefaults standardUserDefaults];
	self.title = NSLocalizedString(@"相关资讯", nil);
	_mandarinCell.textLabel.text = NSLocalizedString(@"国语", nil);
	_cantoneseCell.textLabel.text = NSLocalizedString(@"粤语", nil);
	_amtbCell.textLabel.text = NSLocalizedString(@"净空法师专集", nil);
	_hwadzanCell.textLabel.text = NSLocalizedString(@"华藏净宗弘化网", nil);
	_jingZongCell.textLabel.text = NSLocalizedString(@"净宗学院", nil);
	_commentCell.textLabel.text = NSLocalizedString(@"撰写短评", nil);
	_copyrightCell.textLabel.text = NSLocalizedString(@"欢迎复制流通　功德无量", nil);
	
	[self prepareCellForSelectedLang];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.toolbarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	self.navigationController.toolbarHidden = NO;
}


@end
