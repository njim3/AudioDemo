//
//  AudioTestVC.m
//  AudioDemo
//
//  Created by njim3 on 2018/7/10.
//  Copyright © 2018 cnbmsmart. All rights reserved.
//

#import "AudioTestVC.h"
#import <AVFoundation/AVFoundation.h>
#import <VoiceConverter.h>

@interface AudioTestVC () {
    BOOL _isStartRecord;
    
    int _countDown;
    
    NSTimer* _refreshLblTimer;
    NSTimer* _strokeTimer;
    
    NSString* _curWavFilePath;
    NSString* _curAmrFilePath;
    
    NSURL* _curWavFileUrl;
    AVAudioRecorder* _avAudioRecorder;
    AVAudioPlayer* _avAudioPlayer;
}

@property (nonatomic, strong) CAShapeLayer* shapeLayer;
@property (weak, nonatomic) IBOutlet UIView *speakerView;

@property (weak, nonatomic) IBOutlet UILabel *countDownLbl;

@property (weak, nonatomic) IBOutlet UIButton *startRecordBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopRecordBtn;

@property (nonatomic, strong) UIAlertController* record60secAlert;

@property (nonatomic, strong) AVAudioSession* audioSession;

@end

@implementation AudioTestVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutViews];
    [self setViewAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Layout
- (void)layoutViews {
    [self.speakerView.layer addSublayer: self.shapeLayer];
}


#pragma mark - View Action
- (void)setViewAction {
    _isStartRecord = NO;
    _countDown = 0;
}

- (IBAction)startRecordBtnAction:(UIButton *)sender {
    [self requestRecordingPermission:^(BOOL granted) {
        if (granted) {
            // begin recording
            if (_isStartRecord)
                return ;
            
            // 重置
            [self resetBtnAction: nil];
            
            _isStartRecord = YES;
            
            [self startRecording];
            [self startTimer];
            
        } else {
            // alert
            UIAlertController* alertController = [UIAlertController
                                                  alertControllerWithTitle: @"无权限"
                                                  message: @"请在设置中打开权限"
                                                  preferredStyle: UIAlertControllerStyleAlert];
            
            UIAlertAction* alertAction = [UIAlertAction actionWithTitle: @"确定"
                                                                  style: UIAlertActionStyleDefault
                                                                handler: nil];
            
            [alertController addAction: alertAction];
            
            [self presentViewController: alertController
                               animated: YES
                             completion: nil];
        }
    }];
}

- (IBAction)stopRecordBtnAction:(UIButton *)sender {
    [self stopTimer];
    [self saveRecording];
    
    _isStartRecord = NO;
}


- (IBAction)resetBtnAction:(UIButton *)sender {
    [self stopTimer];
    [self stopRecording];
    
    self.shapeLayer.strokeEnd = 0;
    
    _countDown = -1;
    [self refreshTimeLbl];
    
    _isStartRecord = NO;
    
    if ([_avAudioPlayer isPlaying])
        [_avAudioPlayer stop];
    
    // 删除文件，如果直接点击按钮则删除，传入为nil则为清除配置
    if (sender)
        [[FileManager manager] deleteFileWithPath: _curWavFilePath];
}

- (IBAction)pauseBtnAction:(UIButton *)sender {
    NSString* btnTitleStr = [sender titleForState: UIControlStateNormal];
    
    if ([btnTitleStr isEqualToString: @"Pause"]) {
        [sender setTitle: @"Continue"
                forState: UIControlStateNormal];
        
        [self pauseRecording];
    } else {
        [sender setTitle: @"Pause"
                forState: UIControlStateNormal];
        
        [self continueRecording];
    }
}

- (IBAction)playBBIAction:(UIBarButtonItem *)sender {
    if (_avAudioPlayer && _avAudioPlayer.isPlaying) {
        [_avAudioPlayer stop];
        
        return ;
    }
    
    if ([_avAudioRecorder isRecording])
        return ;
    
    if ([[FileManager manager] isFileExistsAtPath: _curWavFilePath]) {
        _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
                          [NSURL fileURLWithPath: _curWavFilePath]
                                                                error: nil];
        
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback
                                               error: nil];
        
        [_avAudioPlayer play];
    }
}


- (void)refreshTimeLbl {
    self.countDownLbl.text = [NSString stringWithFormat: @"00:%02i",
                              ++_countDown];
    
    if (_countDown == 60) {
        // 停止
        [self stopRecordBtnAction: self.stopRecordBtn];
        
        // 展示录制完的alert
        [self presentViewController: self.record60secAlert
                           animated: YES
                         completion: nil];
    }
}

- (void)strokeCircle {
    self.shapeLayer.strokeEnd += (0.05f / 60);
}

#pragma mark - Logical Process
- (void)requestRecordingPermission: (void(^) (BOOL))callback {
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    
    if ([audioSession respondsToSelector: @selector(requestRecordPermission:)]) {
        [audioSession performSelector: @selector(requestRecordPermission:)
                           withObject: ^(BOOL granted) {
                               callback(granted);
                           }];
    }
}

