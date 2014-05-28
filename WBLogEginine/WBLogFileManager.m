//
//  WBLogFileManager.m
//  Weibo
//
//  Created by anyuan on 14-5-27.
//  Copyright (c) 2014年 Sina. All rights reserved.
//

#import "WBLogFileManager.h"

@interface WBLogFileManager()
@property (nonatomic, assign) dispatch_queue_t io_queue;
@property (nonatomic, retain) NSString *userLogsCacheFilePath;
@property (nonatomic, retain) NSString *devLogsCacheFilePath;
@property (nonatomic, retain) NSString *logCacheDir;

@property (nonatomic, retain, readwrite) NSData *devLogsData;
@property (nonatomic, retain, readwrite) NSData *userLogsData;
@end

@implementation WBLogFileManager

#pragma public methods
+ (id)sharedManager
{
    static dispatch_once_t onceQueue;
    static WBLogFileManager *sharedManager = nil;
    
    dispatch_once(&onceQueue, ^{
        sharedManager = [[self alloc] init];
        sharedManager.io_queue = dispatch_queue_create("logfile_io_queue", 0);
        [sharedManager buildFolderPath:sharedManager.logCacheDir error:nil];
    });
    
    return sharedManager;
}

- (BOOL)cacheDevLogData:(NSData *)logData
{
    return [self cacheLogData:logData path:[self devLogsCacheFilePath]];
}

- (BOOL)cacheUserLogData:(NSData *)logData
{
    return [self cacheLogData:logData path:[self userLogsCacheFilePath]];
}

- (NSData *)devLogsData
{
    _devLogsData = [NSData dataWithContentsOfFile:[self devLogsCacheFilePath]];
    return _devLogsData;
}

- (NSData *)userLogsData
{
    _userLogsData = [NSData dataWithContentsOfFile:[self userLogsCacheFilePath]];
    return _userLogsData;
}

#pragma private methods
- (BOOL)buildFolderPath:(NSString *)path error:(NSError **)error
{
    BOOL isDirectory = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exists = [fm fileExistsAtPath:path isDirectory:&isDirectory];
    if (exists)
    {
        if (!isDirectory)
        {
            [fm removeItemAtPath:path error:NULL];
            return [fm createDirectoryAtPath:path
                 withIntermediateDirectories:NO
                                  attributes:nil
                                       error:error];
        }
        else
        {
            return YES;
        }
    }
    else
    {
        NSString *parent = [path stringByDeletingLastPathComponent];
        if ([self buildFolderPath:parent error:error])
        {
            return [fm createDirectoryAtPath:path
                          withIntermediateDirectories:NO
                                           attributes:nil
                                                error:error];
        }
    }
    return NO;
}

- (BOOL)cacheLogData:(NSData *)logData
                path:(NSString *)path
{
    __block BOOL succ = NO;
    dispatch_sync(self.io_queue, ^{
        succ = [logData writeToFile:path atomically:YES];
    });
    return succ;
}

#pragma mark - Getter Methods
- (NSString *)logCacheDir
{
    if (!_logCacheDir) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheFolder = [paths objectAtIndex:0];
        _logCacheDir = [[cacheFolder stringByAppendingPathComponent:@"action_logs"] retain];
    }
    return _logCacheDir;
}

- (NSString *)userLogsCacheFilePath
{
    if (!_userLogsCacheFilePath) {
        NSString *fileName = [NSString stringWithFormat:@"%@.0.dat", _accountID];
        _userLogsCacheFilePath = [[_logCacheDir stringByAppendingPathComponent:fileName] retain];
    }
    return _userLogsCacheFilePath;
}

- (NSString *)devLogsCacheFilePath
{
    if (!_devLogsCacheFilePath) {
        NSString *fileName = [NSString stringWithFormat:@"%@.1.dat", _accountID];
        _devLogsCacheFilePath = [[_logCacheDir stringByAppendingPathComponent:fileName] retain];
    }
    return _devLogsCacheFilePath;
}

#pragma mark - life cycle method
- (void)dealloc
{
    [_userLogsCacheFilePath release], _userLogsCacheFilePath = nil;
    [_devLogsCacheFilePath release], _devLogsCacheFilePath = nil;
    [_logCacheDir release], _logCacheDir = nil;
    [_accountID release], _accountID = nil;
    dispatch_release(_io_queue), _io_queue = nil;
    
    [super dealloc];
    
}
@end
