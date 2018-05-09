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

static NSMutableDictionary<NSString *, NSNumber *> *__executeDict() {
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

+ (void)oncePerformInSeconds:(NSTimeInterval)secs forKey:(NSString *)key
                       block:(dispatch_block_t)block {
    [self oncePerformInSeconds:secs forKey:key block:block completion:nil];
}

+ (void)oncePerformInSeconds:(NSTimeInterval)secs forKey:(NSString *)key
                       block:(dispatch_block_t)block
                  completion:(void (^)(BOOL finished))completion {
    NSAssert(secs > 0, @"Param secs must greater or equal to 0");
    NSAssert(key != nil, @"Param key cannot be nil");
    
    Lock();
    NSTimeInterval lastExecuteTimestamp = [__executeDict()[key] doubleValue];
    NSTimeInterval currentTimestamp = [NSDate date].timeIntervalSince1970;
    Unlock();
    
    if (currentTimestamp - lastExecuteTimestamp < secs) {
        return;
    }
    
    Lock();
    lastExecuteTimestamp = currentTimestamp;
    [__executeDict() setObject:@(lastExecuteTimestamp) forKey:key];
    
    NSArray<NSString *> *allKeys = [__executeDict().allKeys copy];

    if (allKeys.count > 30) {
        for (NSString *tmpKey in allKeys) {
            if ([tmpKey isEqualToString:key]) continue;
            [__executeDict() removeObjectForKey:tmpKey]; break;
        }
    }
    Unlock();
    
    if (block) block();
    if (completion) completion(YES);
}

@end
