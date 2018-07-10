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
}

@property (nonatomic, strong) CAShapeLayer* shapeLayer;
@property (weak, nonatomic) IBOutlet UIView *speakerView;


@end

@implementation AudioTestVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setViewAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Layout


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
            
            
            
            
        } else {
            // alert
            
            
        }
        
        
    }];
    
}

- (IBAction)resetBtnAction:(UIButton *)sender {
    
    
    
    
    
    
    
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
                    startAngle:  endAngle:<#(CGFloat)#> clockwise:<#(BOOL)#>]
    }
}


@end
