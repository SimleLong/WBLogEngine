//
//  WBRecordCrashLog.h
//  WBLogEginine
//
//  Created by Robin on 5/22/14.
//  Copyright (c) 2014 Robin. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef kWBRecordSystermContinuouWBrash
#define kWBRecordSystermContinuouWBrash "ContinuouslyCrash"
#endif


//fuck sina weibo history reason named ,latetime means  lasttime
#ifndef kWBRecordSystermLastTime
#define kWBRecordSystermLastTime "lateTime"
#endif

#ifndef kWBRecordCrashFile
#define kWBRecordCrashFile [NSString stringWithFormat:@"%@/Documents/crashlog.txt", NSHomeDirectory()]
#endif


@protocol WBCrashLogDelegate <NSObject>

@optional
- (void)extensionCrashLogDictionary:(NSMutableDictionary *)dic;
@end


@interface WBRecordCrashLog : NSObject

/*!
 *  custom crash extension dictionary
 */
@property (nonatomic, assign) id<WBCrashLogDelegate> crashLogDelegate;
/*!
 *  turn on/off crash log ,default is Yes;
 */
@property (nonatomic, assign) BOOL isOpenCrashLog;

/*!
 *  singleton class method;
 *
 *  @return self instancetype;
 */
+ (instancetype)shareInstance;

/*!
 *  register crash handler;
 */
- (void)registerHandler;

/*!
 *  remove crash handler;
 */
- (void)unregisterHandler;

/*!
 *  clear Crash Log
 */
- (void)clearCrashLog;

@end
