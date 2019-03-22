//
//  WLSingleContentManager.m
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSingleContentManager.h"
#import "WLPostBase.h"
#import "WLComment.h"
#import "WLSuperLikeRequest.h"
#import "WLDislikePostRequest.h"
#import "WLLikeCommentRequest.h"
#import "WLDislikeCommentRequest.h"
#import "WLLikeReplyRequest.h"
#import "WLDislikeReplyRequest.h"
#import "WLDeletePostRequest.h"
#import "WLDeleteCommentRequest.h"
#import "WLDeleteReplyRequest.h"
#import "WLAccountManager.h"
#import "WLPollPost.h"
#import "WLPollRequest.h"
#import "WLTrackerLike.h"

@interface WLLikeManager : NSObject

+ (NSInteger)convertSuperLikeLevelWithExp:(long long)exp;
+ (NSInteger)likeCountBySuperLikeLevel:(NSInteger)level;

@end

@implementation WLLikeManager

+ (NSInteger)convertSuperLikeLevelWithExp:(long long)exp
{
    if (exp == 0) return 1;
    if (exp >= 1 && exp < 30) return 2;
    if (exp >= 30 && exp < 50) return 3;
    if (exp >= 50 && exp < 100) return 4;
    if (exp >= 100) return 5;
    return 1;
}

+ (NSInteger)likeCountBySuperLikeLevel:(NSInteger)level
{
    if (level == 2) return 1;
    if (level == 3) return 3;
    if (level == 4) return 5;
    if (level == 5) return 10;
    return 0;
}

@end

@interface WLSingleContentManager ()

@property (nonatomic, strong) NSPointerArray *delegates;
@property (nonatomic, strong) NSMutableDictionary *deleteMap;

- (void)broadcastDeletePost:(NSString *)pid;
- (void)broadcastDeletePost:(NSString *)pid Failed:(NSInteger)errCode;
- (void)broadcastDeleteComment:(NSString *)cid;
- (void)broadcastDeleteComment:(NSString *)cid Failed:(NSInteger)errCode;

@end

@implementation WLSingleContentManager

