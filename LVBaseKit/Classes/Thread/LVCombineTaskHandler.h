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
typedef void(^normalTaskBlock)(const dispatch_queue_t queue); ///queue ：当前任务队列

/**
 @brief 利用GCD_group完成并发任务
 */
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


/**
 @brief 利用GCD_Barrier实现读写任务
 
 @note 允许多条线程读取操作
 @note 不允许多线程同时执行读、写操作
 @note 不允许多线程多个写操作
 */
@interface LVBarrierReadWriteHander : LVCombineTaskHandler

/**
 @brief 利用 dispatch_barrier_async 开辟新线程完成写操作
 */
- (void)addWriteTask:(normalTaskBlock)task;

/**
 @brief 利用 dispatch_async 异步并发任务
 */
- (void)addReadTask:(normalTaskBlock)task;

@end

NS_ASSUME_NONNULL_END
