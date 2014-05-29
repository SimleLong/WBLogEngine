//
//  WBRecordCrashLog.m
//  WBLogEginine
//
//  Created by Robin on 5/22/14.
//  Copyright (c) 2014 Robin. All rights reserved.
//

#import "WBRecordCrashLog.h"
#import <signal.h>
#import "WBRecordCrashTools.h"
#import <execinfo.h>
#import "NSMutableDictionary+WBLogSetValue.h"

#define kWBrashTypeKey                      "type"
#define kWBrashSubtypeKey                   "subtype"
#define kWBrashTypeValue_Signal                      "signal"
#define kWBrashTypeValue_Exception                   "exception"

#define WBRSET_CRASH_SUBTYPE_NAME(a,b)    case a: b = [NSString stringWithUTF8String:#a];break;

@implementation WBRecordCrashLog

#pragma mark objetc lifecycle
-(id) init
{
    self = [super init];
    if (self)
    {
        _isOpenCrashLog = YES;
    }
    return self;
}
- (void)dealloc
{
    [self unregisterHandler];
    [super dealloc];
}

#pragma mark end ---


#pragma mark WBRecord Public Method

+ (instancetype)shareInstance
{
    static WBRecordCrashLog * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)registerHandler
{
    [self p_registerCrashHandler];
    [self p_registerUncaughtHandler];
}
- (void)unregisterHandler
{
    [self p_unregisterCrashHandler];
    [self p_unregisterUncaughtHandler];
}

- (void)clearCrashLog
{
    
}

#pragma mark end ---

#pragma mark WBRecord Private Method

- (void)p_registerCrashHandler
{
    signal(SIGABRT, signalHandler);
    signal(SIGBUS, signalHandler);
    signal(SIGFPE, signalHandler);
    signal(SIGILL, signalHandler);
    signal(SIGPIPE, signalHandler);
    signal(SIGSEGV, signalHandler);
}
- (void)p_unregisterCrashHandler
{
    signal(SIGABRT, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
}

- (void)p_registerUncaughtHandler
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

- (void)p_unregisterUncaughtHandler
{
     NSSetUncaughtExceptionHandler(nil);
}

- (NSMutableString *)p_appendPreviousRecord
{
    
    NSMutableString *mutableString = [NSMutableString string];
    if ([[NSFileManager defaultManager] fileExistsAtPath:kWBRecordCrashFile])
    {
        NSString *content = [NSString stringWithContentsOfFile:kWBRecordCrashFile encoding:NSUTF8StringEncoding error:nil];
        [mutableString appendFormat:@"%@,", content];
    }
    
    return mutableString;
}

- (NSString *)p_serializeMessage:(id)message
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:0 error:nil] encoding:NSUTF8StringEncoding];
}

- (void)p_updateBacktraceToDictionary:(NSMutableDictionary *)dic fromSigalCode:(int)signalcode
{
    [dic setLogSafeObject:@kWBrashTypeValue_Signal forKey:@kWBrashTypeKey];
    
    NSString *subtype = nil;
    switch (signalcode)
    {
            WBRSET_CRASH_SUBTYPE_NAME(SIGABRT, subtype);
            WBRSET_CRASH_SUBTYPE_NAME(SIGBUS, subtype);
            WBRSET_CRASH_SUBTYPE_NAME(SIGFPE, subtype);
            WBRSET_CRASH_SUBTYPE_NAME(SIGILL, subtype);
            WBRSET_CRASH_SUBTYPE_NAME(SIGPIPE, subtype);
            WBRSET_CRASH_SUBTYPE_NAME(SIGSEGV, subtype);
        default:
            break;
    }
    [dic setLogSafeObject:subtype forKey:@kWBrashSubtypeKey];
    NSInteger crashedThread = w_mach_crashedThreadIndex();
    
    void* callstack[128];
    const int numFrames = backtrace(callstack, 128);
    char **symbols = backtrace_symbols(callstack, numFrames);
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:numFrames];
    for (int i = 0; i < numFrames; ++i)
    {
        [arr addObject:[NSString stringWithUTF8String:symbols[i]]];
    }
    
    free(symbols);
    
    NSMutableString *content =[[NSMutableString alloc] init];
    [content appendString:[NSString stringWithFormat:@"Crashed thread 0x%08d#",crashedThread]];
    for (int i = 0; i < [arr count]; i ++)
    {
        [content appendString:[NSString stringWithFormat:@"%@#",[arr objectAtIndex:i]]];
    }
    
    if (self.crashLogDelegate) {
        if ([self.crashLogDelegate respondsToSelector:@selector(extensionCrashLogDictionary:)]) {
            [self.crashLogDelegate extensionCrashLogDictionary:dic];
        }
    }
    [dic setLogSafeObject:content forKey:@"content"];
    
    [content release];

}

- (void)p_updateBacktraceToDictionary:(NSMutableDictionary *)dic fromException:(NSException*)exception
{
    [dic setLogSafeObject:@kWBrashTypeValue_Signal forKey:@kWBrashTypeKey];
    [dic setLogSafeObject:[exception name] forKey:@kWBrashSubtypeKey];
    
    NSInteger crashedThread = w_mach_crashedThreadIndex();
    
    NSMutableString *content =[[NSMutableString alloc] init];
    NSArray *adresses = [exception callStackSymbols];
    
    [content appendString:[NSString stringWithFormat:@"Crashed thread 0x%08d#",crashedThread]];
    [content appendString:[NSString stringWithFormat:@"Crashed reason: %@#",[exception reason]]];
    for (int i = 0; i < [adresses count]; i ++)
    {
        [content appendString:[NSString stringWithFormat:@"%@#",[adresses objectAtIndex:i]]];
    }
    
    if (self.crashLogDelegate) {
        if ([self.crashLogDelegate respondsToSelector:@selector(extensionCrashLogDictionary:)]) {
            [self.crashLogDelegate extensionCrashLogDictionary:dic];
        }
    }
    
    [dic setLogSafeObject:content forKey:@"content"];
    [content release];

}

#pragma mark end ---

#pragma mark c method implement for signal handler

void signalHandler(int signalcode)
{
    [[WBRecordCrashLog shareInstance] p_unregisterCrashHandler];
    
    if (![[WBRecordCrashLog shareInstance]isOpenCrashLog]) {
        return;
    }
    
    NSMutableDictionary *crashLogs = [NSMutableDictionary  dictionary];
    NSMutableString *crashlog = [[WBRecordCrashLog shareInstance]p_appendPreviousRecord];
    [[WBRecordCrashLog shareInstance]p_updateBacktraceToDictionary:crashLogs fromSigalCode:signalcode];
    NSString *crashContent =  [[WBRecordCrashLog shareInstance]p_serializeMessage:crashLogs];
    [crashlog appendString:[NSString stringWithFormat:@"%@",crashContent]];
    [crashlog writeToFile:kWBRecordCrashFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

void uncaughtExceptionHandler(NSException *exception)
{
    [[WBRecordCrashLog shareInstance] p_unregisterCrashHandler];
    
    NSMutableDictionary *crashLogs = [NSMutableDictionary  dictionary];
    NSMutableString *crashlog = [[WBRecordCrashLog shareInstance]p_appendPreviousRecord];
    [[WBRecordCrashLog shareInstance]p_updateBacktraceToDictionary:crashLogs fromException:exception];
    NSString *crashContent =  [[WBRecordCrashLog shareInstance]p_serializeMessage:crashLogs];
    [crashlog appendString:[NSString stringWithFormat:@"%@",crashContent]];
    [crashlog writeToFile:kWBRecordCrashFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

#pragma mark end ---


@end
