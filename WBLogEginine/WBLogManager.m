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

@interface WBLogManager()<WBCrashLogDelegate>
@property (nonatomic, strong)WBRecordFileLog *fileLogRecord;

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
