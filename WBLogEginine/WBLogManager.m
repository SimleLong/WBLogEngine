//
//  WBLogManager.m
//  WBLogEginine
//
//  Created by Robin on 5/26/14.
//  Copyright (c) 2014 Robin. All rights reserved.
//

#import "WBLogManager.h"
#import "WBRecordFileLog.h"
#import "WBRecordCrashLog.h"
#import "WBLogFileAccess.h"

@interface WBLogManager()<WBCrashLogDelegate>
@property (nonatomic, strong)WBRecordFileLog *fileLogRecord;
@property (nonatomic, strong)WBLogFileAccess *LogfileAccess;

@end
@implementation WBLogManager
{
    NSString *_logPath;
}
+ (instancetype)sharedInstance
{
    static WBLogManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        [[WBRecordCrashLog shareInstance]registerHandler];
        WBRecordFileLog *fileLog = [[[WBRecordFileLog alloc]init]autorelease];
        self.fileLogRecord = fileLog;
        
        self.LogfileAccess = [[[WBLogFileAccess alloc] init] autorelease];
        
        _logPath = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    }
    return self;
}

- (void)dealloc
{
    
    if (_fileLogRecord) {
        [_fileLogRecord release];
        _fileLogRecord = nil;
    }
    
    if (_logPath) {
        [_logPath release];
        _logPath = nil;
    }
    
    if (_LogfileAccess) {
        [_LogfileAccess release];
        _LogfileAccess = nil;
    }
    
    [super dealloc];
}


- (void)logWithString:(NSString*)str{
    [self.fileLogRecord logWithString:str];
}

- (void)logWithFormat:(NSString*)str, ...
{
    if (!str || ![str isKindOfClass:NSString.class])
        return;
    
    va_list objects;
	va_start(objects, str);
    
    NSString* str1 = [[[NSString alloc] initWithFormat:str arguments:objects] autorelease];
    
    [self.fileLogRecord logWithString:str1];
}

- (BOOL)cacheDevLogData:(NSData *)logData
{
    return [self.LogfileAccess cacheDevLogData:logData];
}

- (BOOL)cacheUserLogData:(NSData *)logData
{
    return [self.LogfileAccess cacheUserLogData:logData];
}

- (void)configureLogPath:(NSString *)path
{
    
}

- (void)extensionCrashLogDictionary:(NSMutableDictionary *)dic
{
    if (self.crashDelegate) {
        if ([self.crashDelegate respondsToSelector:@selector(extensionCrashLogDictionary:)]) {
            [self.crashDelegate extensionCrashLogDictionary:dic];
        }
    }
}

@end
