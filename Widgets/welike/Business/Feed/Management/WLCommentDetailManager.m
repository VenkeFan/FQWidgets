//
//  WLCommentDetailManager.m
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCommentDetailManager.h"
#import "WLCommentDetailRequest.h"
#import "WLCommentLayout.h"

@interface WLCommentDetailManager ()

@property (nonatomic, strong) WLCommentDetailRequest *commentDetailRequest;
@property (nonatomic, copy) NSString *cursor;

- (NSArray *)convertCommentListToLayoutModelList:(NSArray *)comments;

@end

@implementation WLCommentDetailManager

- (void)tryRefreshWithMainCid:(NSString *)mainCid
{
    if (self.commentDetailRequest != nil) return;
    self.cursor = nil;
    
    __weak typeof(self) weakSelf = self;
    self.commentDetailRequest = [[WLCommentDetailRequest alloc] initCommentDetailRequestWithCid:mainCid];
    [self.commentDetailRequest listRepliesWithCursor:nil successed:^(NSArray *replies, NSString *cursor) {
        weakSelf.commentDetailRequest = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *replyModels = [weakSelf convertCommentListToLayoutModelList:replies];
            BOOL last = [cursor length] == 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(onRefreshCommentDetail:replies:cid:last:errCode:)])
                {
                    [weakSelf.delegate onRefreshCommentDetail:weakSelf replies:replyModels cid:mainCid last:last errCode:ERROR_SUCCESS];
                }
            });
        });
    } error:^(NSInteger errorCode) {
        weakSelf.commentDetailRequest = nil;
        [weakSelf.delegate onRefreshCommentDetail:weakSelf replies:nil cid:mainCid last:NO errCode:errorCode];
    }];
}

- (void)tryHisWithMainCid:(NSString *)mainCid
{
    if (self.commentDetailRequest != nil) return;
    
    if ([self.cursor length] != 0)
    {
        __weak typeof(self) weakSelf = self;
        self.commentDetailRequest = [[WLCommentDetailRequest alloc] initCommentDetailRequestWithCid:mainCid];
        [self.commentDetailRequest listRepliesWithCursor:self.cursor successed:^(NSArray *replies, NSString *cursor) {
            weakSelf.commentDetailRequest = nil;
            BOOL last = [cursor length] > 0 ? NO : YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *replyModels = [weakSelf convertCommentListToLayoutModelList:replies];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([weakSelf.delegate respondsToSelector:@selector(onReceiveCommentDetailHis:replies:cid:last:errCode:)])
                    {
                        [weakSelf.delegate onReceiveCommentDetailHis:weakSelf replies:replyModels cid:mainCid last:last errCode:ERROR_SUCCESS];
                    }
                });
            });
        } error:^(NSInteger errorCode) {
            weakSelf.commentDetailRequest = nil;
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveCommentDetailHis:replies:cid:last:errCode:)])
            {
                [weakSelf.delegate onReceiveCommentDetailHis:weakSelf replies:nil cid:mainCid last:NO errCode:errorCode];
            }
        }];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onReceiveCommentDetailHis:replies:cid:last:errCode:)])
        {
            [self.delegate onReceiveCommentDetailHis:self replies:nil cid:mainCid last:YES errCode:ERROR_SUCCESS];
        }
    }
}

- (NSArray *)convertCommentListToLayoutModelList:(NSArray *)comments
{
    NSMutableArray *commentArray = [NSMutableArray arrayWithCapacity:[comments count]];
    for (NSInteger i = 0; i < [comments count]; i++) {
        WLCommentLayout *layout = [[WLCommentLayout alloc] initWithComment:[comments objectAtIndex:i]];
        [commentArray addObject:layout];
    }
    return commentArray;
}

@end
