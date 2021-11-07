//
//  LVViewController.m
//  LVBaseKit
//
//  Created by newhl on 11/06/2021.
//  Copyright (c) 2021 newhl. All rights reserved.
//

#import "LVViewController.h"

#import <LVBaseKit/LVCombineTaskHandler.h>

@interface LVViewController () {
    LVGCDCombinTaskHandler *_handler;
    LVBarrierReadWriteHander *_handler2;
}

@end

@implementation LVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    [self test4];
}

#pragma mark - Test

- (void)test4 {
    
}

- (void)test2 {
    _handler2 = [[LVBarrierReadWriteHander alloc] init];
    __weak typeof(self) weakSelf = self;
    [_handler2 addReadTask:^(const dispatch_queue_t  _Nonnull queue) {
        [weakSelf test3];
    }];
    [_handler2 addReadTask:^(const dispatch_queue_t  _Nonnull queue) {
        [weakSelf test3];
    }];
    [_handler2 addWriteTask:^(const dispatch_queue_t  _Nonnull queue) {
        NSLog(@"------- write -------");
        sleep(2);
    }];
    [_handler2 addReadTask:^(const dispatch_queue_t  _Nonnull queue) {
        [weakSelf test3];
    }];
    [_handler2 addWriteTask:^(const dispatch_queue_t  _Nonnull queue) {
        NSLog(@"------- write -------");
        sleep(2);
    }];
    [_handler2 addReadTask:^(const dispatch_queue_t  _Nonnull queue) {
        [weakSelf test3];
    }];
    [_handler2 addReadTask:^(const dispatch_queue_t  _Nonnull queue) {
        [weakSelf test3];
    }];
}

- (void)test3 {
    NSInteger timeout = MAX(random()%10, 1);
    NSInteger idn = random()%1000000;
    NSLog(@"开始读%ld秒-%ld", (long)timeout,idn);
    
    sleep((int)timeout);
    
    NSLog(@"---%ld结束",idn);
}

- (void)test1 {
    _handler = [[LVGCDCombinTaskHandler alloc] init];
    
    __block NSArray *data1;
    __block NSArray *data2;
    
    [_handler addTaskConfigure:^(const dispatch_group_t  _Nonnull group, const dispatch_queue_t  _Nonnull queue) {
        dispatch_group_enter(group);
    } task:^(const dispatch_group_t  _Nonnull group, const dispatch_queue_t  _Nonnull queue) {
        NSLog(@"___enter 1");
        dispatch_async(queue, ^{
            sleep(2);
            data1 = @[@"dsa",@"dsa",@"dsa"];
            dispatch_group_leave(group);
        });
        NSLog(@"___exit 1");
    }];
    
    [_handler addTaskConfigure:^(const dispatch_group_t  _Nonnull group, const dispatch_queue_t  _Nonnull queue) {
        dispatch_group_enter(group);
    } task:^(const dispatch_group_t  _Nonnull group, const dispatch_queue_t  _Nonnull queue) {
        NSLog(@"___enter 2");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            sleep(2);
            data2 = @[@"hahah", @"ri", @"niubi"];
            dispatch_group_leave(group);
        });
        NSLog(@"___exit 2");
    }];
    
    [_handler bindCompletionOnMainThread:YES completion:^(const dispatch_group_t  _Nonnull group, const dispatch_queue_t  _Nonnull queue) {
        NSLog(@"%@ \n %@", data1, data2);
    }];
}

@end
