//
//  LVCombineTaskHandler.h
//  LVBaseKit
//
//  Created by Hong Lv on 2021/11/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LVCombineTaskHandler : NSObject

@end



typedef void(^configureBlock)(const dispatch_group_t group, const dispatch_queue_t queue);
typedef void(^taskBlock) (const dispatch_group_t group, const dispatch_queue_t queue);

@interface LVGCDCombinTaskHandler : LVCombineTaskHandler

@property (nonatomic, readonly, strong) dispatch_group_t group; ///< group

/**
 @brief 往Group添加任务
 
 @param configure 可以使用 dispatch_group_enter 标志一个异步任务，当前Group中未完成的任务数+1
 @param task 任务
 */
- (void)addTaskConfigure:(configureBlock)configure task:(taskBlock)task;

/**
 @brief 当Group任务都完成时回调函数
 
 @note 执行回调线程为GCD分配的异步线程
 @param isMain 是为主线程
 */
- (void)bindCompletionOnMainThread:(BOOL)isMain completion:(taskBlock)completion;

/**
 @brief 阻塞当前线程等待Group任务都完成
 
 @note 禁止在UI线程使用
 */
- (void)waitUnFinishTask:(dispatch_time_t)time;

@end

NS_ASSUME_NONNULL_END
