//
//  LVCrashHandler.m
//  LVBaseKit
//
//  Created by Hong Lv on 2021/11/7.
//

#import "LVCrashHandler.h"

extern void lvUncaughtExceptionHanlder(NSException *exception) {
    NSArray *stackArray = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *exceptionInfo = [NSString stringWithFormat:@"%@", [stackArray componentsJoinedByString:@"\n"]];
    
}

@implementation LVCrashHandler

+ (void)registerExceptionHandler {
    NSSetUncaughtExceptionHandler(&lvUncaughtExceptionHanlder);
}

@end
