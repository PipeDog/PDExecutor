//
//  PDExecutor.h
//  PDExecutor
//
//  Created by liang on 2018/5/9.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDExecutor : NSObject

+ (void)oncePerformInSeconds:(NSTimeInterval)secs forKey:(id)key
                       block:(dispatch_block_t)block;

+ (void)oncePerformInSeconds:(NSTimeInterval)secs forKey:(id)key
                       block:(dispatch_block_t)block
                  completion:(void (^ _Nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
