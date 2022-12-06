//
//  MasterViewController.m
//  BuddhaSC
//
//  Created by hoishing on 24/9/13.
//  Copyright (c) 2013 FBM Development. All rights reserved.
//

#import "ContentVC.h"
#import "DetailVC.h"
#import "PlayerVC.h"
#import "Utilities.h"
#import "AppDelegate.h"

@interface ContentVC () {
	NSUserDefaults *ud;
	NSFileManager *fm;
	NSString *serverPath;
}
@property (strong, nonatomic) NSArray *contents;
@property (strong, nonatomic) NSArray *sectionTitles;
@end

@implementation ContentVC

#pragma mark - Subroutines

-(BOOL)checkHistory{
	NSDictionary *dict = [ud dictionaryForKey:@"historyDict"];
	return [fm fileExistsAtPath:dict[@"path"]];
}

-(void)updateFileSizeLabel{
	unsigned long long totalBytes = [Utilities folderSize:[Utilities docPath]];
	NSString *sizeStr = [Utilities byteToMb:totalBytes withDecimalPlaces:1];
	_storageLabel.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"总共", nil), sizeStr];
}

-(void)deleteLang{
	[ud removeObjectForKey:@"audioLang"];
}

-(void)deleteAllDownloadedFiles{
	NSArray *fileNames = [fm contentsOfDirectoryAtPath:[MiniUtility docPath] error:nil];
	for (NSString *fileName in fileNames) {
		NSString *path = [MiniUtility docFile:fileName];
		[fm removeItemAtPath:path error:nil];
	}
}

-(void)prepareContents:(NSString *)audioLang{
	NSString *contentFileName = [NSString stringWithFormat:@"%@Contents.plist", audioLang];
	NSString *contentPath = [MiniUtility bundleFile:contentFileName];
	self.contents = [NSArray arrayWithContentsOfFile:contentPath];
	[self.tableView reloadData];
}

-(void)prepareLang{
	NSString *audioLang = [ud stringForKey:@"audioLang"];
	if (!audioLang) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"请选择语言", nil)
														message:nil delegate:self
											  cancelButtonTitle:NSLocalizedString(@"国语", nil)
											  otherButtonTitles:NSLocalizedString(@"粤语", nil), nil];
		[alert show];
	} else {
		[self prepareContents:audioLang];
	}
}

#pragma mark - KVC

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if (object == ud && [keyPath isEqualToString:@"audioLang"]) {
		id oldVal = change[NSKeyValueChangeOldKey];
		NSString *audioLang = [ud stringForKey:@"audioLang"];
		BOOL isNull = (oldVal == [NSNull null]);
		if (isNull) {
			[self prepareContents:audioLang];
		} else {
			if (![audioLang isEqualToString:oldVal]) {
				[self prepareContents:audioLang];
				[self deleteAllDownloadedFiles];
			}
		}
	}
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	if ([alertView.title isEqualToString:NSLocalizedString(@"请选择语言", nil)]) {
		NSString *audioLang = (buttonIndex == alertView.cancelButtonIndex)? @"Mandarin" : @"Cantonese";
		[ud setObject:audioLang forKey:@"audioLang"];	//will trigger KVO
	} else {
		_continueBut.enabled = [self checkHistory];
	}

}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return _contents.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_contents[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return self.sectionTitles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	NSDictionary *dict = _contents[indexPath.section][indexPath.row];
	cell.textLabel.text = NSLocalizedString(dict[@"ChiFolderName"], nil);
	cell.detailTextLabel.text = NSLocalizedString(dict[@"author"], nil);
    return cell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *dict = _contents[indexPath.section][indexPath.row];
		DetailVC *vc = segue.destinationViewController;
		vc.chapters = dict[@"chapters"];
		vc.engName = NSLocalizedString(dict[@"EngFolderName"], nil);
		vc.chiName = NSLocalizedString(dict[@"ChiFolderName"], nil);
    }
	if ([segue.identifier isEqualToString:@"resumePlaying"]) {
		NSDictionary *dict = [ud dictionaryForKey:@"historyDict"];
		PlayerVC *vc = segue.destinationViewController;
		[vc playFile:dict[@"path"] atTime:[dict[@"time"] doubleValue]];
	}
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	ud = [NSUserDefaults standardUserDefaults];
	fm = [NSFileManager defaultManager];
	[ud addObserver:self forKeyPath:@"audioLang" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];

	self.title = NSLocalizedString(@"目录", nil);
	_continueBut.title = NSLocalizedString(@"继续播放", nil);
//	[self deleteLang]; //for testing only
	self.sectionTitles = @[NSLocalizedString(@"讲经说法", nil), NSLocalizedString(@"读诵持名", nil)];

	[self prepareLang];

}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	_continueBut.enabled = [self checkHistory];
	[self updateFileSizeLabel];
}



@end
