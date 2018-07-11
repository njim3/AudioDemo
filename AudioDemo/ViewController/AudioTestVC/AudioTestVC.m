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
}

@property (nonatomic, strong) CAShapeLayer* shapeLayer;
@property (weak, nonatomic) IBOutlet UIView *speakerView;

@property (weak, nonatomic) IBOutlet UILabel *countDownLbl;

@property (weak, nonatomic) IBOutlet UIButton *startRecordBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopRecordBtn;

@property (nonatomic, strong) UIAlertController* record60secAlert;


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
            
            _isStartRecord = YES;
            
            [self startRecording];
            [self startTimer];
            
            
            
        } else {
            // alert
            
            
        }
        
        
    }];
    
}

- (IBAction)stopRecordBtnAction:(UIButton *)sender {
    
    
    
    
}


- (IBAction)resetBtnAction:(UIButton *)sender {
    
    
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
