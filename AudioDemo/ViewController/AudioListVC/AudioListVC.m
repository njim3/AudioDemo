//
//  AudioListVC.m
//  AudioDemo
//
//  Created by njim3 on 01/02/2018.
//  Copyright © 2018 cnbmsmart. All rights reserved.
//

#import "AudioListVC.h"
#import "NSDate+Formatter.h"
#import "PlayAudioVC.h"

@interface AudioListVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray* audioMutArr;

@end

@implementation AudioListVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setViewAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController* destVC = segue.destinationViewController;
    
    if ([destVC isKindOfClass: [PlayAudioVC class]]) {
        PlayAudioVC* playAudioVC = (PlayAudioVC*)destVC;
        
        playAudioVC.filePath = (NSString*)sender;
    }
}

#pragma mark - View Action
- (void)setViewAction {
    [self getAudioListFromFolder];
    
    [self.tableView reloadData];
}

- (IBAction)refreshAudioBBIAction:(UIBarButtonItem *)sender {
    [self getAudioListFromFolder];
    
    [self.tableView reloadData];
}

- (void)deleteWavAudioAtIndexPath: (NSIndexPath*)indexPath {
    NSString* wavFilePath = self.audioMutArr[indexPath.row];
    
    [[FileManager manager] deleteFileWithPath: wavFilePath];
    
    [self.audioMutArr removeObjectAtIndex: indexPath.row];
    
    [self.tableView deleteRowsAtIndexPaths: @[indexPath]
                          withRowAnimation: UITableViewRowAnimationAutomatic];
}

#pragma mark - Logical Process
- (void)getAudioListFromFolder {
    NSMutableArray* allSubFilePath = [[FileManager manager]
                                      getAllSubFilePathFromDirectory:
                                      AUDIO_FOLDER_PATH];
    
    NSArray* sortedAllFilePath = [allSubFilePath sortedArrayUsingComparator:
                                  ^NSComparisonResult(id obj1, id obj2) {
        NSInteger timeStampObj1 = [[[obj1 lastPathComponent]
                                    stringByDeletingPathExtension]
                                   integerValue];
        NSInteger timeStampObj2 = [[[obj2 lastPathComponent]
                                    stringByDeletingPathExtension]
                                   integerValue];
        
        return timeStampObj1 > timeStampObj2 ?
        NSOrderedAscending : NSOrderedDescending;
    }];
    
    [self.audioMutArr removeAllObjects];
    [self.audioMutArr addObjectsFromArray: sortedAllFilePath];
}

- (NSString*)getDateStrFromWavFilePath: (NSString*)wavFilePath {
    NSInteger wavTimeStamp = [[[wavFilePath lastPathComponent]
                               stringByDeletingPathExtension] integerValue];
    
    NSDate* wavDate = [NSDate dateWithTimeIntervalSince1970: wavTimeStamp];
    
    return [wavDate date2String];
}

#pragma mark - UITableView delegate & datasource methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.audioMutArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return HEIGHT_AUDIOLIST_TV;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:
                             CELLIDENTIFIER_AUDIOLISTVC];
    
    NSString* wavFilePath = self.audioMutArr[indexPath.row];
    NSString* dateStr = [self getDateStrFromWavFilePath: wavFilePath];
    
    cell.textLabel.text = [wavFilePath lastPathComponent];
    cell.detailTextLabel.text = dateStr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    NSString* wavFilePath = self.audioMutArr[indexPath.row];
    
    [self performSegueWithIdentifier: SEGUE_AUDIOLIST2PLAYAUDIO
                              sender: wavFilePath];
}


- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString*)tableView:(UITableView *)tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Delete";
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 删除该项
    [self deleteWavAudioAtIndexPath: indexPath];
}


#pragma mark - Variables getter & setter
- (NSMutableArray*)audioMutArr {
    if (!_audioMutArr) {
        _audioMutArr = [NSMutableArray array];
    }
    
    return _audioMutArr;
}

@end
