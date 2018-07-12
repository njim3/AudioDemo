//
//  FileManager.m
//  eshop-sb
//
//  Created by njim3 on 2/4/16.
//  Copyright © 2016 njim3. All rights reserved.
//

#import "FileManager.h"

@interface FileManager ()

@property (nonatomic, weak) NSFileManager* fileManager;

@end

@implementation FileManager

+ (FileManager*)manager {
    
    static FileManager* fManager = nil;
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        fManager = [[FileManager alloc] init];
    });
    
    return fManager;
}

- (NSFileManager*)fileManager {
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    
    return _fileManager;
}

- (BOOL)createAudiosFolder {
    
    NSError* error;
    BOOL res = YES;
    
    DLOG(@"Document Path:\n%@", DOCUMENT_PATH);
    
    res = [self.fileManager createDirectoryAtPath: AUDIO_FOLDER_PATH
                      withIntermediateDirectories: YES
                                       attributes: nil
                                            error: &error];
    
    if (!res || error) {
        
        DLOG(@"Error creating %@ folder!!", AUDIO_FOLDER_PATH);
        
        return NO;
    }
    
    return YES;
}

+ (NSString*)getFilePathWithPathComponent: (NSString*)pathComponent {
    return [DOCUMENT_PATH stringByAppendingPathComponent:
            pathComponent];
}

- (NSInteger)getFileSizeWithFilePath: (NSString*)filePath {
    if ([self.fileManager fileExistsAtPath: filePath]) {
        long long fileSize = [self.fileManager attributesOfItemAtPath: filePath
                                                                error: nil].fileSize;
        
        return fileSize / 1024.0f;
        
    }
    
    return 0.0f;
}

- (void)deleteFileWithPath: (NSString*)filePath {
    if (![self.fileManager fileExistsAtPath: filePath]) {
        DLOG(@"File not exists! %@", filePath);
        
        return ;
    }
    
    NSError* error;
    
    [self.fileManager removeItemAtPath: filePath
                                 error: &error];
    
    if (error) {
        DLOG(@"Error delete file: %@, error: %@",
             filePath, error.description);
    }
}

- (BOOL)isFileExistsAtPath: (NSString*)filePath {
    return [self.fileManager fileExistsAtPath: filePath];
}

- (NSMutableArray*)getAllSubFilePathFromDirectory: (NSString*)dirPath {
    BOOL isDir = NO;
    BOOL isExists = [self.fileManager fileExistsAtPath: dirPath
                                           isDirectory: &isDir];
    
    if (!isExists || !isDir) {
        return nil;
    }
    
    NSMutableArray* allSubFilePathMutArr = [NSMutableArray array];
    
    NSArray* subPathArr = [self.fileManager contentsOfDirectoryAtPath: dirPath
                                                                error: nil];
    
    for (NSString* str in subPathArr) {
        NSString* subPath = [dirPath stringByAppendingPathComponent: str];
        
        BOOL isSubPathDir = NO;
        
        [self.fileManager fileExistsAtPath: subPath
                               isDirectory: &isSubPathDir];
        
        if (!isSubPathDir) {
            [allSubFilePathMutArr addObject: subPath];
        }
    }
    
    return allSubFilePathMutArr;
}


@end
