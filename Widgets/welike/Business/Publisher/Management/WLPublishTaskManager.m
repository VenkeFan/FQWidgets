//
//  WLPublishTaskManager.m
//  welike
//
//  Created by 刘斌 on 2018/5/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPublishTaskManager.h"
#import "WLPublishTask.h"
#import "WLDraftManager.h"
#import "AFNetworkManager.h"
#import "WLTrackerRepostAndComment.h"
#import "WLPublishModel.h"

@interface WLPublishTaskManager () <WLPublishTaskDelegate>

@property (nonatomic, strong) NSMutableArray *taskPool;
@property (nonatomic, strong) WLPublishTask *runningTask;
@property (nonatomic, strong) NSPointerArray *delegates;

@end

@implementation WLPublishTaskManager

- (id)init
{
    self = [super init];
    if (self)
    {
        self.taskPool = [NSMutableArray array];
        self.delegates = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

- (void)registerDelegate:(id<WLPublishTaskManagerDelegate>)delegate
{
    @synchronized (self.delegates)
    {
        if ([self.delegates containsObject:delegate] == NO)
        {
            [self.delegates addObject:delegate];
        }
    }
}

- (void)unregister:(id<WLPublishTaskManagerDelegate>)delegate
{
    @synchronized (self.delegates)
    {
        [self.delegates removeObject:delegate];
    }
}

-(NSString *)postTaskWithTrackInfo:(WLPublishModel *)trackInfo withDraft:(WLDraftBase *)draft
{
    if ([[AFNetworkManager getInstance] reachabilityStatus] != HLNetWorkStatusNotReachable)
    {
        WLPublishTask *task = [[WLPublishTask alloc] initWithDraft:draft];
        task.publishModel = trackInfo;
        draft.show = NO;
        
        if ([draft isKindOfClass:[WLPostDraft class]])
        {
            WLPostDraft *postDraft = (WLPostDraft *)draft;
            if (postDraft.pollDraftList.count == 0)
            {
                [[AppContext getInstance].draftManager insertOrUpdate:draft];
            }
        }
        else
        {
            [[AppContext getInstance].draftManager insertOrUpdate:draft];
        }
        
        if (self.runningTask == nil)
        {
            self.runningTask = task;
            self.runningTask.delegate = self;
            [self.runningTask start];
        }
        else
        {
            @synchronized (self.taskPool)
            {
                [self.taskPool addObject:task];
            }
        }
        return task.taskId;
    }
    else
    {
        [self handlePostError];
        
        //处理下投票的情况,不需要存草稿
        if ([draft isKindOfClass:[WLPostDraft class]])
        {
            WLPostDraft *postDraft = (WLPostDraft *)draft;
            if (postDraft.pollDraftList.count > 0)
            {
                draft.show = NO;
            }
            else
            {
                draft.show = YES;
                [[AppContext getInstance].draftManager insertOrUpdate:draft];
            }
        }
        else{
            draft.show = YES;
            [[AppContext getInstance].draftManager insertOrUpdate:draft];
        }
        
        
        //发送打点
        [WLPublishTrack publishSendBtnClicked:self.runningTask.publishModel];
        
        //发送失败打点
        [WLPublishTrack publishSendBtnClickedAndFail:self.runningTask.publishModel];
        
        
        NSString *taskId = [LuuUtils uuid];
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized (self.delegates)
            {
                for (NSInteger i = 0; i < [self.delegates count]; i++)
                {
                    id<WLPublishTaskManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
                    if ([delegate respondsToSelector:@selector(onPublishTask:end:)])
                    {
                        [delegate onPublishTask:taskId end:ERROR_NETWORK_INVALID];
                    }
                }
            }
        });
        
        return taskId;
    }
}

//不再调用
- (NSString *)postTask:(WLDraftBase *)draft
{
    if ([[AFNetworkManager getInstance] reachabilityStatus] != HLNetWorkStatusNotReachable)
    {
        WLPublishTask *task = [[WLPublishTask alloc] initWithDraft:draft];
        draft.show = NO;
        
        if ([draft isKindOfClass:[WLPostDraft class]])
        {
            WLPostDraft *postDraft = (WLPostDraft *)draft;
            if (postDraft.pollDraftList.count == 0)
            {
                [[AppContext getInstance].draftManager insertOrUpdate:draft];
            }
        }
        else
        {
            [[AppContext getInstance].draftManager insertOrUpdate:draft];
        }

        if (self.runningTask == nil)
        {
            self.runningTask = task;
            self.runningTask.delegate = self;
            [self.runningTask start];
        }
        else
        {
            @synchronized (self.taskPool)
            {
                [self.taskPool addObject:task];
            }
        }
        return task.taskId;
    }
    else
    {
        [self handlePostError];
        
        //处理下投票的情况,不需要存草稿
        if ([draft isKindOfClass:[WLPostDraft class]])
        {
            WLPostDraft *postDraft = (WLPostDraft *)draft;
            if (postDraft.pollDraftList.count > 0)
            {
                draft.show = NO;
            }
            else
            {
                 draft.show = YES;
                [[AppContext getInstance].draftManager insertOrUpdate:draft];
            }
        }
        else{
             draft.show = YES;
              [[AppContext getInstance].draftManager insertOrUpdate:draft];
        }
        
        
        NSString *taskId = [LuuUtils uuid];
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized (self.delegates)
            {
                for (NSInteger i = 0; i < [self.delegates count]; i++)
                {
                    id<WLPublishTaskManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
                    if ([delegate respondsToSelector:@selector(onPublishTask:end:)])
                    {
                        [delegate onPublishTask:taskId end:ERROR_NETWORK_INVALID];
                    }
                }
            }
        });
        
        return taskId;
    }
}

