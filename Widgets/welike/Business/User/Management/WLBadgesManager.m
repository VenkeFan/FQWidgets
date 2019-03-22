//
//  WLBadgesManager.m
//  welike
//
//  Created by fan qi on 2019/2/20.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLBadgesManager.h"
#import "WLBadgeRequest.h"
#import "WLUserBadgesRequest.h"
#import "WLUserWearBadgeRequest.h"

@interface WLBadgesManager ()

@property (nonatomic, strong) WLBadgeRequest *allRequest;
@property (nonatomic, strong) WLUserBadgesRequest *userRequest;
@property (nonatomic, strong) WLUserWearBadgeRequest *wearRequest;

@end

@implementation WLBadgesManager

- (void)fetchAllBadgesWithUserID:(NSString *)userID {
    if (userID.length == 0) {
        return;
    }
    
    if (_allRequest) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    _allRequest = [[WLBadgeRequest alloc] initWithUserID:userID];
    [_allRequest requestAllBadgesWithSucceed:^(NSArray *dataArray) {
        weakSelf.allRequest = nil;
        
        if ([weakSelf.delegate respondsToSelector:@selector(badgesManagerFetch:dataArray:errCode:)]) {
            [weakSelf.delegate badgesManagerFetch:weakSelf dataArray:dataArray errCode:ERROR_SUCCESS];
        }
        
    } failed:^(NSInteger errorCode) {
        weakSelf.allRequest = nil;
        
        if ([weakSelf.delegate respondsToSelector:@selector(badgesManagerFetch:dataArray:errCode:)]) {
            [weakSelf.delegate badgesManagerFetch:weakSelf dataArray:nil errCode:errorCode];
        }
    }];
}

- (void)fetchUserBadgesWithUserID:(NSString *)userID {
    if (userID.length == 0) {
        return;
    }
    
    if (_userRequest) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    _userRequest = [[WLUserBadgesRequest alloc] initWithUserID:userID];
    [_userRequest requestUserBadgesWithSucceed:^(NSArray *dataArray) {
        weakSelf.userRequest = nil;
        
        if ([weakSelf.delegate respondsToSelector:@selector(badgesManagerFetch:dataArray:errCode:)]) {
            [weakSelf.delegate badgesManagerFetch:weakSelf dataArray:dataArray errCode:ERROR_SUCCESS];
        }
        
    } failed:^(NSInteger errorCode) {
        weakSelf.userRequest = nil;
        
        if ([weakSelf.delegate respondsToSelector:@selector(badgesManagerFetch:dataArray:errCode:)]) {
            [weakSelf.delegate badgesManagerFetch:weakSelf dataArray:nil errCode:errorCode];
        }
    }];
}

- (void)wearBadgeWithUserID:(NSString *)userID
                 newBadgeID:(NSString *)newBadgeID
                 oldBadgeID:(NSString *)oldBadgeID
                      index:(NSInteger)index
                   finished:(void(^)(BOOL succeed))finished {
    if (userID.length <= 0 || newBadgeID.length <= 0 || oldBadgeID.length <= 0) {
        return;
    }
    
    if (_wearRequest) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    _wearRequest = [[WLUserWearBadgeRequest alloc] init];
    [_wearRequest wearBadgeWithUserID:userID
                           newBadgeID:newBadgeID
                           oldBadgeID:oldBadgeID
                                index:index
                              succeed:^(NSDictionary * _Nonnull dic) {
                                  weakSelf.wearRequest = nil;
                                  
                                  if (finished) {
                                      finished(YES);
                                  }
                              }
                               failed:^(NSInteger errorCode) {
                                   weakSelf.wearRequest = nil;
                                   
                                   if (finished) {
                                       finished(NO);
                                   }
                               }];
}

@end
