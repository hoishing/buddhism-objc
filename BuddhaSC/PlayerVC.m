//
//  PlayerVC.m
//  BuddhaSC
//
//  Created by hoishing on 25/9/13.
//  Copyright (c) 2013 FBM Development. All rights reserved.
//

#import "PlayerVC.h"
#import "Utilities.h"

@interface PlayerVC (){
	NSUserDefaults *ud;
	NSFileManager *fm;
	NSTimer *timer;
	int currentRow;
	NSString *currentPath;
	MPNowPlayingInfoCenter *info;
	NSMutableDictionary *infoDict;
}

@end

const NSTimeInterval kStepDuration = 10;

@implementation PlayerVC



#pragma mark Helper Methods
-(void)noFileAlert{
	[Utilities showAlert:NSLocalizedString(@"档案不存在，请重新下载", nil) withDelegate:self];
}

-(void)prepareAudioSession{
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
	[audioSession setActive:YES error:nil];
}

-(void)prepareInfoCenter{
	info = [MPNowPlayingInfoCenter defaultCenter];
	MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
	NSString *albumTitle = [currentPath stringByDeletingLastPathComponent].lastPathComponent;
	infoDict = [NSMutableDictionary dictionaryWithDictionary:@{MPMediaItemPropertyTitle: self.title,
																		  MPMediaItemPropertyAlbumTitle: albumTitle,
																		  MPMediaItemPropertyArtwork: artwork,
																		  MPMediaItemPropertyPlaybackDuration: @(_player.duration),
																		  MPNowPlayingInfoPropertyElapsedPlaybackTime: @(_player.currentTime),
																		  MPNowPlayingInfoPropertyPlaybackRate: @(1.0),
																		  MPNowPlayingInfoPropertyChapterNumber: @(currentRow),
																		  MPNowPlayingInfoPropertyChapterCount: @(self.localPaths.count)
																		  }];
	info.nowPlayingInfo = infoDict;
}

-(void)updateInfoDict{
	[infoDict setObject:@(_player.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
	info.nowPlayingInfo = infoDict;
}

-(void)startTimer{
	// timer auto retained by NSRunLoop
	if (!timer)	timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
													   selector:@selector(updateSlider) userInfo:NULL repeats:YES];
}

-(void)invalidateTimer{
	[timer invalidate];		//timer will be released by NSRunLoop
	timer = nil;
}


-(void)updateSlider{
	_currentTimeLabel.text = [Utilities second2String:_player.currentTime];
	_remainTimeLabel.text = [NSString stringWithFormat:@"-%@",[Utilities second2String:(_player.duration - _player.currentTime)]];
	_durationSlider.value = _player.currentTime / _player.duration;
}

-(void)step:(BOOL)forward{
	int sign = (forward)? 1 : -1;
	NSTimeInterval deltaTime = _player.currentTime + (sign * kStepDuration);
	BOOL condition = (forward)? deltaTime < _player.duration : deltaTime > 0 ;
	
	BOOL playing = [_player isPlaying];
	if (condition) {
		if (playing) [_player pause];
		_player.currentTime = deltaTime;
		[self updateSlider];
		if (playing) [_player play];
	}
}

-(void)updateHistory{
	if (!_player) return; //when mp3 not exist
	NSTimeInterval seconds = ((_player.duration - _player.currentTime) < 30.0)? _player.duration - 30.0 : _player.currentTime;	//prevent history set at the end
	NSDictionary *dict = @{@"time": @(seconds), @"path": currentPath};
	[ud setObject:dict forKey:@"historyDict"];
}

#pragma mark IBActions

-(IBAction)togglePlayPause{
	if (_player.isPlaying) {
		[self invalidateTimer];
		[_player pause];
	} else {
		[self startTimer];
		[_player play];
	}
	[self updatePlayPauseButton];
}

-(IBAction)stepForward{
	[self step:YES];
}

-(IBAction)stepBackward{
	[self step:NO];
}

-(IBAction)nextChapter{
	[self changeAudio:1];
	[self updatePlayPauseButton];
}

-(IBAction)previousChapter{
	[self changeAudio:-1];
	[self updatePlayPauseButton];
}


-(IBAction)durationSliderDown{
	[self invalidateTimer];
}

-(IBAction)durationSliderSliding{
//	BOOL isPlaying = _player.isPlaying;
//	if (isPlaying) [_player pause];
	NSTimeInterval duration = _player.duration;
	NSTimeInterval currentTimeInterval = _durationSlider.value * duration;
	_currentTimeLabel.text = [Utilities second2String:currentTimeInterval];
	NSTimeInterval remainTimeInterval = _player.duration - currentTimeInterval;
	_remainTimeLabel.text = [NSString stringWithFormat:@"-%@",[Utilities second2String:remainTimeInterval]];
	// player will pause when currentTime = 0
//	_player.currentTime = (currentTimeInterval == duration)? currentTimeInterval - 1 : currentTimeInterval;
//	if (isPlaying) [_player play];
}

-(IBAction)durationSliderUp{
	NSTimeInterval duration = _player.duration;
	NSTimeInterval currentTimeInterval = _durationSlider.value * duration;
	_player.currentTime = (currentTimeInterval == duration)? currentTimeInterval - 1 : currentTimeInterval;
	[self updateInfoDict];
	[self startTimer];
}


-(IBAction)addBookmark{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"新增书签", nil)
													message:nil
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:@"OK", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	UITextField *textField = [alert textFieldAtIndex:0];
	textField.text = [NSString stringWithFormat:@"%@-%@", _currentTimeLabel.text, self.title];
	[alert show];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
	if ([alertView.title isEqualToString:NSLocalizedString(@"档案不存在，请重新下载", nil)]) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	} else {
		if (buttonIndex != alertView.cancelButtonIndex) {
			UITextField *textField = [alertView textFieldAtIndex:0];
			NSNumber *currentTime = [NSNumber numberWithFloat:_player.currentTime];
			NSDictionary *dict = @{@"description": textField.text, @"time": currentTime, @"path": currentPath};
			NSMutableArray *bookmarks = [NSMutableArray arrayWithArray:[ud arrayForKey:@"bookmarks"]];
			[bookmarks addObject:dict];
			[ud setObject:bookmarks forKey:@"bookmarks"];
		}
	}
}