#pragma mark WLPublishTaskDelegate methods
- (void)onPublishTaskBegin:(NSString *)taskId
{
    if (self.runningTask != nil && [self.runningTask.taskId isEqualToString:taskId] == YES)
    {
        @synchronized (self.delegates)
        {
            for (NSInteger i = 0; i < [self.delegates count]; i++)
            {
                id<WLPublishTaskManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
                if ([delegate respondsToSelector:@selector(onPublishTaskBegin:)])
                {
                    [delegate onPublishTaskBegin:taskId];
                }
            }
        }
    }
}

- (void)onPublishTask:(NSString *)taskId process:(CGFloat)process
{
    if (self.runningTask != nil && [self.runningTask.taskId isEqualToString:taskId] == YES)
    {
        @synchronized (self.delegates)
        {
            for (NSInteger i = 0; i < [self.delegates count]; i++)
            {
                id<WLPublishTaskManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
                if ([delegate respondsToSelector:@selector(onPublishTask:process:)])
                {
                    [delegate onPublishTask:taskId process:process];
                    //NSLog(@"上传进度%f",process / 100.0);
                }
            }
        }
    }
}

- (void)onPublishTaskCompleted:(NSString *)taskId
{
    if (self.runningTask != nil && [self.runningTask.taskId isEqualToString:taskId] == YES)
    {
        [WLTrackerRepostAndComment appendTrackerWithDraft:self.runningTask.draft
                                                   status:WLTrackerReAndComStatus_Succeed];
        
        //发送打点
        [WLPublishTrack publishSendBtnClicked:self.runningTask.publishModel];
        
        //发送成功打点
        self.runningTask.publishModel.post_id = self.runningTask.draft.pid;
        [WLPublishTrack publishSendBtnClickedAndSuccess:self.runningTask.publishModel];
        
        self.runningTask = nil;
        
        @synchronized (self.delegates)
        {
            for (NSInteger i = 0; i < [self.delegates count]; i++)
            {
                id<WLPublishTaskManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
                if ([delegate respondsToSelector:@selector(onPublishTask:end:)])
                {
                    [delegate onPublishTask:taskId end:ERROR_SUCCESS];
                }
            }
        }
        
        @synchronized (self.taskPool)
        {
            if ([self.taskPool count] > 0)
            {
                self.runningTask = [self.taskPool objectAtIndex:0];
                [self.taskPool removeObject:self.runningTask];
                self.runningTask.delegate = self;
                [self.runningTask start];
            }
        }
    }
}

- (void)onPublishTask:(NSString *)taskId failed:(NSInteger)errCode
{
    if (self.runningTask != nil && [self.runningTask.taskId isEqualToString:taskId] == YES)
    {
        [self handlePostError];
        
        [WLTrackerRepostAndComment appendTrackerWithDraft:self.runningTask.draft
                                                   status:WLTrackerReAndComStatus_Failed];
        
        //发送打点
        [WLPublishTrack publishSendBtnClicked:self.runningTask.publishModel];
        
        //发送失败打点
        [WLPublishTrack publishSendBtnClickedAndFail:self.runningTask.publishModel];
        
        self.runningTask = nil;
        @synchronized (self.delegates)
        {
            for (NSInteger i = 0; i < [self.delegates count]; i++)
            {
                id<WLPublishTaskManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
                if ([delegate respondsToSelector:@selector(onPublishTask:end:)])
                {
                    [delegate onPublishTask:taskId end:errCode];
                }
            }
        }
        
        @synchronized (self.taskPool)
        {
            if ([self.taskPool count] > 0)
            {
                self.runningTask = [self.taskPool objectAtIndex:0];
                [self.taskPool removeObject:self.runningTask];
                self.runningTask.delegate = self;
                [self.runningTask start];
            }
        }
    }
}


-(void)handlePostError
{
    _runningTask.uploadStartTime = 0;
    _runningTask.uploadEndTime = 0;
}

@end
