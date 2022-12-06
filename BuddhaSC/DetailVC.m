//
//  DetailViewController.m
//  BuddhaSC
//
//  Created by hoishing on 24/9/13.
//  Copyright (c) 2013 FBM Development. All rights reserved.
//

#import "DetailVC.h"
#import "DetailCell.h"
#import "PlayerVC.h"
#import "Utilities.h"
#import "WebVC.h"
#import "NetworkFile.h"

@interface DetailVC () {
	NSFileManager *fm;
	NSUserDefaults *ud;
	NSMutableArray *localPaths;
	NSMutableArray *downloadStatus;
	NSMutableArray *engFileNames;
	NSArray *fileSizes;
	unsigned long long dlSize;
	int downloadingRow;
	NetworkFile *nf;
	BOOL cancelFlag;
	NSString *serverPath;
	unsigned long long storedBytes;
}

@property (nonatomic) BOOL isDownloading;

@end

@implementation DetailVC

#pragma mark - Subroutines

-(void)updateSizeLabel:(unsigned long long)bytes{
	NSString *sizeStr = [MiniUtility byteToMb:bytes withDecimalPlaces:1];
	_storageLabel.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"离线档案", nil), sizeStr];
}

-(void)updateStoredSize{
	NSString *folderPath = [MiniUtility docFile:self.title];
	storedBytes = ([fm fileExistsAtPath:folderPath])? [MiniUtility folderSize:folderPath] : 0;
	[self updateSizeLabel:storedBytes];
}


-(void)prepareArrays{
	localPaths = [NSMutableArray array];
	downloadStatus = [NSMutableArray array];
	engFileNames = [NSMutableArray array];
	fileSizes = [_chapters valueForKey:@"bytes"];
	dlSize = 0;
	
	for (NSDictionary *dict in _chapters) {
		NSString *ChiName = [self.title stringByAppendingString:dict[@"ChiSuffix"]];
		NSString *localPath = [[MiniUtility docFile:self.title] stringByAppendingPathComponent:ChiName];
		[localPaths addObject:localPath];
		
		NSString *EngName = [_engName stringByAppendingString:[dict objectForKey:@"EngSuffix"]];
		[engFileNames addObject:EngName];
		
		BOOL fileExists = [fm fileExistsAtPath:localPath];
		[downloadStatus addObject:[NSNumber numberWithBool:fileExists]];
		dlSize += (fileExists)? 0 : [dict[@"bytes"] unsignedLongLongValue];
	}
}

-(void)refreshRow:(int)row{
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)setIsDownloading:(BOOL)downloading{
	self.navigationItem.rightBarButtonItem = (downloading)? _cancelBut : nil ;
	[self.navigationItem setHidesBackButton:downloading animated:NO];
	[UIApplication sharedApplication].idleTimerDisabled = downloading; //prevent device go to sleep
	_isDownloading = downloading;
	[self.tableView reloadData];
}

-(IBAction)cancelDownload{
	cancelFlag = YES;
	[nf cancelDownload];
	[self updateStoredSize];
}

