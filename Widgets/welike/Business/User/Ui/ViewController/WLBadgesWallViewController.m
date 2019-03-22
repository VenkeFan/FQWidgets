//
//  WLBadgesWallViewController.m
//  welike
//
//  Created by fan qi on 2019/2/20.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLBadgesWallViewController.h"
#import "WLBadgesManager.h"
#import "WLBadgeModel.h"
#import "WLSegmentedControl.h"
#import "WLHeadView.h"
#import "WLBadgeCollectionView.h"
#import "WLBadgesWearViewController.h"

@interface WLBadgesWallViewController () <WLBadgesManagerDelegate, WLSegmentedControlDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) WLBadgesManager *manager;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) WLSegmentedControl *segmentedCtr;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) WLBadgeCollectionView *socialView;
@property (nonatomic, strong) WLBadgeCollectionView *activityView;
@property (nonatomic, strong) WLBadgeCollectionView *verifiedView;

@end

@implementation WLBadgesWallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [AppContext getStringForKey:@"badges_wall_title" fileName:@"user"];
    
    [self layoutUI];
    
    [self fetchData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)layoutUI {
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, kNavBarHeight, CGRectGetWidth(self.view.frame), 176);
    headerView.layer.contents = (__bridge id)[AppContext getImageForKey:@"badges_wall_bg"].CGImage;
    headerView.layer.contentsGravity = kCAGravityResize;
    [self.view addSubview:headerView];
    
    UIView *avatarBgView = ({
        UIView *view = [[UIView alloc] init];
        UIImage *img = [AppContext getImageForKey:@"badges_avatar_bg"];
        view.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        view.center = CGPointMake(CGRectGetWidth(headerView.frame) - CGRectGetWidth(view.frame) * 0.5 - 30, CGRectGetHeight(headerView.frame) * 0.5);
        view.layer.contents = (__bridge id)img.CGImage;
        view.layer.contentsGravity = kCAGravityResize;
        
        WLHeadView *avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        avatarView.frame = CGRectMake(0, 0, 70, 70);
        avatarView.center = CGPointMake(CGRectGetWidth(view.frame) * 0.5 - 2.0,
                                        CGRectGetHeight(view.frame) * 0.5 - 4.0);
        [avatarView setHeadUrl:[AppContext getInstance].accountManager.myAccount.headUrl];
        [view addSubview:avatarView];
        
        view;
    });
    [headerView addSubview:avatarBgView];
    
    UIView *infoView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 0)];
        view.backgroundColor = [UIColor clearColor];
        
        CGFloat centerX = CGRectGetWidth(view.frame) * 0.5;
        
        _countLabel = [[UILabel alloc] init];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = kBoldFont(28);
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.text = @"0";
        [_countLabel sizeToFit];
        _countLabel.width = CGRectGetWidth(view.frame);
        _countLabel.center = CGPointMake(centerX, CGRectGetHeight(_countLabel.frame) * 0.5);
        [view addSubview:_countLabel];
        
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = [UIColor whiteColor];
        lab.font = kRegularFont(kNameFontSize);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.text = [AppContext getStringForKey:@"badges_wall_current_badges" fileName:@"user"];
        [lab sizeToFit];
        lab.center = CGPointMake(centerX, CGRectGetMaxY(_countLabel.frame) + 3 + CGRectGetHeight(lab.frame) * 0.5);
        [view addSubview:lab];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 112, 32);
        [btn setBackgroundImage:[AppContext getImageForKey:@"activate_wall_btn_bg"]
                       forState:UIControlStateNormal];
        [btn setBackgroundImage:[AppContext getImageForKey:@"activate_wall_btn_bg"]
                       forState:UIControlStateHighlighted];
        btn.center = CGPointMake(centerX, CGRectGetMaxY(lab.frame) + 12 + CGRectGetHeight(btn.frame) * 0.5);
        [btn setTitle:[AppContext getStringForKey:@"badges_wall_activate_badge" fileName:@"user"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = kBoldFont(kLightFontSize);
        btn.titleLabel.numberOfLines = 0;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn addTarget:self action:@selector(activateBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        
        view.height = CGRectGetMaxY(btn.frame);
        
        view;
    });
    infoView.center = CGPointMake(30 + CGRectGetWidth(infoView.frame) * 0.5, CGRectGetHeight(headerView.frame) * 0.5);
    [headerView addSubview:infoView];
    
    _segmentedCtr = ({
        WLSegmentedControl *ctr = [[WLSegmentedControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), CGRectGetWidth(self.view.frame), kSegmentHeight)];
        ctr.backgroundColor = [UIColor whiteColor];
        ctr.currentIndex = 1;
        ctr.delegate = self;
        [ctr setItems:@[[AppContext getStringForKey:@"badges_wall_segment_social" fileName:@"user"],
                        [AppContext getStringForKey:@"badges_wall_segment_activity" fileName:@"user"],
                        [AppContext getStringForKey:@"badges_wall_segment_verified" fileName:@"user"]]];
        
        [self.view addSubview:ctr];
        ctr;
    });
    
    _scrollView = ({
        UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.segmentedCtr.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.segmentedCtr.frame))];
        sv.delegate = self;
        sv.showsHorizontalScrollIndicator = NO;
        sv.pagingEnabled = YES;
        
        _socialView = [[WLBadgeCollectionView alloc] init];
        _socialView.frame = sv.bounds;
        [sv addSubview:_socialView];
        
        _activityView = [[WLBadgeCollectionView alloc] init];
        _activityView.frame = CGRectMake(CGRectGetMaxX(_socialView.frame), 0, CGRectGetWidth(sv.frame), CGRectGetHeight(sv.frame));
        [sv addSubview:_activityView];
        
        _verifiedView = [[WLBadgeCollectionView alloc] init];
        _verifiedView.frame = CGRectMake(CGRectGetMaxX(_activityView.frame), 0, CGRectGetWidth(sv.frame), CGRectGetHeight(sv.frame));
        [sv addSubview:_verifiedView];
        
        sv.contentSize = CGSizeMake(CGRectGetWidth(sv.bounds) * _segmentedCtr.items.count, 0);
        sv.contentOffset = CGPointMake(CGRectGetWidth(sv.bounds) * _segmentedCtr.currentIndex, 0);
        
        [self.view addSubview:sv];
        sv;
    });
}

