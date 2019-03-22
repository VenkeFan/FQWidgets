//
//  WLSingleUserManager.h
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLUser;
@class WLContact;

@protocol WLSingleUserManagerDelegate <NSObject>

@optional
- (void)onUser:(NSString *)uid followEnd:(NSInteger)errCode;
- (void)onUser:(NSString *)uid unfollowEnd:(NSInteger)errCode;

@end

typedef void(^userDetailSuccessed)(WLUser *user);
typedef void(^userDetailFailed)(NSString *uid, NSInteger errCode);

@interface WLSingleUserManager : NSObject

- (void)registerDelegate:(id<WLSingleUserManagerDelegate>)delegate;
- (void)unregister:(id<WLSingleUserManagerDelegate>)delegate;
- (void)follow:(WLContact *)user;
- (void)unfollow:(NSString *)uid;
- (BOOL)isFollowing:(NSString *)uid;
- (BOOL)isUnfollowing:(NSString *)uid;
- (void)loadUserDetailWithUid:(NSString *)uid successed:(userDetailSuccessed)successed error:(userDetailFailed)error;
- (void)blockUserWithUid:(NSString *)uid;
- (void)unblockUserWithUid:(NSString *)uid;

@end
