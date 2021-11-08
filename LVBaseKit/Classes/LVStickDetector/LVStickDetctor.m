//
//  LVStickDetctor.m
//  LVBaseKit
//
//  Created by Hong Lv on 2021/11/6.
//

#import "LVStickDetctor.h"

static LVStickDetctor *detector;

@interface LVStickDetctor ()

@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, assign) CFRunLoopActivity activity;   ///< 监听到的状态
@property (nonatomic, assign) NSInteger timeoutCount; ///< 超时次数

@end

/**
 // Run Loop Observer Activities
 typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
     kCFRunLoopEntry = (1UL << 0),
     kCFRunLoopBeforeTimers = (1UL << 1),
     kCFRunLoopBeforeSources = (1UL << 2),
     kCFRunLoopBeforeWaiting = (1UL << 5),
     kCFRunLoopAfterWaiting = (1UL << 6),
     kCFRunLoopExit = (1UL << 7),
     kCFRunLoopAllActivities = 0x0FFFFFFFU
 }
 */
static void lv_runloopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    detector.activity = activity;
    dispatch_semaphore_signal(detector.semaphore);
}



@implementation LVStickDetctor

- (void)registerObserver {
    CFRunLoopObserverContext context = {0, (__bridge void *)self, NULL, NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                            kCFRunLoopAllActivities,
                                                            YES,
                                                            0,
                                                            &lv_runloopObserverCallBack,
                                                            &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    
    //创建一个信号
    _semaphore = dispatch_semaphore_create(0);
    
    // 子线程监控时长
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (YES) {
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC);
            long st = dispatch_semaphore_wait(self.semaphore, time);
            if (st != 0) {
                if (self.activity == kCFRunLoopBeforeSources || self.activity == kCFRunLoopAfterWaiting) {
                    if (++self.timeoutCount < 5) continue;
                    //ANR Report
                    /**
                     PLCrashReporterConfig *config = [[PLCrashReporterConfig alloc] initWithSignalHandlerType:PLCrashReporterSignalHandlerTypeBSD
                                                                                        symbolicationStrategy:PLCrashReporterSymbolicationStrategyAll];
                     PLCrashReporter *crashReporter = [[PLCrashReporter alloc] initWithConfiguration:config];
                     NSData *data = [crashReporter generateLiveReport];
                     PLCrashReport *reporter = [[PLCrashReport alloc] initWithData:data error:NULL];
                     NSString *report = [PLCrashReportTextFormatter stringValueForCrashReport:reporter
                                                                               withTextFormat:PLCrashReportTextFormatiOS];
                     */
                }
            }
            self.timeoutCount = 0;
        }
    });
}

@end
