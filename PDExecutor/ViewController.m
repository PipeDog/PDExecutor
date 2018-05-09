//
//  ViewController.m
//  PDExecutor
//
//  Created by liang on 2018/5/9.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "ViewController.h"
#import "PDExecutor.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    for (int i = 0; i < 10; i ++) {
        [PDExecutor oncePerformInSeconds:0.5f forKey:NSStringFromSelector(_cmd) block:^{
            NSLog(@"i = (%d)", i);
        }];
    }
    
    [self perform];
}

- (void)perform {
    [PDExecutor oncePerformInSeconds:0.5 forKey:NSStringFromSelector(_cmd) block:^{
        NSLog(@"perform >>>");
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self perform];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
