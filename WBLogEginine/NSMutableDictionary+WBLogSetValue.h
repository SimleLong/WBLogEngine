//
//  NSMutableDictionary+WBLogSetValue.h
//  WBLogEngine
//
//  Created by kevin on 14-5-29.
//  Copyright (c) 2014年 Robin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (WBLogSetValue)

/*!
 *  向当前字典中添加非空键值对
 *
 *  @param obj 需要设置的对象
 *  @param key 需要设置的键值
 */
- (void)setLogSafeObject:(id)obj forKey:(NSString *)key;

@end
