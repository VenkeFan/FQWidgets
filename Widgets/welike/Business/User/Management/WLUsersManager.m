//
//  WLUsersManager.m
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUsersManager.h"
#import "WLFollowedUsersProvider.h"
#import "WLFollowingUsersProvider.h"
#import "WLPostLikeUsersProvider.h"
#import "WLUserRecommendRequest.h"
#import "WLRemoveRecommendRequest.h"
#import "WLPinRequest.h"

@interface WLUsersManager () <WLUsersProviderDelegate>

@property (nonatomic, strong) id<WLUsersProvider> provider;

- (NSArray *)convertUserListToLayoutModelList:(NSArray *)users;

@end

@implementation WLUsersManager

- (void)setDataSourceProvider:(id<WLUsersProvider>)provider
{
    if (self.provider != nil)
    {
        [self.provider stop];
        [self.provider setListener:nil];
    }
    self.provider = provider;
    [self.provider setListener:self];
}

- (void)tryRefreshUsersWithKeyId:(NSString *)kid
{
    if (self.provider != nil)
    {
        [self.provider tryRefreshUsersWithKeyId:kid];
    }
}

- (void)tryHisUsersWithKeyId:(NSString *)kid
{
    if (self.provider != nil)
    {
        [self.provider tryHisUsersWithKeyId:kid];
    }
}

- (void)removeRecommendUser:(NSString *)userID {
    if (userID.length == 0) {
        return;
    }
    
    WLRemoveRecommendRequest *request = [[WLRemoveRecommendRequest alloc] init];
    [request removeRecommendWithUserID:userID
                               succeed:^{
                                   
                               }
                                failed:^(NSInteger errorCode) {
                                    
                                }];
}

-(void)pinPost:(NSString *)pid complete:(pinCompleted)complete
{
    WLPinRequest *request = [[WLPinRequest alloc] initPin:pid];
    
    [request pinPost:pid succeed:^(BOOL result) {
       
        if (complete)
        {
            complete(YES,ERROR_SUCCESS);
        }
        
        
    } failed:^(NSInteger errorCode) {
        
        if (complete)
        {
            complete(NO,errorCode);
        }
    }];
}


-(void)unPinPost:(NSString *)pid complete:(pinCompleted)complete
{
    WLPinRequest *request = [[WLPinRequest alloc] initUnPin:pid];
    
    [request unPinPost:pid succeed:^(BOOL result) {
       
        if (complete)
        {
            complete(YES,ERROR_SUCCESS);
        }
        
    } failed:^(NSInteger errorCode) {
        
        if (complete)
        {
            complete(NO,errorCode);
        }
    }];
}

#pragma mark WLUsersProviderDelegate methods
- (void)onRefreshUsersProvider:(id<WLUsersProvider>)provider users:(NSArray *)users kid:(NSString *)kid newCount:(NSInteger)newCount last:(BOOL)last errCode:(NSInteger)errCode
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onRefreshManager:users:kid:newCount:last:errCode:)])
            {
                [weakSelf.delegate onRefreshManager:weakSelf users:users kid:kid newCount:newCount last:last errCode:errCode];
            }
        });
    });
}

- (void)onReceiveHisUsersProvider:(id<WLUsersProvider>)provider users:(NSArray *)users kid:(NSString *)kid last:(BOOL)last errCode:(NSInteger)errCode
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisManager:users:kid:last:errCode:)])
            {
                [weakSelf.delegate onReceiveHisManager:weakSelf users:users kid:kid last:last errCode:errCode];
            }
        });
    });
}

#pragma mark private methods
- (NSArray *)convertUserListToLayoutModelList:(NSArray *)users
{
    return nil;
}

@end