- (void)fetchData {
    [self showLoading];
    [self.manager fetchAllBadgesWithUserID:[AppContext getInstance].accountManager.myAccount.uid];
}

#pragma mark - WLBadgesManagerDelegate

- (void)badgesManagerFetch:(WLBadgesManager *)manager
                 dataArray:(NSArray *)dataArray
                   errCode:(NSInteger)errCode {
    [self hideLoading];
    
    if (errCode != ERROR_SUCCESS) {
        return;
    }
    
    _countLabel.text = [NSString stringWithFormat:@"%ld", dataArray.count];
    
    NSMutableArray *socialArray = [NSMutableArray array];
    NSMutableArray *activityArray = [NSMutableArray array];
    NSMutableArray *verifiedArray = [NSMutableArray array];
    
    for (int i = 0; i < dataArray.count; i++) {
        if (![dataArray[i] isKindOfClass:[WLBadgeModel class]]) {
            continue;
        }
        
        WLBadgeModel *model = (WLBadgeModel *)dataArray[i];
        switch (model.type) {
            case WLBadgeModelType_Social:
                [socialArray addObject:model];
                break;
            case WLBadgeModelType_Verified:
                [verifiedArray addObject:model];
                break;
            case WLBadgeModelType_Growth:
            case WLBadgeModelType_Activity:
                [activityArray addObject:model];
                break;
        }
    }
    
    [self.socialView setDataArray:socialArray];
    [self.activityView setDataArray:activityArray];
    [self.verifiedView setDataArray:verifiedArray];
}

#pragma mark - WLSegmentedControlDelegate

- (void)segmentedControl:(WLSegmentedControl *)control
        didSelectedIndex:(NSInteger)index
                preIndex:(NSInteger)preIndex {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame) * index, 0);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat x = scrollView.contentOffset.x;
    NSInteger index = x / kScreenWidth;
    
    self.segmentedCtr.currentIndex = index;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.segmentedCtr setLineOffsetX:scrollView.contentOffset.x];
}

#pragma mark - Event

- (void)activateBtnClicked {
    WLBadgesWearViewController *ctr = [[WLBadgesWearViewController alloc] init];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - Getter

- (WLBadgesManager *)manager {
    if (!_manager) {
        _manager = [[WLBadgesManager alloc] init];
        _manager.delegate = self;
    }
    return _manager;
}

@end
