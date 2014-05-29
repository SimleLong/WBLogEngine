//
//  NSMutableDictionary+WBLogSetValue.m
//  WBLogEngine
//
//  Created by kevin on 14-5-29.
//  Copyright (c) 2014年 Robin. All rights reserved.
//

#import "NSMutableDictionary+WBLogSetValue.h"

@implementation NSMutableDictionary (WBLogSetValue)

- (void)setLogSafeObject:(id)obj forKey:(NSString *)key
{
    if (obj == nil || key == nil)
        return;
    
    [self setObject:obj forKey:key];
}

@end
