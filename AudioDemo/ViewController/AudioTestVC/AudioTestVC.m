//
//  AudioTestVC.m
//  AudioDemo
//
//  Created by njim3 on 01/02/2018.
//  Copyright © 2018 cnbmsmart. All rights reserved.
//

#import "AudioTestVC.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioTestVC () {
    NSTimer* _timer;
    
    int _countDown;
    
    NSString* _curAudioFilePath;
    NSURL* _curAudioFileUrl;
    
    AVAudioRecorder* _avAudioRecorder;
    AVAudioPlayer* _avAudioPlayer;
}

@property (weak, nonatomic) IBOutlet UIButton *startRecordBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopRecordBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIButton *resetBtn;

@property (weak, nonatomic) IBOutlet UILabel *timeLbl;

@property (nonatomic, strong) AVAudioSession* audioSesstion;

@end

@implementation AudioTestVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setViewAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (void)setViewAction {
    _countDown = 0;
    
    self.startRecordBtn.enabled = YES;
    self.stopRecordBtn.enabled = NO;
    self.pauseBtn.enabled = NO;
    self.resetBtn.enabled = NO;
}

- (IBAction)startRecordBtnAction:(UIButton*)sender {
    self.startRecordBtn.enabled = NO;
    self.stopRecordBtn.enabled = YES;
    self.pauseBtn.enabled = YES;
    self.resetBtn.enabled = YES;
    
    // 开始录音
    [self requireRecordingPermission:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startRecording];
                
                [self startTimer];
            });
        }
    }];
}

- (IBAction)stopRecordBtnAction:(UIButton *)sender {
    self.startRecordBtn.enabled = YES;
    self.stopRecordBtn.enabled = NO;
    self.pauseBtn.enabled = NO;
    self.resetBtn.enabled = NO;
    
    [self stopTimer];
    
    [self stopRecording];
    
    _countDown = -1;
    [self refreshTimeLabel];
}

- (IBAction)pauseBtnAction:(UIButton*)sender {
    NSString* pauseBtnTitleStr = [self.pauseBtn titleForState:
                                  UIControlStateNormal];
    
    if ([pauseBtnTitleStr isEqualToString: @"Pause"]) {
        [self.pauseBtn setTitle: @"Restart" forState: UIControlStateNormal];
        
        [self stopTimer];
    } else {
        [self.pauseBtn setTitle: @"Pause" forState: UIControlStateNormal];
        
        [self startTimer];
    }
}

- (IBAction)resetBtnAction:(UIButton*)sender {
    // 先stop，再start
    [self stopRecordBtnAction: nil];
    [self startRecordBtnAction: nil];
    
    
}

#pragma mark - Logical Process
- (void)startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval: 1.0f
                                              target: self
                                            selector: @selector(refreshTimeLabel)
                                            userInfo: nil
                                             repeats: YES];
    
    [[NSRunLoop currentRunLoop] addTimer: _timer
                                 forMode: NSRunLoopCommonModes];
}
              
- (void)refreshTimeLabel {
    self.timeLbl.text = [NSString stringWithFormat: @"00:%02i", ++_countDown];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)requireRecordingPermission: (void(^) (BOOL))callback {
    AVAudioSession* audioSesstion = [AVAudioSession sharedInstance];
    
    if ([audioSesstion respondsToSelector: @selector(requestRecordPermission:)]) {
        
        [audioSesstion performSelector: @selector(requestRecordPermission:)
                            withObject: ^(BOOL granted) {
                                callback(granted);
                            }];
    }
}

- (void)startRecording {
    AVAudioSession* audioSesstion = [AVAudioSession sharedInstance];
    NSError* sessionError;
    
    [audioSesstion setCategory: AVAudioSessionCategoryPlayAndRecord
                         error: &sessionError];
    
    if (audioSesstion == nil) {
        UIAlertController* alertController = [UIAlertController
                                  alertControllerWithTitle: @"Error"
                                  message: sessionError.description
                                  preferredStyle: UIAlertControllerStyleAlert];
        
        [self presentViewController: alertController
                           animated: YES
                         completion: nil];
        
        return ;
    } else {
        [audioSesstion setActive: YES
                           error: nil];
    }
    
    self.audioSesstion = audioSesstion;
    _curAudioFilePath = [self generateAudioFilePath];
    _curAudioFileUrl = [NSURL fileURLWithPath: _curAudioFilePath];
    
    NSDictionary* recordSetting = @{
                                    AVSampleRateKey : @8000.0f,                 // 采样率
                                    AVFormatIDKey : @(kAudioFormatLinearPCM),   // 音频格式
                                    AVLinearPCMBitDepthKey : @16,               // 采样位数
                                    AVNumberOfChannelsKey : @1,                 // 音频通道
                                    AVEncoderAudioQualityKey : @(AVAudioQualityHigh)    // 录音质量
                                    };
    
    _avAudioRecorder = [[AVAudioRecorder alloc] initWithURL: _curAudioFileUrl
                                                   settings: recordSetting
                                                      error: nil];
    
    if (_avAudioRecorder) {
        _avAudioRecorder.meteringEnabled = YES;
        
        [_avAudioRecorder prepareToRecord];
        [_avAudioRecorder record];
    } else {
        UIAlertController* alertController = [UIAlertController
                                              alertControllerWithTitle: @"Error"
                                              message: @"Error init AVAudioRecorder"
                                              preferredStyle: UIAlertControllerStyleAlert];
        
        [self presentViewController: alertController
                           animated: YES
                         completion: nil];
    }
}

- (void)stopRecording {
    
    if ([_avAudioRecorder isRecording]) {
        [_avAudioRecorder stop];
    }
    
    DLOG(@"录制 %i 秒，文件大小为 %liKb", _countDown,
         [[FileManager manager] getFileSizeWithFilePath: _curAudioFilePath]);
}

- (NSString*)generateAudioFilePath {
    
    NSInteger timeStamp = [[NSNumber numberWithDouble:
                            [[NSDate date] timeIntervalSince1970]] integerValue];
    
    return [NSString stringWithFormat: @"%@/%li.wav", AUDIO_FOLDER_PATH, timeStamp];
}


- (IBAction)testBBIAction:(UIBarButtonItem *)sender {
    DLOG(@"%@", [self generateAudioFilePath]);
    
    // play the current audio
    if ([[FileManager manager] getFileSizeWithFilePath: _curAudioFilePath] > 0) {
        if ([_avAudioPlayer isPlaying]) {
            [_avAudioPlayer stop];
            
            return ;
        }
        
        _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: _curAudioFileUrl
                                                                error: nil];
        
        [self.audioSesstion setCategory: AVAudioSessionCategoryPlayback
                                  error: nil];
        
        [_avAudioPlayer play];
    }
}

@end
