//
//  WBLogFileAccess.h
//  WBLogEngine
//
//  Created by kevin on 14-5-29.
//  Copyright (c) 2014年 Robin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBLogFileAccess : NSObject

@property (nonatomic, retain) NSString *accountID;
@property (nonatomic, retain, readonly) NSData *devLogsData;
@property (nonatomic, retain, readonly) NSData *userLogsData;

//write log data
- (BOOL)cacheDevLogData:(NSData *)logData;
- (BOOL)cacheUserLogData:(NSData *)logData;

@end
