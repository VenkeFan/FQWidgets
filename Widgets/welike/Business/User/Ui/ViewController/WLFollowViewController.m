//
//  WLFollowViewController.m
//  welike
//
//  Created by fan qi on 2018/5/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFollowViewController.h"
#import "WLSegmentedControl.h"
#import "WLFollowSubViewController.h"
#import "WLTrackerFollow.h"

@interface WLFollowViewController () <WLSegmentedControlDelegate, UIScrollViewDelegate>

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, assign) WLFollowType followType;

@property (nonatomic, strong) WLSegmentedControl *segmentedCtr;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation WLFollowViewController

#pragma mark - LifeCycle

- (instancetype)initWithUserID:(NSString *)userID followType:(WLFollowType)followType {
    if (self = [super init]) {
        _userID = [userID copy];
        _followType = followType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [AppContext getStringForKey:@"user_follow_page_title" fileName:@"user"];
    
    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)layoutUI {
    NSInteger index = self.followType == WLFollowType_Followed ? 0 : 1;
    
    self.navigationBar.navLine.hidden = YES;
    
    self.segmentedCtr = ({
        WLSegmentedControl *ctr = [[WLSegmentedControl alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kSegmentHeight)];
        ctr.backgroundColor = [UIColor whiteColor];
        ctr.currentIndex = index;
        ctr.delegate = self;
        [ctr setItems:@[[AppContext getStringForKey:@"mine_follower_num_text" fileName:@"user"],
                        [AppContext getStringForKey:@"following_btn_text" fileName:@"common"]]];
        [ctr addShadow];
        [self.view addSubview:ctr];
        
        ctr;
    });
    
    self.scrollView = ({
        UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.segmentedCtr.frame), kScreenWidth, kScreenHeight - CGRectGetMaxY(self.segmentedCtr.frame))];
        sv.delegate = self;
        sv.showsHorizontalScrollIndicator = NO;
        sv.pagingEnabled = YES;
        [self.view insertSubview:sv belowSubview:self.segmentedCtr];
        sv;
    });
    
    [self addSubCtrWithType:WLFollowType_Followed x:0];
    [self addSubCtrWithType:WLFollowType_Following x:kScreenWidth];
    
    self.scrollView.contentSize = CGSizeMake(kScreenWidth * self.segmentedCtr.items.count, 0);
    self.scrollView.contentOffset = CGPointMake(kScreenWidth * self.segmentedCtr.currentIndex, 0);
    
    if (self.segmentedCtr.currentIndex < self.childViewControllers.count) {
        [self.childViewControllers[self.segmentedCtr.currentIndex] display];
    }
    
    if (self.segmentedCtr.currentIndex == 0) {
        [WLTrackerFollow setFeedSource:WLTrackerFeedSource_User_Follow];
    } else {
        [WLTrackerFollow setFeedSource:WLTrackerFeedSource_User_Following];
    }
}

- (WLFollowSubViewController *)addSubCtrWithType:(WLFollowType)followType x:(CGFloat)x {
    WLFollowSubViewController *ctr = [[WLFollowSubViewController alloc] initWithUserID:self.userID
                                                                                    followType:followType];
    ctr.view.frame = (CGRect){.origin = CGPointMake(x, 0), .size = self.scrollView.bounds.size};
    [self addChildViewController:ctr];
    [self.scrollView addSubview:ctr.view];
    
    return ctr;
}

#pragma mark - WLSegmentedControlDelegate

- (void)segmentedControl:(WLSegmentedControl *)control didSelectedIndex:(NSInteger)index {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.scrollView.contentOffset = CGPointMake(kScreenWidth * index, 0);
                     }
                     completion:^(BOOL finished) {
                         WLFollowSubViewController *ctr = self.childViewControllers[index];
                         [ctr display];
                     }];
    
    if (index == 0) {
        [WLTrackerFollow setFeedSource:WLTrackerFeedSource_User_Follow];
    } else {
        [WLTrackerFollow setFeedSource:WLTrackerFeedSource_User_Following];
    }
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

@end
