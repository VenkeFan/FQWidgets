//
//  WLFollowButton.m
//  welike
//
//  Created by fan qi on 2018/5/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFollowButton.h"
#import "WLSingleUserManager.h"
#import "WLContactsManager.h"
#import "WLUser.h"
#import "WLPostBase.h"
#import "WLAlertController.h"
#import "WLDynamicLoadingView.h"
#import "WLTrackerFollow.h"
#import "WLTrackerLogin.h"

@interface WLFollowButton() <WLSingleUserManagerDelegate>

@property (nonatomic, strong) WLDynamicLoadingView *loadingView;

@property (nonatomic, strong) WLSingleUserManager *manager;
@property (nonatomic, copy) NSString *userID;

@end

@implementation WLFollowButton

- (instancetype)init {
    if (self = [self initWithFrame:kFollowDefaultFrame]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = kCornerRadius;
        self.tintColor = [UIColor clearColor];
        
        self.titleLabel.font = kBoldFont(kLightFontSize);
        [self addTarget:self action:@selector(selfOnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)dealloc {
    [_manager unregister:self];
}

#pragma mark - Public

- (void)setUser:(WLUser *)user {
    _user = user;
    self.userID = user.uid;
    
    [self p_setTypeWithFollowing:user.following followed:user.follower];
}

- (void)setFeedModel:(WLPostBase *)feedModel {
    _feedModel = feedModel;
    self.userID = feedModel.uid;
    
    [self p_setTypeWithFollowing:feedModel.following followed:feedModel.follower];
}

- (void)setLoading:(BOOL)loading {
    if (loading == _loading) {
        return;
    }
    
    _loading = loading;
    
    if (loading) {
        switch (self.type) {
            case WLFollowButtonType_Friends:
            case WLFollowButtonType_Following: {
                self.loadingView.tintColor = kMainColor;
            }
                break;
            case WLFollowButtonType_None:
            case WLFollowButtonType_Followed:
                self.loadingView.tintColor = [UIColor whiteColor];
                break;
        }
        
        UIImage *loadingImg = [AppContext getImageForKey:@"common_loading"];
        loadingImg = [loadingImg resizeWithSize:CGSizeMake(self.titleLabel.font.pointSize, self.titleLabel.font.pointSize)];
        loadingImg = [loadingImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self setImage:loadingImg forState:UIControlStateNormal];
        [self setTitle:nil forState:UIControlStateNormal];
        
        [self.imageView addSubview:self.loadingView];
        [self.loadingView startAnimating];
    } else {
        [self.loadingView stopAnimating];
        [self.loadingView removeFromSuperview];
        
        if ([self.user.uid isEqualToString:self.userID]) {
            [self p_setTypeWithFollowing:self.user.following followed:self.user.follower];
        } else if ([self.feedModel.uid isEqualToString:self.userID]) {
            [self p_setTypeWithFollowing:self.feedModel.following followed:self.feedModel.follower];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(followButtonLoadingChanged:)]) {
        [self.delegate followButtonLoadingChanged:self];
    }
}

#pragma mark - Network

- (void)postFollow {
    WLContact *contact = nil;
    if (self.user != nil) {
        contact = [[WLContact alloc] init];
        contact.uid = self.userID;
        contact.nickName = self.user.nickName;
        contact.head = self.user.headUrl;
        contact.gender = self.user.gender;
        contact.create = self.user.createdTime;
        contact.vip = self.user.vip;
    } else if (self.feedModel != nil) {
        contact = [[WLContact alloc] init];
        contact.uid = self.userID;
        contact.nickName = self.feedModel.nickName;
        contact.head = self.feedModel.headUrl;
        contact.gender = self.feedModel.gender;
        contact.create = self.feedModel.userCreateTime;
        contact.vip = self.feedModel.vip;
    }
    
    if (contact != nil) {
        if (self.isLoading) {
            return;
        }
        
        [self.manager follow:contact];
        [self setLoading:[self.manager isFollowing:self.userID]];
        
        [WLTrackerFollow appendTrackerWithFollowAction:WLTrackerFollowAction_Follow
                                                  post:self.feedModel
                                                userID:self.userID];
    }
}

- (void)postUnFollow {
    if (self.isLoading) {
        return;
    }
    
    [self.manager unfollow:self.userID];
    [self setLoading:[self.manager isUnfollowing:self.userID]];
    
    [WLTrackerFollow appendTrackerWithFollowAction:WLTrackerFollowAction_UnFollow
                                              post:self.feedModel
                                            userID:self.userID];
}

#pragma mark - WLSingleUserManagerDelegate

- (void)onUser:(NSString *)uid followEnd:(NSInteger)errCode {
    [self setLoading:[self.manager isFollowing:self.userID]];
    
    if (errCode != ERROR_SUCCESS) {
        [[AppContext currentViewController] showToastWithNetworkErr:errCode];
        return;
    }
    
    if (errCode == ERROR_SUCCESS) {
        if ([self.user.uid isEqualToString:uid]) {
            self.user.following = YES;
            
            if ([self.delegate respondsToSelector:@selector(followButtonFinished:)]) {
                [self.delegate followButtonFinished:self];
            }
            
            [self p_setTypeWithFollowing:self.user.following followed:self.user.follower];

        } else if ([self.feedModel.uid isEqualToString:uid]) {
            self.feedModel.following = YES;
            
            if ([self.delegate respondsToSelector:@selector(followButtonFinished:)]) {
                [self.delegate followButtonFinished:self];
            }
            
            [self p_setTypeWithFollowing:self.feedModel.following followed:self.feedModel.follower];
        }
    }
}

- (void)onUser:(NSString *)uid unfollowEnd:(NSInteger)errCode {
    [self setLoading:[self.manager isUnfollowing:self.userID]];
    
    if (errCode != ERROR_SUCCESS) {
        [[AppContext currentViewController] showToastWithNetworkErr:errCode];
        return;
    }
    
    if (errCode == ERROR_SUCCESS) {
        if ([self.user.uid isEqualToString:uid]) {
            self.user.following = NO;
            [self p_setTypeWithFollowing:self.user.following followed:self.user.follower];

        } else if ([self.feedModel.uid isEqualToString:uid]) {
            self.feedModel.following = NO;
            [self p_setTypeWithFollowing:self.feedModel.following followed:self.feedModel.follower];
        }
        
        if ([self.delegate respondsToSelector:@selector(followButtonFinished:)]) {
            [self.delegate followButtonFinished:self];
        }
    }
}

#pragma mark - Event

- (void)selfOnClicked {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Follow];
    kNeedLogin
    
    switch (self.type) {
        case WLFollowButtonType_Friends:
        case WLFollowButtonType_Following: {
            WLAlertController *alert = [WLAlertController alertControllerWithTitle:[AppContext getStringForKey:@"user_follow_dialog_title" fileName:@"user"]
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"common_cancel" fileName:@"common"]
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                    }]];
            [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"common_confirm" fileName:@"common"]
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [self postUnFollow];
                                                    }]];
            
            [[AppContext rootViewController] presentViewController:alert animated:YES completion:nil];
        }
            break;
        case WLFollowButtonType_None:
        case WLFollowButtonType_Followed:
            [self postFollow];
            break;
    }
}

