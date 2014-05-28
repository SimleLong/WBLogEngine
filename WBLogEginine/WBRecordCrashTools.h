//
//  WBRecordCrashTools.h
//  WBLogEginine
//
//  Created by Robin on 5/26/14.
//  Copyright (c) 2014 Robin. All rights reserved.
//

#import <Foundation/Foundation.h>

const char* w_mach_currentCPUArch(void);

uint32_t w_mach_imageNamed(const char* const imageName, bool exactMatch);

const uint8_t* w_mach_imageUUID(const char* const imageName, bool exactMatch);

const uintptr_t w_mach_imageAddress(const char* const imageName, bool exactMatch);

unsigned int w_mach_crashedThreadIndex();

struct timeval w_syWBtl_timevalForName(const char* const name);
