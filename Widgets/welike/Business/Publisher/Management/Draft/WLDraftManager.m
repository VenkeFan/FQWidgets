//
//  WLDraftManager.m
//  welike
//
//  Created by 刘斌 on 2018/5/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDraftManager.h"
#import "WLDraftCache.h"

@interface WLDraftManager ()

@property (nonatomic, strong) WLDraftCache *cache;

@end

@implementation WLDraftManager

- (id)init
{
    self = [super init];
    if (self)
    {
        self.cache = [[WLDraftCache alloc] init];
    }
    return self;
}

- (void)prepare
{
    [self.cache prepare];
}

- (void)insertOrUpdate:(WLDraftBase *)draft
{
//    NSLog(@"123131 WLDraftManager");
    long long now = [[NSDate date] timeIntervalSince1970] * 1000;
    draft.time = now;
    [self.cache insertOrUpdate:draft];
}

- (void)resetUncompletedDraft:(WLDraftBase *)draft
{
    if (draft.type == WELIKE_DRAFT_TYPE_POST)
    {
        WLPostDraft *postDraft = (WLPostDraft *)draft;
        if ([postDraft.picDraftList count] > 0)
        {
            for (NSInteger i = 0; i < [postDraft.picDraftList count]; i++)
            {
                WLAttachmentDraft *pic = [postDraft.picDraftList objectAtIndex:i];
                pic.objectKey = nil;
            }
        }
        WLAttachmentDraft *video = postDraft.video;
        if (video != nil)
        {
            video.objectKey = nil;
        }
    }
}

- (void)deleteDraftWithId:(NSString *)draftId
{
    [self.cache deleteWithId:draftId];
}

- (void)clearAll
{
    [self.cache deleteAll];
}

- (void)listAll:(listAllCompleted)completed
{
    [self.cache listAllShowable:^(NSArray *draftList) {
        if (completed)
        {
            completed(draftList);
        }
    }];
}

- (void)countAll:(countAllCompleted)completed
{
    [self.cache countAllShowable:^(NSInteger count) {
        if (completed)
        {
            completed(count);
        }
    }];
}

- (void)reset
{
    [self.cache reset];
}

@end
