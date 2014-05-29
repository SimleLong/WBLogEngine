//
//  WBLogManager.h
//  WBLogEginine
//
//  Created by Robin on 5/26/14.
//  Copyright (c) 2014 Robin. All rights reserved.
//

#import <Foundation/Foundation.h>

#if WB_ALLOW_FILE_LOG

#define FileLog(logStr) [[WBLogManager sharedStore] logWithString:logStr];
#define FileLogFormat(...) [[WBLogManager sharedStore] logWithFormat:__VA_ARGS__];

#else

#define FileLog(logStr)
#define FileLogFormat(...)

#endif

@protocol WBLogManagerCrashDelegate <NSObject>

@optional
- (void)extensionCrashLogDictionary:(NSMutableDictionary *)dic;
@end


@interface WBLogManager : NSObject

/*!
 *  custom crash extension dictionary
 */
@property (nonatomic, assign) id<WBLogManagerCrashDelegate> crashDelegate;

+ (instancetype)sharedInstance;
- (void)configureLogPath:(NSString *)path;


- (void)logWithString:(NSString*)str;
- (void)logWithFormat:(NSString*)str, ...;

- (BOOL)cacheDevLogData:(NSData *)logData;
- (BOOL)cacheUserLogData:(NSData *)logData;

@end
