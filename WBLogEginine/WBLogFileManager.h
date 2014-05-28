//
//  WBLogFileManager.h
//  Weibo
//
//  Created by anyuan on 14-5-27.
//  Copyright (c) 2014年 Sina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBLogFileManager : NSObject

@property (nonatomic, retain) NSString *accountID;
@property (nonatomic, retain, readonly) NSData *devLogsData;
@property (nonatomic, retain, readonly) NSData *userLogsData;

+ (id)sharedManager;

//write log data
- (BOOL)cacheDevLogData:(NSData *)logData;
- (BOOL)cacheUserLogData:(NSData *)logData;

@end
