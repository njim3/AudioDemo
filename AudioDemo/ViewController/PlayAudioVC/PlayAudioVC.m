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

@end

@implementation PlayAudioVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
}

- (IBAction)stopAudioBtnAction:(UIButton *)sender {
    if (_avAudioPlayer && _avAudioPlayer.isPlaying) {
        [_avAudioPlayer stop];
    }
}


@end
