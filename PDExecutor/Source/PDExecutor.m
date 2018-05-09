//
//  PDExecutor.m
//  PDExecutor
//
//  Created by liang on 2018/5/9.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDExecutor.h"

#define Lock() dispatch_semaphore_wait(__lock(), DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(__lock())

static NSString *const kLastExecuteTimestampKey = @"kLastExecuteTimestampKey";
static NSString *const kExecuteInSecondsKey = @"kExecuteInSecondsKey";

static NSMutableDictionary *__executeDict() {
    static NSMutableDictionary *__executeDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __executeDict = [NSMutableDictionary dictionary];
    });
    return __executeDict;
}

static dispatch_semaphore_t __lock() {
    static dispatch_semaphore_t __lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __lock = dispatch_semaphore_create(1);
    });
    return __lock;
}

@implementation PDExecutor

// infoDict {kLastExecuteTimestampKey: xxx, kExecuteInSecondsKey: xxx}
// __executeDict {key: infoDict, key1: infoDict1}
+ (void)oncePerformInSeconds:(NSTimeInterval)secs forKey:(id)key
                       block:(dispatch_block_t)block {
    [self oncePerformInSeconds:secs forKey:key block:block completion:nil];
}

+ (void)oncePerformInSeconds:(NSTimeInterval)secs forKey:(id)key
                       block:(dispatch_block_t)block
                  completion:(void (^)(BOOL finished))completion {
    NSAssert(secs > 0, @"Param secs must greater or equal to 0");
    NSAssert(key != nil, @"Param key cannot be nil");
    
    Lock();
    NSDictionary *infoDict = __executeDict()[key];
    if (!infoDict) infoDict = [NSDictionary dictionary];
    
    NSTimeInterval lastExecuteTimestamp = [infoDict[kLastExecuteTimestampKey] doubleValue];
    NSTimeInterval currentTimestamp = [NSDate date].timeIntervalSince1970;
    Unlock();
    
    if (currentTimestamp - lastExecuteTimestamp < secs) {
        return;
    }
    lastExecuteTimestamp = currentTimestamp;
    
    Lock();
    infoDict = @{kLastExecuteTimestampKey: @(lastExecuteTimestamp),
                 kExecuteInSecondsKey: @(secs)};
    [__executeDict() setObject:infoDict forKey:key];
    Unlock();
    
    if (block) block();
    if (completion) completion(YES);
}

@end
