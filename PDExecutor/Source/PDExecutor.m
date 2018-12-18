//
//  PDExecutor.m
//  PDExecutor
//
//  Created by liang on 2018/5/9.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDExecutor.h"

#define Lock() dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self.lock)

@interface PDExecutor ()

@property (class, strong, readonly) NSMutableDictionary<NSString *, NSNumber *> *handlers;
@property (class, strong, readonly) dispatch_semaphore_t lock;

@end

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
    NSTimeInterval lastExecuteTimestamp = [self.handlers[key] doubleValue];
    NSTimeInterval currentTimestamp = [NSDate date].timeIntervalSince1970;
    Unlock();
    
    if (currentTimestamp - lastExecuteTimestamp < secs) {
        return;
    }
    
    Lock();
    lastExecuteTimestamp = currentTimestamp;
    [self.handlers setObject:@(lastExecuteTimestamp) forKey:key];
    
    NSArray<NSString *> *allKeys = [self.handlers.allKeys copy];

    if (allKeys.count > 30) {
        for (NSString *tmpKey in allKeys) {
            if ([tmpKey isEqualToString:key]) continue;
            [self.handlers removeObjectForKey:tmpKey]; break;
        }
    }
    Unlock();
    
    !block ?: block();
    !completion ?: completion(YES);
}

#pragma mark - Getter Methods
+ (NSMutableDictionary<NSString *,NSNumber *> *)handlers {
    static NSMutableDictionary *_handlers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _handlers = [NSMutableDictionary dictionary];
    });
    return _handlers;
}

+ (dispatch_semaphore_t)lock {
    static dispatch_semaphore_t _lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lock = dispatch_semaphore_create(1);
    });
    return _lock;
}


@end