- (void)startRecording {
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    NSError* error;
    
    [audioSession setCategory: AVAudioSessionCategoryPlayAndRecord
                        error: &error];
    
    if (audioSession == nil) {
        UIAlertController* alertController = [UIAlertController
                                              alertControllerWithTitle: @"Error"
                                              message: error.description
                                              preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"确定"
                                                           style: UIAlertActionStyleDefault
                                                         handler: nil];
        
        [alertController addAction: okAction];
        
        [self presentViewController: alertController animated: YES
                         completion: nil];
        
        return ;
    }
    
    [audioSession setActive: YES
                      error: nil];
    
    self.audioSession = audioSession;
    
    NSDate* nowDate = [NSDate date];
    
    _curWavFilePath = [self generateAudioFilePathWithDate: nowDate
                                                   andExt: @"wav"];
    _curAmrFilePath = [self generateAudioFilePathWithDate: nowDate
                                                   andExt: @"amr"];
    
    _curWavFileUrl = [NSURL fileURLWithPath: _curWavFilePath];
    
    NSDictionary* recordSettings = @{
             AVSampleRateKey: @8000.0f,                         // 采样率
             AVFormatIDKey: @(kAudioFormatLinearPCM),           // 音频格式
             AVLinearPCMBitDepthKey: @16,                       // 采样位数
             AVNumberOfChannelsKey: @1,                         // 音频通道
             AVEncoderAudioQualityKey: @(AVAudioQualityHigh)    // 录音质量
             };
    
    _avAudioRecorder = [[AVAudioRecorder alloc] initWithURL: _curWavFileUrl
                                                   settings: recordSettings
                                                      error: nil];
    
    if (!_avAudioRecorder) {
        UIAlertController* alertController = [UIAlertController
                                              alertControllerWithTitle: @"Error"
                                              message: @"Error init AVAudioRecorder"
                                              preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"OK"
                                                           style: UIAlertActionStyleDefault
                                                         handler: nil];
        
        [alertController addAction: okAction];
        
        [self presentViewController: alertController
                           animated: YES
                         completion: nil];
        
        return ;
    }
    
    _avAudioRecorder.meteringEnabled = YES;
    [_avAudioRecorder prepareToRecord];
    [_avAudioRecorder record];
}

- (void)startTimer {
    _refreshLblTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0f
                                                        target: self
                                                      selector: @selector(refreshTimeLbl)
                                                      userInfo: nil
                                                       repeats: YES];
    
    _strokeTimer = [NSTimer scheduledTimerWithTimeInterval: 0.05f
                                                    target: self
                                                  selector: @selector(strokeCircle)
                                                  userInfo: nil
                                                   repeats: YES];
    
    [[NSRunLoop currentRunLoop] addTimer: _refreshLblTimer
                                 forMode: NSRunLoopCommonModes];
    
    [[NSRunLoop currentRunLoop] addTimer: _strokeTimer
                                 forMode: NSRunLoopCommonModes];
}

- (void)saveRecording {
    if ([_avAudioRecorder isRecording]) {
        [_avAudioRecorder stop];
    }
    
    DLOG(@"录制 %i 秒，文件大小为 %liKb", _countDown,
         [[FileManager manager] getFileSizeWithFilePath: _curWavFilePath]);
    
    // 可以在这里转换为amr文件
}

- (void)stopRecording {
    [self saveRecording];
}

- (void)pauseRecording {
    if ([_avAudioRecorder isRecording]) {
        [_avAudioRecorder pause];
    }
    
    [self stopTimer];
}

- (void)continueRecording {
    [_avAudioRecorder record];
    
    [self startTimer];
}

- (void)stopTimer {
    [_refreshLblTimer invalidate];
    [_strokeTimer invalidate];
    
    _refreshLblTimer = nil;
    _strokeTimer = nil;
}

- (NSString*)generateAudioFilePathWithDate: (NSDate*)date
                                    andExt: (NSString*)ext {
    NSInteger timeStamp = [[NSNumber numberWithDouble:
                            [date timeIntervalSince1970]] integerValue];
    
    return [NSString stringWithFormat: @"%@/%li.%@", AUDIO_FOLDER_PATH,
            timeStamp, ext];
}

#pragma mark - Variables getter & setter
- (CAShapeLayer*)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [[CAShapeLayer alloc] init];
        
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.lineWidth = 3.0f;
        _shapeLayer.strokeColor = [UIColor orangeColor].CGColor;
        
        UIBezierPath* path = [[UIBezierPath alloc] init];
        
        [path moveToPoint: CGPointMake(self.speakerView.width / 2, 0)];
        [path addArcWithCenter: CGPointMake(self.speakerView.width / 2,
                                            self.speakerView.height / 2)
                        radius: self.speakerView.width / 2
                    startAngle: - M_PI / 2
                      endAngle: 3 * M_PI / 2
                     clockwise: YES];
        
        _shapeLayer.path = path.CGPath;
        
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd = 0;
    }
    
    return _shapeLayer;
}

- (UIAlertController*)record60secAlert {
    if (!_record60secAlert) {
        _record60secAlert = [UIAlertController alertControllerWithTitle: @"提示"
                                                                message: @"您已录制60s，再次录制请点击开始"
                                                         preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"确定"
                                                           style: UIAlertActionStyleDefault
                                                         handler: nil];
        
        [_record60secAlert addAction: okAction];
    }
    
    return _record60secAlert;
}


@end
