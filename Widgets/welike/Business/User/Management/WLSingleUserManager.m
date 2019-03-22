//
//  WLSingleUserManager.m
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSingleUserManager.h"
#import "WLFollowUserRequest.h"
#import "WLUnfollowUserRequest.h"
#import "WLUserDetailRequest.h"
#import "WLBlockUserRequest.h"
#import "WLUnblockUserRequest.h"
#import "WLAccountManager.h"
#import "WLContactsManager.h"
#import "WLUser.h"
#import "WLMessageManager.h"

@interface WLSingleUserManager ()

@property (nonatomic, strong) NSPointerArray *delegates;
@property (nonatomic, strong) NSMutableArray *followRequests;
@property (nonatomic, strong) NSMutableArray *unfollowRequests;

- (void)broadcastFollowUser:(NSString *)uid;
- (void)broadcastFollowUser:(NSString *)uid Failed:(NSInteger)errCode;
- (void)broadcastUnfollowUser:(NSString *)uid;
- (void)broadcastUnfollowUser:(NSString *)uid Failed:(NSInteger)errCode;
- (void)removeFollowRequestByUid:(NSString *)uid;
- (void)removeUnfollowRequestByUid:(NSString *)uid;

@end

@implementation WLSingleUserManager

- (id)init
{
    self = [super init];
    if (self)
    {
        self.followRequests = [NSMutableArray array];
        self.unfollowRequests = [NSMutableArray array];
        self.delegates = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

- (void)registerDelegate:(id<WLSingleUserManagerDelegate>)delegate
{
    @synchronized (self.delegates)
    {
        if ([self.delegates containsObject:delegate] == NO)
        {
            [self.delegates addObject:delegate];
        }
    }
}

- (void)unregister:(id<WLSingleUserManagerDelegate>)delegate
{
    @synchronized (self.delegates)
    {
        [self.delegates removeObject:delegate];
    }
}

- (void)follow:(WLContact *)user
{
    if ([self isFollowing:user.uid] == YES) return;
    
    __weak typeof(self) weakSelf = self;
    WLAccount *myAccount = [[AppContext getInstance].accountManager myAccount];
    WLFollowUserRequest *request = [[WLFollowUserRequest alloc] initFollowUserRequestWithMyUid:myAccount.uid toUid:user.uid];
    [self.followRequests addObject:request];
    [request followSuccessed:^(NSString *uid) {
        [[AppContext getInstance].contactsManager addContact:user];
        [weakSelf broadcastFollowUser:uid];
    } error:^(NSInteger errorCode) {
        [weakSelf broadcastFollowUser:request.uid Failed:errorCode];
    }];
}

- (void)unfollow:(NSString *)uid
{
    if ([self isUnfollowing:uid] == YES) return;
    
    __weak typeof(self) weakSelf = self;
    WLAccount *myAccount = [[AppContext getInstance].accountManager myAccount];
    WLUnfollowUserRequest *request = [[WLUnfollowUserRequest alloc] initUnfollowUserRequestWithMyUid:myAccount.uid toUid:uid];
    [self.unfollowRequests addObject:request];
    [request unfollowSuccessed:^(NSString *uid) {
        [[AppContext getInstance].contactsManager removeContactWithUid:uid];
        [weakSelf broadcastUnfollowUser:uid];
    } error:^(NSInteger errorCode) {
        [weakSelf broadcastUnfollowUser:request.uid Failed:errorCode];
    }];
}

- (BOOL)isFollowing:(NSString *)uid
{
    BOOL res = NO;
    @synchronized (self.followRequests)
    {
        for (NSInteger i = 0; i < [self.followRequests count]; i++)
        {
            WLFollowUserRequest *request = [self.followRequests objectAtIndex:i];
            if ([request.uid isEqualToString:uid] == YES)
            {
                res = YES;
                break;
            }
        }
    }
    return res;
}

- (BOOL)isUnfollowing:(NSString *)uid
{
    BOOL res = NO;
    @synchronized (self.unfollowRequests)
    {
        for (NSInteger i = 0; i < [self.unfollowRequests count]; i++)
        {
            WLUnfollowUserRequest *request = [self.unfollowRequests objectAtIndex:i];
            if ([request.uid isEqualToString:uid] == YES)
            {
                res = YES;
                break;
            }
        }
    }
    return res;
}

- (void)loadUserDetailWithUid:(NSString *)uid successed:(userDetailSuccessed)successed error:(userDetailFailed)error
{
    WLUserDetailRequest *request = [[WLUserDetailRequest alloc] initUserDetailRequestWithUid:uid];
    [request detailSuccessed:^(WLUser *user) {
        WLAccount *account = [[AppContext getInstance].accountManager myAccount];
        if ([account.uid isEqualToString:user.uid] == YES)
        {
            account.myLikedPostsCount = user.myLikedPostsCount;
            account.likedMyPostsCount = user.likedMyPostsCount;
            account.followedUsersCount = user.followedUsersCount;
            account.followUsersCount = user.followUsersCount;
            account.postsCount = user.postsCount;
            account.vip = user.vip;
            account.introduction = user.introduction;
            account.interests = user.interests;
            account.curLevel = user.curLevel;
            account.links = user.links;
            account.cover = user.cover;
            account.canChangeCover = user.canChangeCover;
            account.honors = user.honors;
            [[AppContext getInstance].accountManager updateAccount:account];
        }
        [[WLMessageManager instance] refreshUser:user];
        if (successed)
        {
            successed(user);
        }
    } error:^(NSInteger errorCode) {
        if (error)
        {
            error(uid, errorCode);
        }
    }];
}

- (void)blockUserWithUid:(NSString *)uid
{
    WLBlockUserRequest *request = [[WLBlockUserRequest alloc] initBlockUserRequestWithMyUid:[[AppContext getInstance].accountManager myAccount].uid blockUid:uid];
    [request blockAndSuccessed:^(NSString *uid) {
        [[AppContext getInstance].contactsManager removeContactWithUid:uid];
    } error:nil];
}

- (void)unblockUserWithUid:(NSString *)uid
{
    WLUnblockUserRequest *request = [[WLUnblockUserRequest alloc] initUnblockUserRequestWithMyUid:[[AppContext getInstance].accountManager myAccount].uid unblockUid:uid];
    [request unblockAndSuccessed:nil error:nil];
}

- (void)broadcastFollowUser:(NSString *)uid
{
    @synchronized (self.followRequests)
    {
        [self removeFollowRequestByUid:uid];
    }
    @synchronized (_delegates)
    {
        for (int i = 0; i < [_delegates count]; i++)
        {
            id<WLSingleUserManagerDelegate> delegate = [_delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(onUser:followEnd:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onUser:uid followEnd:ERROR_SUCCESS];
                });
            }
        }
    }
}