-(void)startDownload{
	for (int i = 0; i < [downloadStatus count]; i++) {
		BOOL fileExists = [downloadStatus[i] boolValue];
		if (!fileExists) {
			self.isDownloading = YES;
			downloadingRow = i;
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
			[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
			DetailCell *cell = (DetailCell *)[self.tableView cellForRowAtIndexPath:indexPath];
			cell.detailTextLabel.hidden = YES;
			cell.dlProgress.hidden = NO;
			
			NSString *path = [NSString stringWithFormat:@"%@%@/%@", serverPath, _engName, engFileNames[i]];
			nf = [NetworkFile networkFileWithPath:path delegate:self clearCache:NO];

			break;
		}	
	}
}


#pragma mark - NetworkFileDelegate Methods

-(void)networkFile:(NetworkFile *)networkFile doneWithCachePath:(NSString *)cachedPath{
	NSString *localPath = [localPaths objectAtIndex:downloadingRow];
	NSString *dirPath = [localPath stringByDeletingLastPathComponent];
	if (![fm fileExistsAtPath:dirPath]) [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
	[fm moveItemAtPath:cachedPath toPath:localPath error:nil];
	[self prepareArrays];
	[self refreshRow:downloadingRow];
	[self updateStoredSize];
	downloadingRow = -1;
	self.isDownloading = NO;
	[self startDownload];
}

-(void)networkFile:(NetworkFile *)networkFile failedWithSourcePath:(NSString *)sourcePath{
	downloadingRow = -1;
	self.isDownloading = NO;
	[self prepareArrays];
	if (!cancelFlag) [Utilities showAlert:NSLocalizedString(@"下载中断，请重试", nil)];
	cancelFlag = NO;
}

-(void)networkFile:(NetworkFile *)networkFile downloadProgress:(unsigned long long)bytes{
	DetailCell *cell = (DetailCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:downloadingRow inSection:0]];
	float fileSize = [fileSizes[downloadingRow] floatValue];
	cell.dlProgress.progress = (float)bytes / fileSize;
	[self updateSizeLabel:storedBytes+bytes];
}


#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1) [self startDownload];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _chapters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
	int row = (int)indexPath.row;
	NSString *path = localPaths[row];
	unsigned long long bytes = [fileSizes[row] unsignedLongLongValue];
	NSString *sizeLabel = [MiniUtility byteToMb:bytes withDecimalPlaces:1];
	BOOL fileExist = [downloadStatus[row] boolValue];
	NSString *detailTxt = (fileExist)? sizeLabel : [sizeLabel stringByAppendingFormat:@"（未%@）", NSLocalizedString(@"下载", nil)];
    cell.textLabel.text = [path lastPathComponent];
	cell.detailTextLabel.text = detailTxt;
	cell.accessoryType = (fileExist)? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	cell.selectionStyle = (_isDownloading && !fileExist)? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
//	cell.dlProgress.hidden = (downloadingRow == row)? NO : YES;
//	cell.detailTextLabel.hidden = (downloadingRow == row)? YES : NO;
	cell.dlProgress.hidden = YES;
	cell.detailTextLabel.hidden = NO;
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (_isDownloading) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
			return indexPath;
		} else {
			return nil;
		}
	}
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = (int)indexPath.row;
	BOOL fileExist = [downloadStatus[row] boolValue];
	
	if (fileExist) {
		NSString *path = localPaths[row];
		NSString *ext = [path pathExtension];
		UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];

		if ([ext isEqualToString:@"mp3"]) {
			PlayerVC *playerVC = [sb instantiateViewControllerWithIdentifier:@"playerVC"];
			playerVC.localPaths = [localPaths pathsMatchingExtensions:@[@"mp3"]];
			[self.navigationController pushViewController:playerVC animated:YES];
			[playerVC playRow:(int)indexPath.row];
		} else {
			WebVC *webVC = [sb instantiateViewControllerWithIdentifier:@"webVC"];
			webVC.filePath = localPaths[row];
			[self.navigationController pushViewController:webVC animated:YES];
		}
	} else {
		NSString *sizeStr = [Utilities byteToMb:dlSize withDecimalPlaces:1];
		NSString *alertTitle = [NSString stringWithFormat:@"%@《%@》?", NSLocalizedString(@"下载", nil), self.title];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:sizeStr
													   delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"OK", nil];
		[alert show];
	}
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}


#pragma mark - Life Cycle


- (void)viewDidLoad
{
    [super viewDidLoad];
	ud = [NSUserDefaults standardUserDefaults];
	fm = [NSFileManager defaultManager];
	self.title = _chiName;
	NSString *serverFolder = ([[ud stringForKey:@"audioLang"] isEqualToString:@"Cantonese"])? @"buddhaAudio" : @"buddhaAudioSC";
	serverPath = [NSString stringWithFormat:@"%@%@/", [MiniUtility globals:@"serverPath"], serverFolder];
	downloadingRow = -1;
	[self updateStoredSize];
	[self prepareArrays];
}

@end
