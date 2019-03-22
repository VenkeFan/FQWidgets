//
//  WLPublishTask.h
//  welike
//
//  Created by 刘斌 on 2018/5/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLDraftBase;
@class WLPublishModel;

typedef NS_ENUM(NSInteger, WELIKE_PUBLISH_TASK_STATE)
{
    WELIKE_PUBLISH_TASK_STATE_IDLE = 0,
    WELIKE_PUBLISH_TASK_STATE_UPLOADING,
    WELIKE_PUBLISH_TASK_STATE_SENDING,
    WELIKE_PUBLISH_TASK_STATE_DONE,
    WELIKE_PUBLISH_TASK_STATE_FAILED
};

@protocol WLPublishTaskDelegate <NSObject>

- (void)onPublishTaskBegin:(NSString *)taskId;
- (void)onPublishTask:(NSString *)taskId process:(CGFloat)process;
- (void)onPublishTaskCompleted:(NSString *)taskId;
- (void)onPublishTask:(NSString *)taskId failed:(NSInteger)errCode;

@end

@interface WLPublishTask : NSObject

@property (nonatomic, readonly) WELIKE_PUBLISH_TASK_STATE state;
@property (nonatomic, readonly) NSString *taskId;
@property (nonatomic, weak) id<WLPublishTaskDelegate> delegate;
@property (nonatomic, strong, readonly) WLDraftBase *draft;

@property (nonatomic, assign) NSInteger uploadStartTime;
@property (nonatomic, assign) NSInteger uploadEndTime;
@property (nonatomic, strong) WLPublishModel *publishModel;
@property (nonatomic, copy) NSString *topicStr;




- (id)initWithDraft:(WLDraftBase *)draft;

- (void)start;

@end