- (void)broadcastFollowUser:(NSString *)uid Failed:(NSInteger)errCode
{
    @synchronized (self.followRequests)
    {
        [self removeFollowRequestByUid:uid];
    }
    @synchronized (_delegates)
    {
        for (int i = 0; i < [_delegates count]; i++)
        {
            id<WLSingleUserManagerDelegate> delegate = [_delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(onUser:followEnd:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onUser:uid followEnd:errCode];
                });
            }
        }
    }
}

- (void)broadcastUnfollowUser:(NSString *)uid
{
    @synchronized (self.unfollowRequests)
    {
        [self removeUnfollowRequestByUid:uid];
    }
    @synchronized (_delegates)
    {
        for (int i = 0; i < [_delegates count]; i++)
        {
            id<WLSingleUserManagerDelegate> delegate = [_delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(onUser:unfollowEnd:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onUser:uid unfollowEnd:ERROR_SUCCESS];
                });
            }
        }
    }
}

- (void)broadcastUnfollowUser:(NSString *)uid Failed:(NSInteger)errCode
{
    @synchronized (self.unfollowRequests)
    {
        [self removeUnfollowRequestByUid:uid];
    }
    @synchronized (_delegates)
    {
        for (int i = 0; i < [_delegates count]; i++)
        {
            id<WLSingleUserManagerDelegate> delegate = [_delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(onUser:unfollowEnd:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onUser:uid unfollowEnd:errCode];
                });
            }
        }
    }
}

- (void)removeFollowRequestByUid:(NSString *)uid
{
    NSInteger idx = -1;
    for (NSInteger i = 0; i < [self.followRequests count]; i++)
    {
        WLFollowUserRequest *request = [self.followRequests objectAtIndex:i];
        if ([request.uid isEqualToString:uid] == YES)
        {
            idx = i;
            break;
        }
    }
    if (idx != -1)
    {
        [self.followRequests removeObjectAtIndex:idx];
    }
}

- (void)removeUnfollowRequestByUid:(NSString *)uid
{
    NSInteger idx = -1;
    for (NSInteger i = 0; i < [self.unfollowRequests count]; i++)
    {
        WLUnfollowUserRequest *request = [self.unfollowRequests objectAtIndex:i];
        if ([request.uid isEqualToString:uid] == YES)
        {
            idx = i;
            break;
        }
    }
    if (idx != -1)
    {
        [self.unfollowRequests removeObjectAtIndex:idx];
    }
}

@end
