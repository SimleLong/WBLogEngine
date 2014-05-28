//
//  WBRecordCrashTools.m
//  WBLogEginine
//
//  Created by Robin on 5/26/14.
//  Copyright (c) 2014 Robin. All rights reserved.
//

#import "WBRecordCrashTools.h"


#import <mach-o/dyld.h>
#import <stdio.h>
#import <fcntl.h>
#import <errno.h>
#import <unistd.h>

#import <errno.h>
#import <sys/socket.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <string.h>
#import <stdlib.h>

#import <stdbool.h>
#import <stdint.h>
#import <sys/sysctl.h>
#import <sys/types.h>

#import <mach-o/arch.h>
#import <mach/mach_init.h>
#import <mach/mach_error.h>
#import <mach/task.h>

const char* w_mach_currentCPUArch(void)
{
    const NXArchInfo* archInfo = NXGetLocalArchInfo();
    return archInfo == NULL ? NULL : archInfo->name;
}

uint32_t w_mach_imageNamed(const char* const imageName, bool exactMatch)
{
    const uint32_t imageCount = _dyld_image_count();
    
    for(uint32_t iImg = 0; iImg < imageCount; iImg++)
    {
        const char* name = _dyld_get_image_name(iImg);
        if(exactMatch)
        {
            if(strcmp(name, imageName) == 0)
            {
                return iImg;
            }
        }
        else
        {
            if(strstr(name, imageName) != NULL)
            {
                return iImg;
            }
        }
    }
    return UINT32_MAX;
}

uintptr_t w_mach_firstCmdAfterHeader(const struct mach_header* const header)
{
    switch(header->magic)
    {
        case MH_MAGIC:
        case MH_CIGAM:
            return (uintptr_t)(header + 1);
        case MH_MAGIC_64:
        case MH_CIGAM_64:
            return (uintptr_t)(((struct mach_header_64*)header) + 1);
        default:
            // Header is corrupt
            return 0;
    }
}

const uint8_t* w_mach_imageUUID(const char* const imageName, bool exactMatch)
{
    const uint32_t iImg = w_mach_imageNamed(imageName, exactMatch);
    if(iImg != UINT32_MAX)
    {
        const struct mach_header* header = _dyld_get_image_header(iImg);
        if(header != NULL)
        {
            uintptr_t cmdPtr = w_mach_firstCmdAfterHeader(header);
            if(cmdPtr != 0)
            {
                for(uint32_t iCmd = 0;iCmd < header->ncmds; iCmd++)
                {
                    const struct load_command* loadCmd = (struct load_command*)cmdPtr;
                    if(loadCmd->cmd == LC_UUID)
                    {
                        struct uuid_command* uuidCmd = (struct uuid_command*)cmdPtr;
                        return uuidCmd->uuid;
                    }
                    cmdPtr += loadCmd->cmdsize;
                }
            }
        }
    }
    return NULL;
}

const uintptr_t w_mach_imageAddress(const char* const imageName, bool exactMatch)
{
    const uint32_t iImg = w_mach_imageNamed(imageName, exactMatch);
    if(iImg != UINT32_MAX)
    {
        const struct mach_header* header = _dyld_get_image_header(iImg);
        if(header != NULL)
        {
            uintptr_t binaryAddress = (uintptr_t)header;
            return binaryAddress;
        }
    }
    return 0;
}

unsigned int w_mach_crashedThreadIndex()
{
    int index = -1;
    const thread_t currentThread = mach_thread_self();
    const task_t currentTask = mach_task_self();
    thread_act_array_t threads;
    mach_msg_type_number_t threadWBount;
    kern_return_t kr;
    
    /* Get a list of all threads */
    if ((kr = task_threads(currentTask, &threads, &threadWBount)) != KERN_SUCCESS) {
        NSLog(@"task_threads: %s", mach_error_string(kr));
        threadWBount = 0;
    }
    
    for (mach_msg_type_number_t i = 0; i < threadWBount; i++) {
        if (threads[i] == currentThread) {
            index = i;
            break;
        }
    }
    
    return index >= 0 ? index : 1001;
}
#pragma mark - system control
struct timeval w_syWBtl_timevalForName(const char* const name)
{
    struct timeval value = {0};
    size_t size = sizeof(value);
    
    if(0 != sysctlbyname(name, &value, &size, NULL, 0))
    {
        //NSlog{@"error"};
    }
    
    return value;
}


