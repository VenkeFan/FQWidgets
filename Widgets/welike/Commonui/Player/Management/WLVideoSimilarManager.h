//
//  WLVideoSimilarManager.h
//  welike
//
//  Created by fan qi on 2018/8/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLVideoSimilarManager;

@protocol WLVideoSimilarManagerDelegate <NSObject>

- (void)onRefreshManager:(WLVideoSimilarManager *)manager videos:(NSArray *)videos last:(BOOL)last errCode:(NSInteger)errCode;
- (void)onReceiveHisManager:(WLVideoSimilarManager *)manager videos:(NSArray *)videos last:(BOOL)last errCode:(NSInteger)errCode;

@end

@interface WLVideoSimilarManager : NSObject

- (instancetype)init __attribute__((unavailable("Use -initWithPostID:instead")));
+ (instancetype)new __attribute__((unavailable("Use -initWithPostID:instead")));
- (instancetype)initWithPostID:(NSString *)postID;

- (void)tryRefreshVideos;
- (void)tryHisVideos;

@property (nonatomic, weak) id<WLVideoSimilarManagerDelegate> delegate;

@end