#pragma mark Remote Control Methods

-(BOOL)canBecomeFirstResponder{
	return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
//	NSLog(@"%d", event.subtype);
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlPlay:
		case UIEventSubtypeRemoteControlPause:
			[self togglePlayPause];
			break;
		case UIEventSubtypeRemoteControlNextTrack:
			[self nextChapter];
			break;
		case UIEventSubtypeRemoteControlPreviousTrack:
			[self previousChapter];
			break;
		default:
			break;
	}
	[self updatePlayPauseButton];
}

#pragma mark AVAudioPlayer Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)avPlayer successfully:(BOOL)flag{
	[self nextChapter];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)avPlayer{
	//	player must be playing when receiving this delegate
	//	NSLog(@"begin interrupt");
	[self invalidateTimer];
	[self updatePlayPauseButton];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)avPlayer{
	//	this won't be called after interrupted by iTunes
	//	NSLog(@"end interrupt");
	[self startTimer];
	[_player play];
	[self updatePlayPauseButton];
}

#pragma mark - Class Interfaces

-(void)playRow:(int)row{
	currentRow = row;
	currentPath = _localPaths[row];
	self.title = [[currentPath lastPathComponent] stringByDeletingPathExtension];

	if ([fm fileExistsAtPath:currentPath]) {	// in case file deleted directly from Document folder
		NSURL *audioURL = [NSURL fileURLWithPath:currentPath];
		self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
		_player.delegate = self;
		[_player play];
		[self startTimer];
		[self updatePlayPauseButton];
		[self prepareInfoCenter];
	} else {
		[self noFileAlert];
	}
}

-(void)playFile:(NSString *)path atTime:(NSTimeInterval)time{
	NSString *dirPath = path.stringByDeletingLastPathComponent;
	NSArray *fileNames = [fm contentsOfDirectoryAtPath:dirPath error:nil];
	if (fileNames.count == 0) {
		[self noFileAlert];
		return;
	}
	NSArray *mp3Files = [fileNames pathsMatchingExtensions:@[@"mp3"]];
	NSUInteger row = [mp3Files indexOfObject:path.lastPathComponent];
	if (row != NSNotFound) {
		NSMutableArray *localPaths = [NSMutableArray arrayWithCapacity:mp3Files.count];
		for (NSString *mp3 in mp3Files) {
			[localPaths addObject:[dirPath stringByAppendingPathComponent:mp3]];
		}
		self.localPaths = localPaths;
		[self playRow:(int)row];
		self.player.currentTime = time;
		[self updateInfoDict];
	} else {
		[self noFileAlert];
	}
}

-(void)changeAudio:(int)delta{
	if (delta > 0) {
		int nextRow = currentRow + 1;
		if (nextRow < _localPaths.count) {
			BOOL fileExists = [fm fileExistsAtPath:_localPaths[nextRow]];
			if (fileExists) [self playRow:nextRow];
		}
	} else {
		int previousRow = currentRow - 1;
		if (previousRow >= 0) {
			BOOL fileExists = [fm fileExistsAtPath:_localPaths[previousRow]];
			if (fileExists) [self playRow:previousRow];
		}
	}
}

-(void)updatePlayPauseButton{
	BOOL playing = _player.playing;
	_playPauseButton.selected = (playing)? YES : NO;
}

#pragma mark - LifeCycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
		ud = [NSUserDefaults standardUserDefaults];
		fm = [NSFileManager defaultManager];
		[self prepareAudioSession];
    }
    return self;
}

//-(void)viewDidLoad{
//	[super viewDidLoad];
//}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	self.navigationController.toolbarHidden = YES;
	[self updatePlayPauseButton];
}

-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	if ([timer isValid]) [self invalidateTimer];
	self.navigationController.toolbarHidden = NO;
}

-(void)viewDidAppear:(BOOL)animated{
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
}

-(void)dealloc{
	[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
	[self resignFirstResponder];
	[self updateHistory];
}

@end
