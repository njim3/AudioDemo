//
//  FileManager.h
//  eshop-sb
//
//  Created by njim3 on 2/4/16.
//  Copyright © 2016 njim3. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (FileManager*)manager;

+ (NSString*)getFilePathWithPathComponent: (NSString*)pathComponent;

- (NSInteger)getFileSizeWithFilePath: (NSString*)filePath;

- (BOOL)createAudiosFolder;

- (void)deleteFileWithPath: (NSString*)filePath;

- (BOOL)isFileExistsAtPath: (NSString*)filePath;

- (NSMutableArray*)getAllSubFilePathFromDirectory: (NSString*)dirPath;

@end
