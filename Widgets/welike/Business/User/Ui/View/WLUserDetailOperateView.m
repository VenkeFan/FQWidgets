//
//  WLUserDetailOperateView.m
//  welike
//
//  Created by fan qi on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUserDetailOperateView.h"
#import "WLUser.h"
#import "WLSingleUserManager.h"
#import "WLContactsManager.h"
#import "WLAlertController.h"

@interface WLUserDetailOperateView () <WLSingleUserManagerDelegate> {
    BOOL _viewLoaded;
}

@property (nonatomic, strong) UIButton *followBtn;
@property (nonatomic, strong) UIButton *msgBtn;

@property (nonatomic, strong) WLSingleUserManager *manager;
@property (nonatomic, assign, getter=isLoading) BOOL loading;

@property (nonatomic, strong) CABasicAnimation *rotationAnimation;

@end

@implementation WLUserDetailOperateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _viewLoaded = NO;
    }
    return self;
}

- (void)layoutUI {
    if (_viewLoaded) {
        return;
    }
    _viewLoaded = YES;
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
    self.layer.shadowOffset = CGSizeMake(0, -1);
    self.layer.shadowOpacity = 0.1;
//    self.layer.shadowPath = CGPathCreateWithRect(self.frame, NULL);
    
    self.followBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds) * 0.5, kUserDetailOperateContentHeight);
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
        btn.titleLabel.font = kBoldFont(kNameFontSize);
        [btn addTarget:self action:@selector(followBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        btn;
    });
    
    UIView *separateLine = [[UIView alloc] init];
    separateLine.backgroundColor = kSeparateLineColor;
    separateLine.frame = CGRectMake(CGRectGetWidth(self.followBtn.frame), 8, 1, kUserDetailOperateContentHeight - 16);
    [self addSubview:separateLine];
    
    self.msgBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(CGRectGetWidth(self.followBtn.frame), 0, CGRectGetWidth(self.bounds) * 0.5, kUserDetailOperateContentHeight);
        [btn setTitle:[AppContext getStringForKey:@"mine_user_host_bottom_message" fileName:@"user"] forState:UIControlStateNormal];
        [btn setTitleColor:kLightFontColor forState:UIControlStateNormal];
        btn.titleLabel.font = kBoldFont(kNameFontSize);
        [btn addTarget:self action:@selector(msgBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        btn;
    });
}

- (void)dealloc {
    [_manager unregister:self];
}

#pragma mark - Public

- (void)setUser:(WLUser *)user {
    _user = user;
    
    [self layoutUI];
    [self p_setFollowTitleWithUser:user];
}

#pragma mark - Network

- (void)postFollow {
    WLContact *contact = nil;
    if (self.user != nil)
    {
        contact = [[WLContact alloc] init];
        contact.uid = self.user.uid;
        contact.nickName = self.user.nickName;
        contact.head = self.user.headUrl;
        contact.gender = self.user.gender;
        contact.create = self.user.createdTime;
        contact.vip = self.user.vip;
    }
    if (contact != nil)
    {
        [self.manager follow:contact];
        [self setLoading:[self.manager isFollowing:self.user.uid]];
    }
}

- (void)postUnFollow {
    [self.manager unfollow:self.user.uid];
    [self setLoading:[self.manager isUnfollowing:self.user.uid]];
}

#pragma mark - WLSingleUserManagerDelegate

- (void)onUser:(NSString *)uid followEnd:(NSInteger)errCode {
    [self setLoading:[self.manager isFollowing:self.user.uid]];
    
    if (errCode != ERROR_SUCCESS) {
        [[AppContext currentViewController] showToastWithNetworkErr:errCode];
        return;
    }
    
    if (errCode == ERROR_SUCCESS) {
        if ([self.user.uid isEqualToString:uid]) {
            self.user.following = YES;
            [self p_setFollowTitleWithUser:self.user];
        }
    }
}

- (void)onUser:(NSString *)uid unfollowEnd:(NSInteger)errCode {
    [self setLoading:[self.manager isUnfollowing:self.user.uid]];
    
    if (errCode != ERROR_SUCCESS) {
        [[AppContext currentViewController] showToastWithNetworkErr:errCode];
        return;
    }
    
    if (errCode == ERROR_SUCCESS) {
        if ([self.user.uid isEqualToString:uid]) {
            self.user.following = NO;
            [self p_setFollowTitleWithUser:self.user];
        }
    }
}

#pragma mark - Event

- (void)followBtnClicked {
    if (self.user.following) {
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
        
    } else {
        [self postFollow];
    }
}

- (void)msgBtnClicked {
    if ([self.delegate respondsToSelector:@selector(userDetailOperateViewDidClickSendMsg:)]) {
        [self.delegate userDetailOperateViewDidClickSendMsg:self];
    }
}

#pragma mark - Private

- (void)p_setFollowTitleWithUser:(WLUser *)user {
    if (user.following && user.follower) {
        [self.followBtn setImage:nil forState:UIControlStateNormal];
        [self.followBtn setTitle:[AppContext getStringForKey:@"friends_btn_text" fileName:@"common"] forState:UIControlStateNormal];
        [self.followBtn setTitleColor:kLightFontColor forState:UIControlStateNormal];
    } else if (user.following) {
        [self.followBtn setImage:nil forState:UIControlStateNormal];
        [self.followBtn setTitle:[AppContext getStringForKey:@"following_btn_text" fileName:@"common"] forState:UIControlStateNormal];
        [self.followBtn setTitleColor:kLightFontColor forState:UIControlStateNormal];
    } else {
        [self.followBtn setImage:[AppContext getImageForKey:@"common_add"] forState:UIControlStateNormal];
        [self.followBtn setTitle:[AppContext getStringForKey:@"follow_btn_text" fileName:@"common"] forState:UIControlStateNormal];
        [self.followBtn setTitleColor:kUIColorFromRGB(0xFFB81A) forState:UIControlStateNormal];
    }
    [self.followBtn.imageView.layer removeAllAnimations];
}

#pragma mark - Setter

- (void)setLoading:(BOOL)loading {
    if (_loading == loading) {
        return;
    }
    
    _loading = loading;
    
    if (loading) {
        UIImage *loadingImg = [AppContext getImageForKey:@"common_loading"];
        loadingImg = [loadingImg resizeWithSize:CGSizeMake(kNameFontSize, kNameFontSize)];
        [self.followBtn setImage:loadingImg forState:UIControlStateNormal];
        [self.followBtn.imageView.layer addAnimation:self.rotationAnimation forKey:nil];
    } else {
        [self p_setFollowTitleWithUser:self.user];
    }
}

#pragma mark - Getter

- (WLSingleUserManager *)manager {
    if (!_manager) {
        _manager = [AppContext getInstance].singleUserManager;
        [_manager registerDelegate:self];
    }
    return _manager;
}

- (CABasicAnimation *)rotationAnimation {
    if (!_rotationAnimation) {
        _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
        _rotationAnimation.duration = 1.0;
        _rotationAnimation.repeatCount = INFINITY;
        _rotationAnimation.autoreverses = NO;
        _rotationAnimation.removedOnCompletion = NO;
        _rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
    return _rotationAnimation;
}

@end
