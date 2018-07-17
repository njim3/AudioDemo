//
//  PlayAudioVC.m
//  AudioDemo
//
//  Created by njim3 on 01/02/2018.
//  Copyright © 2018 cnbmsmart. All rights reserved.
//

#import "PlayAudioVC.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayAudioVC () {
    AVAudioPlayer* _avAudioPlayer;
}

@property (weak, nonatomic) IBOutlet UIImageView *playVoiceIV;

@end

@implementation PlayAudioVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Layout
- (void)layoutViews {
    [self setPlayVoiceIVStyle];
}

- (void)setPlayVoiceIVStyle {
    self.playVoiceIV.animationImages = @[UIImageNamed(BG_PLAYVOICE_1),
                                         UIImageNamed(BG_PLAYVOICE_2),
                                         UIImageNamed(BG_PLAYVOICE_3)];
    self.playVoiceIV.animationDuration = 0.8f;
    self.playVoiceIV.animationRepeatCount = 0;
}

#pragma mark - View Action
- (IBAction)playAudioBtnAction:(UIButton *)sender {
    if (_avAudioPlayer && _avAudioPlayer.isPlaying) {
        return ;
    }
    
    if ([[FileManager manager] isFileExistsAtPath: self.filePath]) {
        _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
                          [NSURL fileURLWithPath: self.filePath]
                                                                error: nil];
        
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback
                                               error: nil];
        
        [_avAudioPlayer play];
        
        [self.playVoiceIV startAnimating];
    }
}

- (IBAction)stopAudioBtnAction:(UIButton *)sender {
    if (_avAudioPlayer && _avAudioPlayer.isPlaying) {
        [_avAudioPlayer stop];
        
        [self.playVoiceIV stopAnimating];
    }
}


@end
