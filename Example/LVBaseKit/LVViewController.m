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
}

@end

@implementation LVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self test1];
}

#pragma mark - Test

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
