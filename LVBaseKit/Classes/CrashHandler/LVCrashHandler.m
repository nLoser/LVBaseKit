//
//  LVCrashHandler.m
//  LVBaseKit
//
//  Created by Hong Lv on 2021/11/7.
//

#import "LVCrashHandler.h"

#import <execinfo.h>
#import <sys/signal.h>

static NSUncaughtExceptionHandler *previousUncaughExceptionHandler = NULL;

static void lvUncaughtExceptionHanlder(NSException *exception) {
    NSArray *stackArray = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *exceptionInfo = [NSString stringWithFormat:@"reason:%@***name:%@\n%@", reason, name, [stackArray componentsJoinedByString:@"\n"]];
    
    NSLog(@"\n\n %@ \n\n\n---end----", exceptionInfo);
    
    if (previousUncaughExceptionHandler) {
        previousUncaughExceptionHandler(exception);
    }
    
    // 杀掉进程，这样可以防止同时抛出的SIGABRT被SignalException捕获
    kill(getpid(), SIGKILL);
}

static void _lvUncaughtSignalExceptionHandler(int signal, siginfo_t *info, void *context) {
    NSLog(@"%@", @"hahadsah");
}

static void lvUncaughtSignalExceptionHandler(int signal) {
    struct sigaction action;
    action.sa_sigaction = _lvUncaughtSignalExceptionHandler;
    action.sa_flags = SA_NODEFER | SA_SIGINFO;
    sigemptyset(&action.sa_mask);
    sigaction(signal, &action, 0);
}

@implementation LVCrashHandler

+ (void)registerExceptionHandler {
    previousUncaughExceptionHandler = NSGetUncaughtExceptionHandler();
    
    NSSetUncaughtExceptionHandler(&lvUncaughtExceptionHanlder);
    
    [self registerSignalExceptionHandler];
}

+ (void)registerSignalExceptionHandler {
    lvUncaughtSignalExceptionHandler(SIGABRT);
    lvUncaughtSignalExceptionHandler(SIGBUS);
    lvUncaughtSignalExceptionHandler(SIGFPE);
    lvUncaughtSignalExceptionHandler(SIGILL);
    lvUncaughtSignalExceptionHandler(SIGPIPE);
    lvUncaughtSignalExceptionHandler(SIGSEGV);
    lvUncaughtSignalExceptionHandler(SIGSYS);
    lvUncaughtSignalExceptionHandler(SIGTRAP);
}

@end
