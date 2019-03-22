//
//  WLUserFollowTabView.m
//  welike
//
//  Created by fan qi on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUserFollowTabView.h"
#import "WLUserBase.h"

#define shitYellowColor          kUIColorFromRGB(0xB06E00)

@interface WLUserFollowTabView ()

@property (nonatomic, weak) UILabel *followLabel;
@property (nonatomic, weak) UILabel *followerLabel;
@property (nonatomic, weak) UILabel *praiseLabel;

@end

@implementation WLUserFollowTabView

- (instancetype)init {
    if (self = [self initWithFrame:CGRectMake(0, 0, kScreenWidth, kUserFollowTabViewHeight)]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.width == 0) {
        frame.size.width = kScreenWidth;
    }
    if (frame.size.height == 0) {
        frame.size.height = kUserFollowTabViewHeight;
    }
    
    if (self = [super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat width = CGRectGetWidth(self.bounds) / 3.0, height = CGRectGetHeight(self.bounds);
    
    UIView *followBtn = [self viewWithFrame:CGRectMake(0, 0, width, height)
                                      title:[AppContext getStringForKey:@"following_btn_text" fileName:@"common"]
                                      count:_user.followUsersCount
                                 countLabel:&_followLabel
                                     action:@selector(followingTapped)];
    [self addSubview:followBtn];
    
    UIView *line1 = [self lineView];
    line1.center = CGPointMake(width, CGRectGetHeight(self.bounds) * 0.5);
    [self addSubview:line1];
    
    UIView *followerBtn = [self viewWithFrame:CGRectMake(width, 0, width, height)
                                        title:[AppContext getStringForKey:@"mine_follower_num_text" fileName:@"user"]
                                        count:_user.followedUsersCount
                                   countLabel:&_followerLabel
                                       action:@selector(followerTapped)];
    [self addSubview:followerBtn];
    
    UIView *line2 = [self lineView];
    line2.center = CGPointMake(width * 2, CGRectGetHeight(self.bounds) * 0.5);
    [self addSubview:line2];
    
    UIView *praiseBtn = [self viewWithFrame:CGRectMake(width * 2, 0, width, height)
                                      title:[AppContext getStringForKey:@"mine_post_num_text" fileName:@"user"]
                                      count:_user.postsCount
                                 countLabel:&_praiseLabel
                                     action:@selector(praiseTapped)];
    [self addSubview:praiseBtn];
}

- (UIView *)viewWithFrame:(CGRect)frame
                    title:(NSString *)title
                    count:(NSInteger)count
               countLabel:(__weak UILabel **)countLabel
                   action:(SEL)action {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    [view addGestureRecognizer:tap];
    
    UILabel *countLab = [[UILabel alloc] init];
    countLab.text = [NSString stringWithFormat:@"%ld", (long)count];
    countLab.textColor = kNameFontColor;
    countLab.font = kBoldFont(kNameFontSize);
    countLab.textAlignment = NSTextAlignmentCenter;
    countLab.numberOfLines = 1;
    countLab.frame = CGRectMake(0, 0, CGRectGetWidth(frame), kNameFontSize + 4);
    countLab.center = CGPointMake(CGRectGetWidth(frame) * 0.5, 10 + CGRectGetHeight(countLab.bounds) * 0.5);
    [view addSubview:countLab];
    if (countLabel) {
        *countLabel = countLab;
    }
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = title;
    titleLab.textColor = kLightLightFontColor;
    titleLab.font = kRegularFont(kLightFontSize);
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.numberOfLines = 1;
    [titleLab sizeToFit];
    titleLab.center = CGPointMake(countLab.center.x, 4 + CGRectGetMaxY(countLab.frame) + CGRectGetHeight(titleLab.frame) * 0.5);
    [view addSubview:titleLab];
    
    return view;
}

- (UIView *)lineView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 27)];
    view.backgroundColor = kUIColorFromRGB(0xF0F0F0);
    return view;
}

#pragma mark - Public

- (void)setUser:(WLUserBase *)user {
    _user = user;
    
    _followLabel.text = [NSString stringWithFormat:@"%ld", (long)_user.followUsersCount];
    _followerLabel.text = [NSString stringWithFormat:@"%ld", (long)_user.followedUsersCount];
    _praiseLabel.text = [NSString stringWithFormat:@"%ld", (long)_user.postsCount];
}

#pragma mark - Event

- (void)followingTapped {
    if ([self.delegate respondsToSelector:@selector(userFollowTabViewDidSelectedFollowing:)]) {
        [self.delegate userFollowTabViewDidSelectedFollowing:self];
    }
}

- (void)followerTapped {
    if ([self.delegate respondsToSelector:@selector(userFollowTabViewDidSelectedFollowed:)]) {
        [self.delegate userFollowTabViewDidSelectedFollowed:self];
    }
}

- (void)praiseTapped {
    if ([self.delegate respondsToSelector:@selector(userFollowTabViewDidSelectedPosts:)]) {
        [self.delegate userFollowTabViewDidSelectedPosts:self];
    }
}

@end
