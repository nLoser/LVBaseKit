//
//  LVCombineTaskHandler.m
//  LVBaseKit
//
//  Created by Hong Lv on 2021/11/6.
//

#import "LVCombineTaskHandler.h"

@implementation LVCombineTaskHandler

@end

@interface LVGCDCombinTaskHandler ()

@property (nonatomic, readwrite, strong) dispatch_group_t group;
@property (nonatomic, strong) dispatch_queue_t concurrent;

@end

@implementation LVGCDCombinTaskHandler

#pragma mark - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        _group = dispatch_group_create();
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INITIATED, 0);
        _concurrent = dispatch_queue_create("com.lv", attr);
    }
    return self;
}

#pragma mark - Public Method

- (void)addTaskConfigure:(configureBlock)configure task:(taskBlock)task {
    if (!self.group || !self.concurrent) return;
    __weak typeof(self) weakSelf = self;
    if (configure) {
        configure(self.group, self.concurrent);
    }
    dispatch_group_async(self.group, self.concurrent, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && task) {
            task(strongSelf.group, strongSelf.concurrent);
        }
    });
}

- (void)bindCompletionOnMainThread:(BOOL)isMain completion:(taskBlock)completion {
    dispatch_queue_t queue = isMain ? dispatch_get_main_queue() : self.concurrent;
    if (!self.group || !self.concurrent) return;
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(self.group, queue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && completion) {
            completion(strongSelf.group, strongSelf.concurrent);
        }
    });
}

- (void)waitUnFinishTask:(dispatch_time_t)time {
#if DEBUG
    BOOL isMain = strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0;
    NSAssert(!isMain, @"当前为UI线程");
#endif
    dispatch_group_wait(self.group, time);
}

@end


@interface LVBarrierReadWriteHander ()

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation LVBarrierReadWriteHander

#pragma mark - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INITIATED, 0);
        _queue = dispatch_queue_create("com.lv.rw", attr);
    }
    return self;
}

#pragma mark - Public Method

- (void)addReadTask:(normalTaskBlock)task {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        __weak typeof(weakSelf) strongSelf = weakSelf;
        if (task && strongSelf) {
            task(strongSelf.queue);
        }
    });
}

- (void)addWriteTask:(normalTaskBlock)task {
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(self.queue, ^{
        NSLog(@"barrier:%@", [NSThread currentThread]);
        __weak typeof(weakSelf) strongSelf = weakSelf;
        if (task && strongSelf) {
            task(strongSelf.queue);
        }
    });
}

@end