- (id)init
{
    self = [super init];
    if (self)
    {
        self.deleteMap = [NSMutableDictionary dictionary];
        self.delegates = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

- (void)registerDelegate:(id<WLSingleContentManagerDelegate>)delegate
{
    @synchronized (self.delegates)
    {
        [self.delegates addObject:delegate];
    }
}

- (void)unregister:(id<WLSingleContentManagerDelegate>)delegate
{
    @synchronized (self.delegates)
    {
        [self.delegates removeObject:delegate];
    }
}

- (void)likePost:(WLPostBase *)post
{
    [self superLikePost:post exp:1];
}

- (void)superLikePost:(WLPostBase *)post exp:(long long)exp
{
    if (exp < 0) exp = 0;
    if (exp > 99) exp = 100;
    long long preExp = post.superLikeExp;
    post.superLikeExp = MAX(preExp, exp);
    NSInteger level = [WLLikeManager convertSuperLikeLevelWithExp:exp];
    NSInteger preLevel = [WLLikeManager convertSuperLikeLevelWithExp:preExp];
    if (preLevel != level)
    {
        long long preCount = [WLLikeManager likeCountBySuperLikeLevel:preLevel];
        long long count = [WLLikeManager likeCountBySuperLikeLevel:level];
        post.likeCount = post.likeCount+count-preCount;
    }
    long long newExp = exp - preExp;
    if (newExp == 0) return;
    
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    WLSuperLikeRequest *req = [[WLSuperLikeRequest alloc] initSuperLikeRequestWithUid:account.uid pid:post.pid exp:newExp];
    [req like];
    
    [WLTrackerLike appendTrackerLikePost:post];
}

+ (NSInteger)convertSuperLikeLevelWithExp:(long long)exp
{
    return [WLLikeManager convertSuperLikeLevelWithExp:exp];
}

+ (UIImage *)superLikeImageWithExp:(long long)exp
{
    return [self superLikeImageWithExp:exp imgType:WLSuperLikeType_Feed];
}

+ (UIImage *)superLikeImageWithExp:(long long)exp imgType:(WLSuperLikeType)imgType
{
    BOOL isFeedDetail = (imgType == WLSuperLikeType_FeedDetail);
    NSString *imageKey = !isFeedDetail ? @"feed_like_level_0" : @"feed_detail_like_level_0";
    NSInteger level = [WLLikeManager convertSuperLikeLevelWithExp:exp];
    
    switch (level) {
        case 2:
        {
            imageKey = !isFeedDetail ? @"feed_like_level_1" : @"feed_detail_like_level_1";
        }
            break;
        case 3:
        {
            imageKey = !isFeedDetail ? @"feed_like_level_3" : @"feed_detail_like_level_3";
        }
            break;
        case 4:
        {
            imageKey = !isFeedDetail ? @"feed_like_level_5" : @"feed_detail_like_level_5";
        }
            break;
        case 5:
        {
            imageKey = !isFeedDetail ? @"feed_like_level_10" : @"feed_detail_like_level_10";
        }
            break;
            
        default:
            break;
    }
    return [AppContext getImageForKey:imageKey];
}

- (void)dislikePost:(WLPostBase *)post
{
    NSInteger level = [WLLikeManager convertSuperLikeLevelWithExp:post.superLikeExp];
    NSInteger count = [WLLikeManager likeCountBySuperLikeLevel:level];
    long long lastLikeCount = post.likeCount - count;
    if (lastLikeCount < 0) lastLikeCount = 0;
    post.superLikeExp = 0;
    post.likeCount = lastLikeCount;
    
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    WLDislikePostRequest *req = [[WLDislikePostRequest alloc] initDislikeRequestWithUid:account.uid pid:post.pid];
    [req dislike];
}

- (void)likeComment:(NSString *)cid
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    WLLikeCommentRequest *req = [[WLLikeCommentRequest alloc] initLikeCommentRequestWithUid:account.uid cid:cid];
    [req like];
    
    [WLTrackerLike appendTrackerLikeCommentOrReplay:cid];
}

- (void)dislikeComment:(NSString *)cid
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    WLDislikeCommentRequest *req = [[WLDislikeCommentRequest alloc] initDislikeCommentRequestWithUid:account.uid cid:cid];
    [req dislike];
}

- (void)likeReply:(NSString *)rid
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    WLLikeReplyRequest *req = [[WLLikeReplyRequest alloc] initLikeReplyRequestWithUid:account.uid rid:rid];
    [req like];
    
    [WLTrackerLike appendTrackerLikeCommentOrReplay:rid];
}

- (void)dislikeReply:(NSString *)rid
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    WLDislikeReplyRequest *req = [[WLDislikeReplyRequest alloc] initDislikeReplyRequestWithUid:account.uid rid:rid];
    [req dislike];
}

- (void)deletePost:(WLPostBase *)post
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    if ([account.uid isEqualToString:post.uid] == YES)
    {
        @synchronized (self.deleteMap)
        {
            if ([self.deleteMap objectForKey:post.pid] != nil) return;
        }
        __weak typeof(self) weakSelf = self;
        NSString *p = [post.pid copy];
        WLDeletePostRequest *request = [[WLDeletePostRequest alloc] initDeletePostRequestWithUid:post.uid pid:post.pid];
        [request deletePostForSuccessed:^(NSString *pid) {
            [weakSelf broadcastDeletePost:pid];
        } error:^(NSInteger errorCode) {
            [weakSelf broadcastDeletePost:p Failed:errorCode];
        }];
    }
}

