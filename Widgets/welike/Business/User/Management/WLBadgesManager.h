//
//  WLBadgesManager.h
//  welike
//
//  Created by fan qi on 2019/2/20.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLBadgesManager;

@protocol WLBadgesManagerDelegate <NSObject>

- (void)badgesManagerFetch:(WLBadgesManager *)manager
                 dataArray:(NSArray *)dataArray
                   errCode:(NSInteger)errCode;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WLBadgesManager : NSObject

- (void)fetchAllBadgesWithUserID:(NSString *)userID;
- (void)fetchUserBadgesWithUserID:(NSString *)userID;
- (void)wearBadgeWithUserID:(NSString *)userID
                 newBadgeID:(NSString *)newBadgeID
                 oldBadgeID:(NSString *)oldBadgeID
                      index:(NSInteger)index
                   finished:(void(^)(BOOL succeed))finished;

@property (nonatomic, weak) id<WLBadgesManagerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
