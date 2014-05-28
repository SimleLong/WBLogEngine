//
//  WBRecordFileLog.m
//  WBLogEngine
//
//  Created by Robin on 5/27/14.
//  Copyright (c) 2014 Robin. All rights reserved.
//

#import "WBRecordFileLog.h"
#include <sys/stat.h>

#define kLogFormat @"%d-%d-%d %d:%d:%d %@\n"
@interface WBRecordFileLog()
@property (nonatomic, strong)NSFileManager* fileManager;
@property (nonatomic, strong)NSFileHandle * fileHandler;
@end
@implementation WBRecordFileLog

- (id)init
{
    if (self = [super init])
    {
        _fileManager = [NSFileManager defaultManager];
        self.fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:[self logFullPath]];
    }
    return self;
}

- (void)dealloc
{
    [_fileHandler closeFile];
    [_fileHandler release], _fileHandler = nil;
    
    [super dealloc];
}


- (NSString*)logFullPath
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] == 0)
        return nil;
	
    NSString* cachesPath = [paths objectAtIndex:0];
    if ([cachesPath length] == 0)
        return nil;
    
    NSMutableString* result = [NSMutableString stringWithString:cachesPath];
    
    if (![[result substringWithRange:NSMakeRange([result length] - 1, 1)] isEqualToString:@"/"])
    {
        [result appendString:@"/"];
    }
    [result appendString:@"fileLog/"];
    
    [self createDirectoryIfNotExist:result];
    
    NSDateComponents *comps = [self nowComponents];
    
    [result appendFormat:@"fileLog_%d-%d-%d.txt", [comps year], [comps month], [comps day]];
    
    struct stat st;
    if(lstat([result cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0)
    {
        if (st.st_size > 1024 * 1024)
        {
            [_fileManager removeItemAtPath:result error:nil];
        }
    }
    
    if (![_fileManager fileExistsAtPath:result])
    {
        [_fileManager createFileAtPath:result contents:nil attributes:nil];
    }
    
    return result;
}

- (BOOL)createDirectoryIfNotExist:(NSString *)directory
{
	NSFileManager *tmpFileManager = [NSFileManager defaultManager];
	
	BOOL isDir = NO;
	BOOL isExists = [tmpFileManager fileExistsAtPath:directory isDirectory:&isDir];
	
	if (!(isExists && isDir)) {
		
		BOOL result = [tmpFileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
        
        return result;
	}
    
    return YES;
    
}


- (NSDateComponents*)nowComponents
{
    NSDateFormatter *formatter =[[[NSDateFormatter alloc] init] autorelease];
    NSDate *date = [NSDate date];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    NSDateComponents* comps = [calendar components:unitFlags fromDate:date];
    
    return comps;
}

- (void)logWithString:(NSString*)str
{
    NSDateComponents *comps = [self nowComponents];
    [self writeLogWithString:[NSString stringWithFormat:kLogFormat, [comps year], [comps month], [comps day], [comps hour], [comps minute], [comps second], str]];
}


- (void)writeLogWithString:(NSString*)str
{
    [_fileHandler seekToEndOfFile];
    [_fileHandler writeData: [str dataUsingEncoding: NSUTF8StringEncoding]];
}


@end
