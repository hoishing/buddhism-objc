//
//  PlayerVC.h
//  BuddhaSC
//
//  Created by hoishing on 25/9/13.
//  Copyright (c) 2013 FBM Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlayerVC : UIViewController<AVAudioPlayerDelegate>

@property (strong, nonatomic) NSArray *localPaths;
@property (strong, nonatomic) AVAudioPlayer *player;

@property (weak, nonatomic) IBOutlet UILabel *remainTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *durationSlider;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;

-(void)playRow:(int)row;
-(void)playFile:(NSString *)path atTime:(NSTimeInterval)time;

-(IBAction)togglePlayPause;
-(IBAction)stepForward;
-(IBAction)stepBackward;
-(IBAction)nextChapter;
-(IBAction)previousChapter;
-(IBAction)durationSliderDown;
-(IBAction)durationSliderSliding;
-(IBAction)durationSliderUp;
-(IBAction)addBookmark;

@end
