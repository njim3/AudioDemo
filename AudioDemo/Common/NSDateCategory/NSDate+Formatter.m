//
//  NSDate+Formatter.m
//  AudioDemo
//
//  Created by njim3 on 2018/7/12.
//  Copyright © 2018 cnbmsmart. All rights reserved.
//

#import "NSDate+Formatter.h"

@implementation NSDate (Formatter)

- (NSString*)date2String {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *currentDateString = [dateFormatter stringFromDate: self];
    
    return currentDateString;
}

@end