#pragma mark - Private

- (void)p_setTypeWithFollowing:(BOOL)following followed:(BOOL)followed {
    if (following && followed) {
        [self setType:WLFollowButtonType_Friends];
    } else if (following) {
        [self setType:WLFollowButtonType_Following];
    } else if (followed) {
        [self setType:WLFollowButtonType_Followed];
    } else {
        [self setType:WLFollowButtonType_None];
    }
}

#pragma mark - Setter

- (void)setType:(WLFollowButtonType)type {
    _type = type;
    
    if (self.isLoading) {
        return;
    }
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = kMainColor.CGColor;
    [self setTitleColor:kMainColor forState:UIControlStateNormal];
    
    switch (type) {
        case WLFollowButtonType_Friends:
            [self setImage:nil forState:UIControlStateNormal];
            [self setTitle:[[AppContext getStringForKey:@"friends_btn_text" fileName:@"common"] uppercaseString] forState:UIControlStateNormal];
            break;
        case WLFollowButtonType_Following:
            [self setImage:nil forState:UIControlStateNormal];
            [self setTitle:[[AppContext getStringForKey:@"following_btn_text" fileName:@"common"] uppercaseString] forState:UIControlStateNormal];
            break;
        case WLFollowButtonType_None:
        case WLFollowButtonType_Followed:
            [self setImage:nil forState:UIControlStateNormal];
            [self setTitle:[[AppContext getStringForKey:@"follow_btn_text" fileName:@"common"] uppercaseString] forState:UIControlStateNormal];
            
            self.backgroundColor = kMainColor;
            self.layer.borderWidth = 0.0;
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
    }
    
    [self.imageView.layer removeAllAnimations];
}

#pragma mark - Getter

- (WLSingleUserManager *)manager {
    if (!_manager) {
        _manager = [AppContext getInstance].singleUserManager;
        [_manager registerDelegate:self];
    }
    return _manager;
}

- (WLDynamicLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[WLDynamicLoadingView alloc] initWithFrame:CGRectMake(0, 0, self.titleLabel.font.pointSize, self.titleLabel.font.pointSize)];
        _loadingView.lineWidth = 2.0;
    }
    return _loadingView;
}

@end