- (void)deleteComment:(WLComment *)comment
{
    @synchronized (self.deleteMap)
    {
        if ([self.deleteMap objectForKey:comment.cid] != nil) return;
    }
    __weak typeof(self) weakSelf = self;
    NSString *c = [comment.cid copy];
    WLDeleteCommentRequest *request = [[WLDeleteCommentRequest alloc] initDeleteCommentRequestWithUid:comment.uid cid:comment.cid];
    [request deleteCommentForSuccessed:^(NSString *cid) {
        [weakSelf broadcastDeleteComment:cid];
    } error:^(NSInteger errorCode) {
        [weakSelf broadcastDeleteComment:c Failed:errorCode];
    }];
}

- (void)deleteReply:(WLComment *)comment
{
    @synchronized (self.deleteMap)
    {
        if ([self.deleteMap objectForKey:comment.cid] != nil) return;
    }
    __weak typeof(self) weakSelf = self;
    NSString *r = [comment.cid copy];
    WLDeleteReplyRequest *request = [[WLDeleteReplyRequest alloc] initDeleteReplyRequestWithUid:comment.uid rid:comment.cid];
    [request deleteReplyForSuccessed:^(NSString *rid) {
        [weakSelf broadcastDeleteComment:rid];
    } error:^(NSInteger errorCode) {
        [weakSelf broadcastDeleteComment:r Failed:errorCode];
    }];
}

- (void)postVoteWithPollModel:(WLPollPost *)pollModel
                  choiceArray:(NSArray<WLVoteModel *> *)choiceArray
                     isRepost:(BOOL)isRepost
                     finished:(void (^)(BOOL succeed, WLPollPost *pollModel))finished {
    WLPollRequest *pollRequest = [[WLPollRequest alloc] initWithUserID:[AppContext getInstance].accountManager.myAccount.uid];
    [pollRequest postVoteWithPollModel:pollModel
                           choiceArray:choiceArray
                              isRepost:isRepost
                             successed:^(WLPollPost * _Nonnull pollModel) {
                                 if (finished) {
                                     finished(YES, pollModel);
                                 }
                             }
                                 error:^(NSInteger errorCode) {
                                     if (finished) {
                                         finished(NO, nil);
                                     }
                                 }];
}

- (void)broadcastDeletePost:(NSString *)pid
{
    @synchronized (self.deleteMap)
    {
        [self.deleteMap removeObjectForKey:pid];
    }
    @synchronized (_delegates)
    {
        for (int i = 0; i < [_delegates count]; i++)
        {
            id<WLSingleContentManagerDelegate> delegate = [_delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(onPostDeleted:)])
            {
                [delegate onPostDeleted:pid];
            }
        }
    }
}

- (void)broadcastDeletePost:(NSString *)pid Failed:(NSInteger)errCode
{
    @synchronized (self.deleteMap)
    {
        [self.deleteMap removeObjectForKey:pid];
    }
    @synchronized (_delegates)
    {
        for (int i = 0; i < [_delegates count]; i++)
        {
            id<WLSingleContentManagerDelegate> delegate = [_delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(onPostDeleted:error:)])
            {
                [delegate onPostDeleted:pid error:errCode];
            }
        }
    }
}

- (void)broadcastDeleteComment:(NSString *)cid
{
    @synchronized (self.deleteMap)
    {
        [self.deleteMap removeObjectForKey:cid];
    }
    @synchronized (_delegates)
    {
        for (int i = 0; i < [_delegates count]; i++)
        {
            id<WLSingleContentManagerDelegate> delegate = [_delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(onCommentDeleted:)])
            {
                [delegate onCommentDeleted:cid];
            }
        }
    }
}

- (void)broadcastDeleteComment:(NSString *)cid Failed:(NSInteger)errCode
{
    @synchronized (self.deleteMap)
    {
        [self.deleteMap removeObjectForKey:cid];
    }
    @synchronized (_delegates)
    {
        for (int i = 0; i < [_delegates count]; i++)
        {
            id<WLSingleContentManagerDelegate> delegate = [_delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(onCommentDeleted:error:)])
            {
                [delegate onCommentDeleted:cid error:errCode];
            }
        }
    }
}

@end
