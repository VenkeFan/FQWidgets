//
//  WLSingleContentManager.h
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLPostBase;
@class WLComment;
@class WLPollPost;
@class WLVoteModel;

typedef NS_ENUM(NSInteger, WLSuperLikeType) {
    WLSuperLikeType_Feed,
    WLSuperLikeType_FeedDetail
};

@protocol WLSingleContentManagerDelegate <NSObject>

@optional
- (void)onPostDeleted:(NSString *)pid;
- (void)onPostDeleted:(NSString *)pid error:(NSInteger)errCode;
- (void)onCommentDeleted:(NSString *)cid;
- (void)onCommentDeleted:(NSString *)cid error:(NSInteger)errCode;

@end

@interface WLSingleContentManager : NSObject

- (void)registerDelegate:(id<WLSingleContentManagerDelegate>)delegate;
- (void)unregister:(id<WLSingleContentManagerDelegate>)delegate;
- (void)likePost:(WLPostBase *)post;
- (void)superLikePost:(WLPostBase *)post exp:(long long)exp;
+ (NSInteger)convertSuperLikeLevelWithExp:(long long)exp;
+ (UIImage *)superLikeImageWithExp:(long long)exp;
+ (UIImage *)superLikeImageWithExp:(long long)exp imgType:(WLSuperLikeType)imgType;
- (void)dislikePost:(WLPostBase *)post;
- (void)likeComment:(NSString *)cid;
- (void)dislikeComment:(NSString *)cid;
- (void)likeReply:(NSString *)rid;
- (void)dislikeReply:(NSString *)rid;
- (void)deletePost:(WLPostBase *)post;
- (void)deleteComment:(WLComment *)comment;
- (void)deleteReply:(WLComment *)comment;

- (void)postVoteWithPollModel:(WLPollPost *)pollModel
                  choiceArray:(NSArray<WLVoteModel *> *)choiceArray
                     isRepost:(BOOL)isRepost
                     finished:(void(^)(BOOL succeed, WLPollPost *pollModel))finished;

@end
