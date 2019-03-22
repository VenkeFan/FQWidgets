//
//  WLUserDetailViewController.m
//  welike
//
//  Created by fan qi on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUserDetailViewController.h"
#import "WLMainTableView.h"
#import "WLSegmentedControl.h"
#import "WLScrollViewCell.h"
#import "WLHeadView.h"
#import "WLFollowViewController.h"
#import "WLUserLikesViewController.h"
#import "WLUserFeedsTableView.h"
#import "WLUserAlbumView.h"
#import "WLUserPostsProvider.h"
#import "WLUserLikePostsProvider.h"
#import <AVKit/AVKit.h>
#import "WLFeedDetailViewController.h"
#import "WLRepostViewController.h"
#import "WLCommentPostViewController.h"
#import "WLPersonalEditViewController.h"
#import "WLPrivateMessageViewController.h"
#import "WLAlertController.h"
#import "WLSingleUserManager.h"
#import "WLUser.h"
#import "WLAccountManager.h"
#import "WLFeedLayout.h"
#import "WLGradientCircleLayer.h"
#import "WLImageBrowseView.h"
#import "WLPicInfo.h"
#import "WLPublishTaskManager.h"
#import "WLShareViewController.h"
#import "WLMainViewController.h"
#import "WLFollowButton.h"
#import "WLProfileFollowingBtn.h"
#import "WLTrackerFollow.h"
#import "WLTrackerProfile.h"
#import "WLWebViewController.h"
#import "WLTrackerBlock.h"
#import "WLTrackerLogin.h"
#import "WLBadgesWallViewController.h"
#import "WLFoldLabel.h"

#define kTopBgHeight                    160.0
#define kScrollViewRefreshCritical      90.0
#define kProgressMax                    0.8
#define kNavAvatarViewSize              (32.0)
#define kNavAvatarViewRight             (8.0)

@interface WLUserDetailViewController () <WLSegmentedControlDelegate, WLScrollViewCellDelegate, WLFollowButtonDelegate, UITableViewDelegate, UITableViewDataSource, WLPublishTaskManagerDelegate, WLFoldLabelDelegate>

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, strong) WLUserBase *currentUser;

@property (nonatomic, strong) WLMainTableView *containerTableView;
@property (nonatomic, strong) WLScrollViewCell *scrollViewCell;
@property (nonatomic, strong) WLSegmentedControl *segmentedCtr;

@property (nonatomic, weak) UIButton *navMoreBtn;
@property (nonatomic, weak) UIButton *navEditBtn;
@property (nonatomic, weak) WLFollowButton *navFollowBtn;

@property (nonatomic, weak) UIImageView *coverBgView;

@property (nonatomic, weak) WLHeadView *avatarView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) WLFoldLabel *descLabel;

@property (nonatomic, weak) UIView *followInfoView;
@property (nonatomic, strong) UILabel *followingLabel;
@property (nonatomic, strong) UILabel *followersLabel;
@property (nonatomic, strong) UILabel *likesLabel;

@property (nonatomic, weak) UIView *operateView;
@property (nonatomic, weak) UIButton *editBtn;
@property (nonatomic, weak) WLFollowButton *followBtn;
@property (nonatomic, weak) WLFollowButton *smallFollowBtn;

@property (nonatomic, weak) UIButton *msgBigBtn;
@property (nonatomic, weak) UIButton *msgBtn;

@property (nonatomic, weak) UIView *iconsView;
@property (nonatomic, strong) UIButton *fbBtn;
@property (nonatomic, strong) UIButton *insBtn;
@property (nonatomic, strong) UIButton *youtBtn;

@property (nonatomic, strong) UIImageView *genderIcon;
@property (nonatomic, strong) UIView *honorsView;

@property (nonatomic, weak) UIView *headerFooterView;

@property (nonatomic, strong) WLGradientCircleLayer *refreshProgressLayer;
@property (nonatomic, assign) CGFloat contentInsetTop;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign, getter=isNormalUser) BOOL normalUser;

@property (nonatomic, assign) CGFloat originalNavTitleLeft;
@property (nonatomic, assign) CGFloat originalNavTitleWidth;
@property (nonatomic, assign) CGRect fromFrame;
@property (nonatomic, assign) CGRect toFrame;
@property (nonatomic, strong) UIImageView *navAvatarView;
@property (nonatomic, strong) UIImageView *animateImgView;
@property (nonatomic, assign) BOOL isManual;

@end

@implementation WLUserDetailViewController

#pragma mark - LifeCycle

- (instancetype)initWithOriginalUserInfo:(WLUser *)originalUserInfo {
    if (self = [self initWithUserID:originalUserInfo.uid]) {
        _currentUser = originalUserInfo;
    }
    return self;
}

- (instancetype)initWithUserID:(NSString *)userID {
    if (self = [super init]) {
        _userID = [userID copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loading = NO;
    self.normalUser = YES;
    self.isManual = NO;
    
    [self layoutUI];
    
    [self setCurrentUser:_currentUser];
    
    [self addObserver];
    
    [[AppContext getInstance].publishTaskManager registerDelegate:self];
    
    {
        self.loading = YES;
        _refreshProgressLayer.strokeEnd = kProgressMax;
        [_refreshProgressLayer beginAnimating];
        [self fetchUserInfo];
    }
    
    {
        WLTrackerProfileSource pageSource = WLTrackerProfileSource_Other;
        if (self.navigationController.childViewControllers.count >= 2) {
            UIViewController *lastCtr = self.navigationController.childViewControllers[self.navigationController.childViewControllers.count - 2];
            if ([lastCtr isKindOfClass:[WLMainViewController class]]) {
                WLMainViewController *mainCtr = (WLMainViewController *)lastCtr;
                pageSource = mainCtr.selectedIndex == 3 ? WLTrackerProfileSource_Me : WLTrackerProfileSource_Other;
            }
        }
        [WLTrackerProfile appendTrackerWithProfileAction:WLTrackerProfileActionType_Display
                                              pageSource:pageSource
                                                moreType:WLTrackerProfileMoreType_None
                                                  userID:_userID];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [WLTrackerFollow setFeedSource:WLTrackerFeedSource_User_Detail];
}

- (void)layoutUI {
    {
        self.containerTableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        [self.view addSubview:self.containerTableView];

        _refreshProgressLayer = [WLGradientCircleLayer layer];
        _refreshProgressLayer.circleColor = kMainColor;
        _refreshProgressLayer.frame = CGRectMake(0, 0, 20, 20);
        _refreshProgressLayer.position = CGPointMake(CGRectGetWidth(self.view.bounds) - self.navigationBar.leftBtn.centerX,
                                                     kSystemStatusBarHeight + self.navigationBar.leftBtn.centerY);
        _refreshProgressLayer.strokeEnd = 0.0;
        [self.navigationBar.layer addSublayer:_refreshProgressLayer];

        [_refreshProgressLayer addObserver:self
                                forKeyPath:@"strokeEnd"
                                   options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                   context:nil];
    }
    
    {
        [self layoutNavigationBar];
    }
}

- (void)layoutNavigationBar {
    self.title = [AppContext getStringForKey:@"view_my_profile" fileName:@"user"];
    self.navigationBar.tintColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    self.navigationBar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    self.navigationBar.navLine.hidden = YES;
    self.navigationBarAlwaysFront = NO;
    
    self.originalNavTitleLeft = self.navigationBar.titleLabel.frame.origin.x;
    
    _navAvatarView = [[UIImageView alloc] init];
    _navAvatarView.hidden = YES;
    _navAvatarView.frame = CGRectMake(self.originalNavTitleLeft, (CGRectGetHeight(self.navigationBar.titleView.bounds) - kNavAvatarViewSize) * 0.5, kNavAvatarViewSize, kNavAvatarViewSize);
    _navAvatarView.layer.cornerRadius = kNavAvatarViewSize * 0.5;
    _navAvatarView.layer.masksToBounds = YES;
    [self.navigationBar.titleView addSubview:_navAvatarView];
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn setImage:[[AppContext getImageForKey:@"common_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(navMoreBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navMoreBtn = moreBtn;
    
    if ([self.userID isEqualToString:[AppContext getInstance].accountManager.myAccount.uid]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.alpha = 0.0;
        [btn setImage:[[AppContext getImageForKey:@"user_edit"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(userEditOnTapped) forControlEvents:UIControlEventTouchUpInside];
        self.navEditBtn = btn;
        self.navigationBar.rightBtnArray = @[moreBtn, btn];
    } else {
        WLFollowButton *btn = [[WLFollowButton alloc] initWithFrame:CGRectMake(0, 0, 48, 20)];
        btn.alpha = 0.0;
        btn.delegate = self;
        btn.titleLabel.font = kBoldFont(kDateTimeFontSize);
        self.navFollowBtn = btn;
        self.navigationBar.rightBtnArray = @[moreBtn, btn];
    }
    
    [self.view bringSubviewToFront:self.navigationBar];
}

- (void)dealloc {
    [[AppContext getInstance].publishTaskManager unregister:self];
    [self removeObserver];
    [_refreshProgressLayer removeObserver:self
                               forKeyPath:@"strokeEnd"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Observer

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountChanged:) name:kWLAccountChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(honorChanged:) name:kWLAccountHonorUpdatedNotificationName object:nil];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)accountChanged:(NSNotification *)notification {
    if ([self.userID isEqualToString:[AppContext getInstance].accountManager.myAccount.uid]) {
        [self setCurrentUser:[AppContext getInstance].accountManager.myAccount];
    }
}

- (void)honorChanged:(NSNotification *)notification {
    if ([self.userID isEqualToString:[AppContext getInstance].accountManager.myAccount.uid]) {
        [self fetchUserInfo];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"strokeEnd"]) {
        if ([change[NSKeyValueChangeNewKey] floatValue] > 0.0) {
            self.navMoreBtn.hidden = YES;
        } else {
            self.navMoreBtn.hidden = NO;
        }
    }
}

#pragma mark - Network

- (void)beginRefresh {
    if (self.loading) {
        return;
    }
    
    self.loading = YES;
    [_refreshProgressLayer beginAnimating];
    [UIView animateWithDuration:0.25 animations:^{
        self.containerTableView.contentInset = UIEdgeInsetsMake(self.contentInsetTop + kScrollViewRefreshCritical, 0, 0, 0);
    }];
    
    [self fetchUserInfo];
}

- (void)endRefresh {
    self.loading = NO;
    [_refreshProgressLayer stopAnimating];
    [UIView animateWithDuration:0.25 animations:^{
        self.containerTableView.contentInset = UIEdgeInsetsMake(self.contentInsetTop, 0, 0, 0);
    } completion:^(BOOL finished) {
        if (self.contentInsetTop + self.containerTableView.contentOffset.y != 0) {
            self.isManual = YES;
            [self.containerTableView setContentOffset:CGPointMake(0, -self.contentInsetTop) animated:YES];
        }
    }];
}

- (void)fetchUserInfo {
    [[AppContext getInstance].singleUserManager loadUserDetailWithUid:self.userID
                                  successed:^(WLUser *user) {
                                      [self setCurrentUser:user];
                                      [self endRefresh];
                                      
                                      [self.containerTableView reloadData];
                                  }
                                      error:^(NSString *uid, NSInteger errCode) {
                                          [self endRefresh];
                                          
                                          [self.containerTableView reloadData];
                                      }];
}

- (void)blockUser:(WLUserBase *)user
{
    [[AppContext getInstance].singleUserManager blockUserWithUid:user.uid];
    [WLTrackerBlock appendTrackerWithBlockType:WLTrackerBlockType_Block
                                        userID:user.uid
                                        source:WLTrackerFeedSource_User_Detail];
}

#pragma mark - Share

- (void)showShareController:(WLUserBase *)user {
    WLShareModel *shareModel = [WLShareModel modelWithID:user.uid
                                                    type:WLShareModelType_Profile
                                                   title:user.nickName
                                                    desc:user.introduction
                                                  imgUrl:user.headUrl
                                                 linkUrl:nil];
    
    WLShareViewController *ctr = [[WLShareViewController alloc] init];
    ctr.shareModel = shareModel;
    [self presentViewController:ctr animated:YES completion:nil];
}

#pragma mark - WLPublishTaskManagerDelegate

- (void)onPublishTask:(NSString *)taskId end:(NSInteger)errCode {
    if (errCode == ERROR_SUCCESS) {
        [self showToast:[AppContext getStringForKey:@"editor_send_successed" fileName:@"publish"]];
    } else {
        [self showToastWithNetworkErr:errCode];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGRectGetHeight(self.segmentedCtr.bounds);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!_currentUser) {
        return nil;
    }
    
    if ([self.userID isEqualToString:[AppContext getInstance].accountManager.myAccount.uid]) {
        [self.segmentedCtr setItems:@[[self p_segmentTitle:[AppContext getStringForKey:@"mine_post_num_text" fileName:@"user"]
                                                     count:self.currentUser.postsCount],
                                      [self p_segmentTitle:[AppContext getStringForKey:@"mine_invite_friends_text" fileName:@"user"]
                                                     count:self.currentUser.myLikedPostsCount]]];
    } else {
        [self.segmentedCtr setItems:@[[self p_segmentTitle:[AppContext getStringForKey:@"mine_post_num_text" fileName:@"user"]
                                                     count:self.currentUser.postsCount],
                                      [self p_segmentTitle:[AppContext getStringForKey:@"short_cut_alumb_name" fileName:@"publish"]
                                                     count:0]]];
    }
    
    return self.segmentedCtr;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.currentUser) {
        return [UITableViewCell new];
    }
    
    if (_scrollViewCell) {
        [_scrollViewCell forceRefresh];
    }
    
    if (!_scrollViewCell) {
        _scrollViewCell = [[WLScrollViewCell alloc] init];
        _scrollViewCell.delegate = self;
        
        CGRect frame = CGRectMake(0, 0, kScreenWidth, [self p_scrollCellHeight]);
        
        WLUserFeedsTableView *postView = [[WLUserFeedsTableView alloc] initWithFrame:frame];
        postView.superCell = _scrollViewCell;
        [postView setProvider:[WLUserPostsProvider new] userID:self.userID];
        
        if ([self.userID isEqualToString:[AppContext getInstance].accountManager.myAccount.uid]) {
            WLUserFeedsTableView *likeView = [[WLUserFeedsTableView alloc] initWithFrame:frame];
            likeView.superCell = _scrollViewCell;
            [likeView setProvider:[WLUserLikePostsProvider new] userID:self.userID];
            
            [_scrollViewCell setSubViews:@[postView, likeView]];
        } else {
            WLUserAlbumView *albumView = [[WLUserAlbumView alloc] initWithFrame:frame];
            albumView.superCell = _scrollViewCell;
            albumView.userID = self.userID;
            
            [_scrollViewCell setSubViews:@[postView, albumView]];
        }
        
        [_scrollViewCell setCurrentIndex:self.segmentedCtr.currentIndex];
    }
    
    return _scrollViewCell;
}

#pragma mark - WLSegmentedControlDelegate

- (void)segmentedControl:(WLSegmentedControl *)control didSelectedIndex:(NSInteger)index preIndex:(NSInteger)preIndex {
    if (preIndex < self.scrollViewCell.subViews.count) {
        if ([self.scrollViewCell.subViews[preIndex] isKindOfClass:[WLUserFeedsTableView class]]) {
            [[(WLUserFeedsTableView *)self.scrollViewCell.subViews[preIndex] tableView] destroyMixedPlayerView];
        }
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.scrollViewCell.currentIndex = index;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    if (index == 0) {
        [WLTrackerProfile appendTrackerWithProfileAction:WLTrackerProfileActionType_Posts
                                              pageSource:WLTrackerProfileSource_None
                                                moreType:WLTrackerProfileMoreType_Other
                                                  userID:_userID];
    } else {
        [WLTrackerProfile appendTrackerWithProfileAction:WLTrackerProfileActionType_Likes
                                              pageSource:WLTrackerProfileSource_None
                                                moreType:WLTrackerProfileMoreType_Other
                                                  userID:_userID];
    }
}

#pragma mark - WLScrollViewCellDelegate

- (void)userDetailCellHorizontalScrollViewDidScroll:(UIScrollView *)scrollView {
    [self.segmentedCtr setLineOffsetX:scrollView.contentOffset.x];
}

- (void)userDetailCellHorizontalScrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat x = scrollView.contentOffset.x;
    NSInteger index = x / kScreenWidth;
    
    self.segmentedCtr.currentIndex = index;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self p_topCellHeight] < 0) {
        return;
    }
    
    if (!self.loading) {
        if (scrollView.contentOffset.y + self.containerTableView.contentInset.top <= 0) {
            CGFloat progress = ((ABS(self.containerTableView.contentOffset.y) - self.containerTableView.contentInset.top) / kScrollViewRefreshCritical) * kProgressMax;
            
            _refreshProgressLayer.strokeEnd = progress <= kProgressMax ? progress : kProgressMax;
        } else {
            _refreshProgressLayer.strokeEnd = 0.0;
        }
    }
    
    [self p_updateNavAlpha:scrollView.contentOffset.y + self.containerTableView.contentInset.top];
    [self p_updateNavAvatarView:scrollView.contentOffset.y + self.containerTableView.contentInset.top];
    [self p_updateNavTitleWidth];
//    [self p_updateCoverScale:scrollView.contentOffset.y];
    [self p_updateCoverSize:scrollView.contentOffset.y];
    
    if (self.scrollViewCell.subScrollViewScrolling) {
        self.containerTableView.contentOffset = CGPointMake(0, [self p_topCellHeight]);
        return;
    }
    
    if (scrollView.contentOffset.y >= [self p_topCellHeight]) {
        self.containerTableView.contentOffset = CGPointMake(0, [self p_topCellHeight]);
        self.scrollViewCell.superScrollViewScrolling = NO;
        
        [self.segmentedCtr addShadow];
    } else {
        self.scrollViewCell.superScrollViewScrolling = YES;
        
        [self.segmentedCtr clearShadow];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.isManual = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.containerTableView.contentOffset.y < 0 &&
        ABS(self.containerTableView.contentOffset.y) >= self.containerTableView.contentInset.top + kScrollViewRefreshCritical) {
        
        [self beginRefresh];
    }
}

#pragma mark - WLFollowButtonDelegate

- (void)followButtonFinished:(WLFollowButton *)followBtn {
    [self.navFollowBtn setUser:followBtn.user];
    [self.followBtn setUser:followBtn.user];
    [self.smallFollowBtn setUser:followBtn.user];
    
    [self p_updateFollowBtnHidden];
    
    if (self.navFollowBtn.type == WLFollowButtonType_Friends || self.navFollowBtn.type == WLFollowButtonType_Following) {
        self.navFollowBtn.alpha = 0.0;
    }
    
    [WLTrackerProfile appendTrackerWithProfileAction:WLTrackerProfileActionType_Follow
                                          pageSource:WLTrackerProfileSource_None
                                            moreType:WLTrackerProfileMoreType_Other
                                              userID:_userID];
}

- (void)followButtonLoadingChanged:(WLFollowButton *)followBtn {
    self.navFollowBtn.loading = followBtn.isLoading;
    self.followBtn.loading = followBtn.isLoading;
}

#pragma mark - WLFoldLabelDelegate

- (void)foldLabel:(WLFoldLabel *)label oldHeight:(CGFloat)oldHeight newHeight:(CGFloat)newHeight {
    CGFloat deviation = newHeight - oldHeight;
    
    if (deviation > 0) {
        CGRect frame = self.genderIcon.frame;
        frame.origin.y += deviation;
        self.genderIcon.frame = frame;
        
        self.honorsView.centerY = CGRectGetMidY(self.genderIcon.frame);
        self.iconsView.centerY = CGRectGetMidY(self.genderIcon.frame);
        self.headerFooterView.top += deviation;
        
        UIView *headerView = self.containerTableView.tableHeaderView;
        headerView.height = CGRectGetMaxY(self.headerFooterView.frame);
        self.containerTableView.tableHeaderView = headerView;
    }
}

- (void)foldLabelDidTapped:(WLFoldLabel *)label {
    [self userEditOnTapped];
}

#pragma mark - Event

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:self.containerTableView];
    CGPoint newPoint = [self.coverBgView convertPoint:point fromView:self.containerTableView];
    if (CGRectContainsPoint(self.coverBgView.bounds, newPoint)) {
//        NSLog(@"********* clicked coverBgView");
    }
}

- (void)bgViewTapped:(UIGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.containerTableView];
    CGPoint newPoint = [self.avatarView convertPoint:point fromView:self.containerTableView];
    if (CGRectContainsPoint(self.avatarView.bounds, newPoint)) {
        [self avatarViewOnTapped];
    } else {
//        NSLog(@"********* clicked coverBgView: bgViewTapped");
    }
}

- (void)avatarViewOnTapped {
    UIImageView *imgView = self.avatarView;
    UIView *rootView = ([UIApplication sharedApplication].keyWindow.rootViewController).view;
    
    FQImageBrowseItemModel *itemModel = [[FQImageBrowseItemModel alloc] init];
    itemModel.thumbView = imgView;
    itemModel.userName = self.currentUser.nickName;
    
    WLPicInfo *picInfo = [[WLPicInfo alloc] init];
    picInfo.picUrl = self.currentUser.headUrl;
    itemModel.imageInfo = picInfo;
    
    WLImageBrowseView *browseView = [[WLImageBrowseView alloc] initWithItemArray:@[itemModel]];
    [browseView displayWithFromView:imgView toView:rootView];
}

- (void)userEditOnTapped {
    if ([self.userID isEqualToString:[AppContext getInstance].accountManager.myAccount.uid]) {
        WLPersonalEditViewController *vc = [[WLPersonalEditViewController alloc] init];
        [[AppContext rootViewController] pushViewController:vc animated:YES];
        
        [WLTrackerProfile appendTrackerWithProfileAction:WLTrackerProfileActionType_EditProfile
                                              pageSource:WLTrackerProfileSource_None
                                                moreType:WLTrackerProfileMoreType_None
                                                  userID:_userID];
    }
}

- (void)chatBtnClicked {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Profile_Chat];
    kNeedLogin
    
    WLUser *user = (WLUser *)self.currentUser;
    WLPrivateMessageViewController *vc = [[WLPrivateMessageViewController alloc] initWithUser:user];
    [[AppContext rootViewController] pushViewController:vc animated:YES];
    
    [WLTrackerProfile appendTrackerWithProfileAction:WLTrackerProfileActionType_Message
                                          pageSource:WLTrackerProfileSource_None
                                            moreType:WLTrackerProfileMoreType_Other
                                              userID:_userID];
}

- (void)navMoreBtnClicked {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    WLAlertController *alert = [WLAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (![self.currentUser.uid isEqualToString:[AppContext getInstance].accountManager.myAccount.uid]) {
        NSString *blockAction = [NSString stringWithFormat:@"%@@%@", [AppContext getStringForKey:@"block" fileName:@"common"], self.currentUser.nickName];
        [alert addAction:[UIAlertAction actionWithTitle:blockAction
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self blockUser:self.currentUser];
                                                    
                                                    [WLTrackerProfile appendTrackerWithProfileAction:WLTrackerProfileActionType_More
                                                                                          pageSource:WLTrackerProfileSource_None
                                                                                            moreType:WLTrackerProfileMoreType_Other
                                                                                              userID:self->_userID];
                                                }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"feed_share" fileName:@"feed"]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self showShareController:self.currentUser];
                                                
                                                [WLTrackerProfile appendTrackerWithProfileAction:WLTrackerProfileActionType_More
                                                                                      pageSource:WLTrackerProfileSource_None
                                                                                        moreType:WLTrackerProfileMoreType_Share
                                                                                          userID:self->_userID];
                                                
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"common_cancel" fileName:@"common"]
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [WLTrackerProfile appendTrackerWithProfileAction:WLTrackerProfileActionType_More
                                                                                      pageSource:WLTrackerProfileSource_None
                                                                                        moreType:WLTrackerProfileMoreType_Other
                                                                                          userID:self->_userID];
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)followingLabelTapped {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    WLFollowViewController *ctr = [[WLFollowViewController alloc] initWithUserID:self.currentUser.uid followType:WLFollowType_Following];
    [self.navigationController pushViewController:ctr animated:YES];
    
    [WLTrackerProfile appendTrackerWithProfileAction:WLTrackerProfileActionType_Following
                                          pageSource:WLTrackerProfileSource_None
                                            moreType:WLTrackerProfileMoreType_None
                                              userID:_userID];
}

- (void)followersLabelTapped {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    WLFollowViewController *ctr = [[WLFollowViewController alloc] initWithUserID:self.currentUser.uid followType:WLFollowType_Followed];
    [self.navigationController pushViewController:ctr animated:YES];
    
    [WLTrackerProfile appendTrackerWithProfileAction:WLTrackerProfileActionType_Followers
                                          pageSource:WLTrackerProfileSource_None
                                            moreType:WLTrackerProfileMoreType_None
                                              userID:_userID];
}

- (void)likesLabelTapped {
    WLUserLikesViewController *ctr = [[WLUserLikesViewController alloc] initWithUserID:self.currentUser.uid];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)linkBtnClicked:(UIButton *)sender {
    if (!sender.isSelected) {
        return;
    }
    
    if (sender.tag < 0 || sender.tag >= self.currentUser.links.count) {
        return;
    }
    
    NSString *urlStr = [(WLUserLinkModel *)self.currentUser.links[sender.tag] link];
    if (urlStr.length == 0) {
        return;
    }
    
    WLWebViewController *webCtr = [[WLWebViewController alloc] initWithUrl:urlStr];
    [self.navigationController pushViewController:webCtr animated:YES];
}

- (void)honorsViewTapped {
    kNeedLogin;
    
    WLBadgesWallViewController *ctr = [[WLBadgesWallViewController alloc] init];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - Private

- (CGFloat)p_topCellHeight {
    return self.containerTableView.tableHeaderView.frame.size.height - kNavBarHeight;
}

- (CGFloat)p_scrollCellHeight {
    return kScreenHeight - kNavBarHeight - CGRectGetHeight(self.segmentedCtr.bounds);
}

- (NSString *)p_segmentTitle:(NSString *)title count:(NSInteger)count {
    return count > 0
    ? [NSString stringWithFormat:@"%ld %@", (long)count, title]
    : [NSString stringWithFormat:@"%@", title];
}

- (void)p_updateNavAlpha:(CGFloat)offsetY {
    if (!self.currentUser) {
        return;
    }
    
    if (offsetY <= 0) {
        self.navigationBar.titleLabel.font = kBoldFont(kNameFontSize);
        
        if (self.isNormalUser) {
            self.navigationBar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            self.navigationBar.tintColor = [UIColor colorWithWhite:0.0 alpha:1.0];
            self.navEditBtn.alpha = self.navFollowBtn.alpha = 0.0;
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                self.navigationBar.alpha = 0.0;
                self.navigationBar.tintColor = [UIColor colorWithWhite:1.0 alpha:1.0];
                self.navEditBtn.alpha = self.navFollowBtn.alpha = 0.0;
            } completion:^(BOOL finished) {
//                [self.navigationBar setNeedsLayout];
            }];
        }
    } else if (offsetY > self.nameLabel.frame.origin.y) {
        self.navigationBar.titleLabel.font = kBoldFont(kNameFontSize);
        
        CGFloat ratio = (offsetY - CGRectGetMaxY(self.nameLabel.frame)) / (self.containerTableView.tableHeaderView.frame.size.height - CGRectGetMaxY(self.nameLabel.frame));
        
        if (ratio < 0) {
            ratio = 0;
        }
        
        if (ratio > 1) {
            ratio = 1;
        }
        
        if (self.isNormalUser) {
            self.navigationBar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            self.navigationBar.tintColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        } else {
            self.navigationBar.alpha = ratio;
            self.navigationBar.tintColor = [UIColor colorWithWhite:1.0 - ratio alpha:1.0];
        }
        
        self.navEditBtn.alpha = ratio;
        if (self.navFollowBtn.type == WLFollowButtonType_Friends || self.navFollowBtn.type == WLFollowButtonType_Following) {
            self.navFollowBtn.alpha = 0.0;
        } else {
            self.navFollowBtn.alpha = ratio;
        }
//        [self.navigationBar setNeedsLayout];
    }
}

- (void)p_updateNavAvatarView:(CGFloat)offsetY {
    if (!self.currentUser) {
        return;
    }
    
    if (!self.avatarView) {
        return;
    }
    
    if (self.isManual) {
        return;
    }
    
    CGFloat ratio = (offsetY - CGRectGetMinY(self.avatarView.frame)) / (CGRectGetMinY(self.avatarView.frame) + self.containerTableView.contentInset.top - kNavAvatarViewSize);
    
    if (ratio < 0) {
        ratio = 0;
    }
    
    if (ratio > 1) {
        ratio = 1;
    }
    
    if (ratio >= 0 && ratio <= 1) {
        self.navigationBar.titleLabel.left = self.originalNavTitleLeft + ratio * (kNavAvatarViewSize + kNavAvatarViewRight);
    }
    
    if (ratio == 0) {
        UIView *rootView = self.view;
        _fromFrame = [self.avatarView convertRect:self.avatarView.bounds toView:rootView];
        _toFrame = [self.navAvatarView convertRect:self.navAvatarView.bounds toView:rootView];
        UIImage *img = self.avatarView.image; // [self p_snapshotImage:self.avatarView];
        
        if (!_animateImgView && img) {
            _animateImgView = [[UIImageView alloc] initWithImage:img];
            _animateImgView.clipsToBounds = YES;
            [_animateImgView fq_setImageWithURLString:self.currentUser.headUrl
                                          placeholder:[AppContext getImageForKey:@"head_default"] completed:^(UIImage *image, NSURL *url, NSError *error) {
                                              if (!image) {
                                                  self->_animateImgView.image = img;
                                              }
                                          }];
            [rootView insertSubview:_animateImgView aboveSubview:self.navigationBar];
        }
        _animateImgView.frame = _fromFrame;
        _animateImgView.layer.cornerRadius = CGRectGetWidth(_animateImgView.bounds) * 0.5;
        
        if (offsetY < self.avatarView.frame.origin.y) {
            self.avatarView.hidden = NO;
            _animateImgView.hidden = YES;
        } else {
            self.avatarView.hidden = YES;
            _animateImgView.hidden = NO;
        }

        self.navAvatarView.hidden = YES;
        
    } else if (ratio == 1) {
        self.avatarView.hidden = YES;
        self.navAvatarView.hidden = NO;
        self.navAvatarView.image = _animateImgView.image;
        
        _animateImgView.frame = _toFrame;
        _animateImgView.layer.cornerRadius = CGRectGetWidth(_animateImgView.bounds) * 0.5;
        _animateImgView.hidden = YES;
    } else {
        self.avatarView.hidden = YES;
        self.navAvatarView.hidden = YES;
        _animateImgView.hidden = NO;
        
        CGFloat centerX = CGRectGetMidX(_fromFrame) + ABS((CGRectGetMidX(_fromFrame) - CGRectGetMidX(_toFrame)) * ratio);
        CGFloat centerY = CGRectGetMidY(_fromFrame) - ABS((CGRectGetMidY(_fromFrame) - CGRectGetMidY(_toFrame)) * ratio);
        CGFloat width = (_fromFrame.size.width - _toFrame.size.width) * (1.0 - ratio) + _toFrame.size.width;
        CGFloat height = (_fromFrame.size.height - _toFrame.size.height) * (1.0 - ratio) + _toFrame.size.height;
        
        _animateImgView.frame = CGRectMake(0, 0, width, height);
        _animateImgView.center = CGPointMake(centerX, centerY);
        _animateImgView.layer.cornerRadius = CGRectGetWidth(_animateImgView.bounds) * 0.5;
    }
}

- (void)p_updateNavTitleWidth {
    if (self.navFollowBtn.alpha >= 0.5 && self.originalNavTitleWidth > CGRectGetWidth(self.navigationBar.titleView.bounds) - CGRectGetWidth(self.navFollowBtn.bounds) - self.navigationBar.titleLabel.left) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.navigationBar.titleLabel.width = CGRectGetWidth(self.navigationBar.titleView.bounds) - CGRectGetWidth(self.navFollowBtn.bounds) - self.navigationBar.titleLabel.left;
                         }];
    } else {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.navigationBar.titleLabel.width = self.originalNavTitleWidth;
                         }];
    }
}

- (void)p_updateNavTitle:(NSString *)title {
    if ([self.title isEqualToString:title] || title.length == 0) {
        return;
    }
    
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    [self.navigationBar.titleLabel.layer addAnimation:transition forKey:nil];
    self.title = title;
}

//- (void)p_updateCoverScale:(CGFloat)offsetY {
//    if (offsetY - self.containerTableView.contentInset.top < 0) {
//        CGFloat ratio = 1.0 + fabs(offsetY) / CGRectGetHeight(self.containerTableView.bounds);
//        self.coverBgView.transform = CGAffineTransformMakeScale(ratio, ratio);
//    } else {
//        self.coverBgView.transform = CGAffineTransformIdentity;
//    }
//}

- (void)p_updateCoverSize:(CGFloat)offsetY {
    self.coverBgView.height = ABS(offsetY);
    self.coverBgView.width = CGRectGetWidth(self.coverBgView.superview.frame);
    self.coverBgView.top = CGRectGetHeight(self.coverBgView.superview.frame) - self.coverBgView.height;
}

- (void)p_updateCoverBgViewWithUser:(WLUserBase *)currentUser {
    if (currentUser.cover) {
        self.coverBgView.hidden = NO;
        self.coverBgView.contentMode = UIViewContentModeScaleAspectFill;
        [self.coverBgView fq_setImageWithURLString:currentUser.cover];
        
        self.normalUser = NO;
    } else {
        switch (currentUser.curLevel) {
            case WLUserLevel_Normal: {
                self.coverBgView.hidden = YES;
                
                self.normalUser = YES;
            }
                break;
            case WLUserLevel_Star: {
                UIImage *image = [AppContext getImageForKey:@"user_cover_vip_star"];
                
                self.coverBgView.hidden = NO;
                self.coverBgView.image = image;
                self.coverBgView.contentMode = UIViewContentModeScaleAspectFill;
                
                self.normalUser = NO;
            }
                break;
            case WLUserLevel_Influencer: {
                UIImage *image = [AppContext getImageForKey:@"user_cover_vip_influencer"];
                
                self.coverBgView.hidden = NO;
                self.coverBgView.image = image;
                self.coverBgView.contentMode = UIViewContentModeScaleAspectFill;
                
                self.normalUser = NO;
            }
                break;
        }
    }
}

- (void)p_updateFollowInfoViewWithUser:(WLUserBase *)currentUser x:(CGFloat)x y:(CGFloat)y right:(CGFloat)right {
    CGFloat padding = 6;
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds) - x - right - padding * 2;
    CGFloat viewHeight = 32;
    CGFloat singleWidth = viewWidth / 3.0;
    
    NSMutableAttributedString *(^joinBlock)(NSString *txt1, NSString *txt2) = ^(NSString *txt1, NSString *txt2) {
        NSMutableAttributedString *followingStr = [[NSMutableAttributedString alloc] initWithString:txt1];
        [followingStr setAttributes:@{NSFontAttributeName: kBoldFont(kMediumNameFontSize),
                                      NSForegroundColorAttributeName:kNameFontColor}
                              range:NSMakeRange(0, followingStr.length)];
        [followingStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [followingStr appendAttributedString:[[NSAttributedString alloc] initWithString:txt2 ?: @""
                                                                             attributes:@{NSFontAttributeName: kRegularFont(kLightFontSize), NSForegroundColorAttributeName: kLightLightFontColor}]];
        
        return followingStr;
    };
    
    
    NSMutableAttributedString *str = joinBlock([NSString stringWithFormat:@"%ld", (long)currentUser.followUsersCount], [AppContext getStringForKey:@"mine_following_num_text" fileName:@"user"]);
    self.followingLabel.attributedText = str;
    self.followingLabel.frame = CGRectMake(0, 0, singleWidth, viewHeight);
    
    
    str = joinBlock([NSString stringWithFormat:@"%ld", (long)currentUser.followedUsersCount], [AppContext getStringForKey:@"mine_follower_num_text" fileName:@"user"]);
    self.followersLabel.attributedText = str;
    self.followersLabel.frame = CGRectMake(CGRectGetMaxX(self.followingLabel.frame), 0, singleWidth, viewHeight);
    
    str = joinBlock([NSString stringWithFormat:@"%ld", (long)currentUser.myLikedPostsCount], [AppContext getStringForKey:@"mine_liked_num_text" fileName:@"user"]);
    self.likesLabel.attributedText = str;
    self.likesLabel.frame = CGRectMake(CGRectGetMaxX(self.followersLabel.frame), 0, singleWidth, viewHeight);
    
    self.followInfoView.frame = CGRectMake(x + padding, y, viewWidth, viewHeight);
}

- (void)p_updateOperateViewWithUser:(WLUserBase *)currentUser x:(CGFloat)x right:(CGFloat)right {
    CGFloat btnHeight = 24, paddingX = 8;
    CGFloat btnWidth = CGRectGetWidth(self.view.bounds) - x - right;
    CGFloat chatWidth = 56, followWidth = btnWidth - chatWidth - paddingX;
    self.operateView.frame = CGRectMake(x, CGRectGetMaxY(self.avatarView.frame) - btnHeight, btnWidth, btnHeight);
    
    if ([self.userID isEqualToString:[AppContext getInstance].accountManager.myAccount.uid]) {
        self.editBtn.hidden = NO;
        self.msgBtn.hidden = self.followBtn.hidden = YES;
        
        self.editBtn.frame = CGRectMake(0, 0, CGRectGetWidth(self.operateView.bounds), CGRectGetHeight(self.operateView.bounds));
        self.editBtn.layer.cornerRadius = kCornerRadius;
    } else {
        self.editBtn.hidden = YES;
        self.msgBtn.hidden = self.followBtn.hidden = NO;
        
        self.msgBtn.frame = CGRectMake(0, 0, chatWidth, btnHeight);
        self.msgBtn.center = CGPointMake(CGRectGetWidth(self.operateView.bounds) - CGRectGetWidth(self.msgBtn.bounds) * 0.5, CGRectGetHeight(self.operateView.bounds) * 0.5);
        
        self.followBtn.frame = CGRectMake(0, 0, followWidth, btnHeight);
        
        self.msgBigBtn.frame = self.followBtn.frame;
        self.smallFollowBtn.frame = self.msgBtn.frame;
        
        [self.followBtn setUser:(WLUser *)currentUser];
        [self.smallFollowBtn setUser:(WLUser *)currentUser];
        
        [self p_updateFollowBtnHidden];
        
        self.msgBtn.layer.cornerRadius = self.followBtn.layer.cornerRadius = kCornerRadius;
    }
}

- (void)p_updateFollowBtnHidden {
    switch (self.followBtn.type) {
        case WLFollowButtonType_Friends:
        case WLFollowButtonType_Following: {
            self.smallFollowBtn.hidden = NO;
            self.msgBigBtn.hidden = NO;
            self.msgBtn.hidden = YES;
            self.followBtn.hidden = YES;
        }
            break;
        case WLFollowButtonType_Followed:
        case WLFollowButtonType_None: {
            self.smallFollowBtn.hidden = YES;
            self.msgBigBtn.hidden = YES;
            self.msgBtn.hidden = NO;
            self.followBtn.hidden = NO;
        }
            break;
    }
}

- (void)p_updateDescViewWithUser:(WLUserBase *)currentUser x:(CGFloat)x y:(CGFloat)y {
    CGFloat width = CGRectGetWidth(self.view.bounds) - x * 2;
    CGFloat height = 29;
    NSAttributedString *attrStr = nil;
    
    if (currentUser.introduction.length > 0) {
        attrStr = [[NSAttributedString alloc] initWithString:currentUser.introduction attributes:@{NSFontAttributeName: kRegularFont(kLightFontSize), NSForegroundColorAttributeName: kNameFontColor}];
        CGSize size = [attrStr boundingRectWithSize:CGSizeMake(width, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
        if (size.height < height) {
            height = size.height;
        }
    } else {
        height = 0.0;
    }

    self.descLabel.frame = CGRectMake(0, 0, width, height);
    self.descLabel.attributedText = attrStr;
    self.descLabel.center = CGPointMake(x + CGRectGetWidth(self.descLabel.bounds) * 0.5, y + CGRectGetHeight(self.descLabel.bounds) * 0.5);
}

- (void)p_updateGenderViewWithUser:(WLUserBase *)currentUser x:(CGFloat)x y:(CGFloat)y {
    UIImage *genderImg = currentUser.gender == WELIKE_USER_GENDER_MALE
    ? [AppContext getImageForKey:@"user_male"]
    : (currentUser.gender == WELIKE_USER_GENDER_FEMALE
       ? [AppContext getImageForKey:@"user_female"]
       : nil);
    
    self.genderIcon.frame = CGRectMake(x, y, 20, 20);
    self.genderIcon.image = genderImg;
}

- (void)p_updateHonorsViewWithUser:(WLUserBase *)currentUser {
    [self.honorsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger count = currentUser.honors.count >= 6 ? 6 : currentUser.honors.count;
    CGFloat size = 20, left = 5;
    CGFloat width = 0;
    for (int i = 0; i < count; i++) {
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.frame = CGRectMake(left + i * (size + left), 0, size, size);
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [imgView fq_setImageWithURLString:currentUser.honors[i].picUrl placeholder:[UIImage new]];
        [self.honorsView addSubview:imgView];
        
        width += (left + size);
    }
    
    self.honorsView.frame = CGRectMake(0, 0, width, size);
    self.honorsView.center = CGPointMake(CGRectGetMaxX(self.genderIcon.frame) + CGRectGetWidth(self.honorsView.frame) * 0.5, CGRectGetMidY(self.genderIcon.frame));
}

- (void)p_updateSocialViewWithUser:(WLUserBase *)currentUser x:(CGFloat)x right:(CGFloat)right {
    if ([[AppContext getInstance].accountManager.myAccount.uid isEqualToString:self.userID]) {
        self.iconsView.hidden = NO;
        
        self.iconsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.youtBtn.bounds) * 3 + right * 2, 32);
        self.iconsView.center = CGPointMake(CGRectGetWidth(self.containerTableView.frame) - x - CGRectGetWidth(self.iconsView.frame) * 0.5, CGRectGetMidY(self.genderIcon.frame));
        
        CGFloat centerX = CGRectGetWidth(self.iconsView.bounds) - CGRectGetWidth(self.youtBtn.bounds) * 0.5;
        CGFloat centerY = CGRectGetHeight(self.iconsView.bounds) * 0.5;
        
        self.fbBtn.hidden = self.insBtn.hidden = self.youtBtn.hidden = NO;
        self.fbBtn.selected = self.insBtn.selected = self.youtBtn.selected = NO;
        
        self.youtBtn.center = CGPointMake(centerX, centerY);
        centerX -= (CGRectGetWidth(self.youtBtn.bounds) + right);
        self.insBtn.center = CGPointMake(centerX, centerY);
        centerX -= (CGRectGetWidth(self.insBtn.bounds) + right);
        self.fbBtn.center = CGPointMake(centerX, centerY);
        
        for (NSInteger i = currentUser.links.count - 1; i >= 0; i--) {
            if (![currentUser.links[i] isKindOfClass:[WLUserLinkModel class]]) {
                continue;
            }
            
            WLUserLinkModel *model = (WLUserLinkModel *)currentUser.links[i];
            switch (model.linkType) {
                case WLUserLinkType_Facebook:
                    self.fbBtn.tag = i;
                    self.fbBtn.selected = YES;
                    break;
                case WLUserLinkType_Instagram:
                    self.insBtn.tag = i;
                    self.insBtn.selected = YES;
                    break;
                case WLUserLinkType_YouTube:
                    self.youtBtn.tag = i;
                    self.youtBtn.selected = YES;
                    break;
            }
        }
    } else {
        if (currentUser.curLevel > WLUserLevel_Star && currentUser.links.count > 0) {
            self.iconsView.hidden = NO;
            
            self.iconsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.youtBtn.bounds) * currentUser.links.count + right * (currentUser.links.count - 1), 32);
            self.iconsView.center = CGPointMake(CGRectGetWidth(self.containerTableView.frame) - x - CGRectGetWidth(self.iconsView.frame) * 0.5, CGRectGetMidY(self.genderIcon.frame));
            
            CGFloat centerX = CGRectGetWidth(self.iconsView.bounds) - CGRectGetWidth(self.youtBtn.bounds) * 0.5;
            CGFloat centerY = CGRectGetHeight(self.iconsView.bounds) * 0.5;
            
            self.fbBtn.hidden = self.insBtn.hidden = self.youtBtn.hidden = YES;
            self.fbBtn.selected = self.insBtn.selected = self.youtBtn.selected = NO;
            
            for (NSInteger i = currentUser.links.count - 1; i >= 0; i--) {
                if (![currentUser.links[i] isKindOfClass:[WLUserLinkModel class]]) {
                    continue;
                }
                
                WLUserLinkModel *model = (WLUserLinkModel *)currentUser.links[i];
                switch (model.linkType) {
                    case WLUserLinkType_Facebook:
                        self.fbBtn.tag = i;
                        self.fbBtn.hidden = NO;
                        self.fbBtn.selected = YES;
                        self.fbBtn.center = CGPointMake(centerX, centerY);
                        break;
                    case WLUserLinkType_Instagram:
                        self.insBtn.tag = i;
                        self.insBtn.hidden = NO;
                        self.insBtn.selected = YES;
                        self.insBtn.center = CGPointMake(centerX, centerY);
                        centerX -= (CGRectGetWidth(self.insBtn.bounds) + right);
                        break;
                    case WLUserLinkType_YouTube:
                        self.youtBtn.tag = i;
                        self.youtBtn.hidden = NO;
                        self.youtBtn.selected = YES;
                        self.youtBtn.center = CGPointMake(centerX, centerY);
                        centerX -= (CGRectGetWidth(self.youtBtn.bounds) + right);
                        break;
                }
            }
        } else {
            self.iconsView.hidden = YES;
        }
    }
}

- (void)p_layoutTableHeaderViewWithUser:(WLUserBase *)currentUser {
    CGFloat avatarSize = kAvatarSizeLarge;
    CGFloat left = 12, right = 12, top = 12;
    CGFloat x = left, y = top, marginY = 8;
    
    if (!currentUser) {
        self.containerTableView.tableHeaderView.hidden = YES;
        return;
    }
    
    self.containerTableView.tableHeaderView.hidden = NO;
    
    [self p_updateCoverBgViewWithUser:currentUser];
    
    [self.avatarView setUser:currentUser];
    self.avatarView.frame = CGRectMake(x, y, avatarSize, avatarSize);
    x = CGRectGetMaxX(self.avatarView.frame) + left;
    
    [self p_updateFollowInfoViewWithUser:currentUser x:x y:y right:right];
    y += (CGRectGetHeight(self.followInfoView.bounds) + marginY * 0.5);
    
    [self p_updateOperateViewWithUser:currentUser x:x right:right];
    
    x = left;
    y = (CGRectGetMaxY(self.avatarView.frame) + marginY);
    
    {
        if (!currentUser) {
            self.nameLabel.text = currentUser.nickName;
            [self.nameLabel sizeToFit];
            
        } else {
            NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:currentUser.nickName ?: @""
                                                                                         attributes:@{NSForegroundColorAttributeName: kNameFontColor,
                                                                                                      NSFontAttributeName: kBoldFont(kNameFontSize)}];
            CGSize nameSize = [attrName boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.view.bounds) - x * 2, kScreenHeight)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                     context:nil].size;
            
//            UIImage *img = currentUser.gender == WELIKE_USER_GENDER_MALE ? [AppContext getImageForKey:@"user_male"] :
//            (currentUser.gender == WELIKE_USER_GENDER_FEMALE ? [AppContext getImageForKey:@"user_female"] : nil);
//
//            if (img) {
//                CGFloat imgWidth = img.size.width, imgHeight = img.size.height, paddingX = 6;
//                CGFloat paddingY = (imgHeight - nameSize.height) / 2.0;
//                paddingY = paddingY > 0 ? -paddingY : paddingY;
//
//                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
//                attachment.image = img;
//                attachment.bounds = CGRectMake(paddingX, paddingY, imgWidth, imgHeight);
//                [attrName appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
//                self.nameLabel.attributedText = attrName;
//
//                nameSize = [attrName boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.view.bounds) - x * 2, kScreenHeight)
//                                                  options:NSStringDrawingUsesLineFragmentOrigin
//                                                  context:nil].size;
//                self.nameLabel.frame = CGRectMake(0, 0, nameSize.width + paddingX + imgWidth, nameSize.height);
//
//            } else {
//                self.nameLabel.attributedText = attrName;
//                self.nameLabel.frame = CGRectMake(0, 0, nameSize.width, nameSize.height);
//            }
            
            self.nameLabel.attributedText = attrName;
            self.nameLabel.frame = CGRectMake(0, 0, nameSize.width, nameSize.height);
            
            self.nameLabel.center = CGPointMake(x + CGRectGetWidth(self.nameLabel.bounds) * 0.5, y + CGRectGetHeight(self.nameLabel.bounds) * 0.5);
        }
        y += (CGRectGetHeight(self.nameLabel.bounds) + marginY * 0.5);
    }
    
    [self p_updateDescViewWithUser:currentUser x:x y:y];
    y += (CGRectGetHeight(self.descLabel.bounds) + marginY);
    
    [self p_updateGenderViewWithUser:currentUser x:x y:y];
    
    [self p_updateHonorsViewWithUser:currentUser];
    
    [self p_updateSocialViewWithUser:currentUser x:x right:right];
    if (self.iconsView.hidden) {
        y += (CGRectGetHeight(self.genderIcon.frame) + marginY);
    } else {
        y += CGRectGetHeight(self.iconsView.bounds);
    }
    
    self.headerFooterView.frame = CGRectMake(0, y, CGRectGetWidth(self.view.bounds), marginY);
    
    UIView *headerView = self.containerTableView.tableHeaderView;
    headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetMaxY(self.headerFooterView.frame));
    self.containerTableView.tableHeaderView = headerView;
}

- (UIImage *)p_snapshotImage:(UIView *)view {
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(view.frame.size, view.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Setter

- (void)setCurrentUser:(WLUserBase *)currentUser {
    _currentUser = currentUser;
    
    [self.navFollowBtn setUser:(WLUser *)currentUser];
    
    [self p_updateNavTitle:self.currentUser.nickName];
    self.originalNavTitleWidth = CGRectGetWidth(self.navigationBar.titleLabel.frame);
    
    [self p_layoutTableHeaderViewWithUser:currentUser];
}

- (void)setNormalUser:(BOOL)normalUser {
    _normalUser = normalUser;
    
    if (normalUser) {
        self.contentInsetTop = kNavBarHeight;
    } else {
        self.contentInsetTop = kTopBgHeight;
    }
}

#pragma mark - Getter

- (WLMainTableView *)containerTableView {
    if (!_containerTableView) {
        WLMainTableView *tableView = [[WLMainTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)
                                                                      style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.sectionHeaderHeight = CGRectGetHeight(self.segmentedCtr.bounds);
        tableView.sectionFooterHeight = CGFLOAT_MIN;
        tableView.rowHeight = [self p_scrollCellHeight];
        _containerTableView = tableView;
        
        if (@available(iOS 11.0, *)) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        tableView.contentInset = UIEdgeInsetsMake(self.contentInsetTop, 0, 0, 0);
        
        [tableView addSubview:({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -kScreenHeight, CGRectGetWidth(self.view.bounds), kScreenHeight)];
            view.clipsToBounds = YES;
            view.backgroundColor = [UIColor whiteColor];

            UIImageView *imgView = [[UIImageView alloc] initWithFrame:view.bounds];
            imgView.hidden = YES;
            [view addSubview:imgView];
            self.coverBgView = imgView;

            CALayer *maskLayer = [CALayer layer];
            maskLayer.frame = imgView.bounds;
            maskLayer.backgroundColor = kUIColorFromRGBA(0x000000, 0.2).CGColor;
            [imgView.layer addSublayer:maskLayer];

            view.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgViewTapped:)];
            [view addGestureRecognizer:tap];

            view;
        })];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                      CGRectGetWidth(self.view.bounds),
                                                                      0)];
        headerView.backgroundColor = [UIColor whiteColor];
        headerView.clipsToBounds = NO;
        tableView.tableHeaderView = headerView;
        [tableView bringSubviewToFront:headerView];
        
        {
            WLHeadView *avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
            avatarView.frame = CGRectMake(0, 0, kAvatarSizeLarge, kAvatarSizeLarge);
            [avatarView addBorder];
            [avatarView addShadow];
            [headerView addSubview:avatarView];
            self.avatarView = avatarView;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewOnTapped)];
            [avatarView addGestureRecognizer:tap];
        }
        
        {
            UIView *operateView = ({
                UIView *view = [[UIView alloc] init];
                view.backgroundColor = [UIColor clearColor];
                
                if ([self.userID isEqualToString:[AppContext getInstance].accountManager.myAccount.uid]) {
                    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    editBtn.backgroundColor = [UIColor whiteColor];
                    [editBtn setTitle:[AppContext getStringForKey:@"mine_edit_profile" fileName:@"user"] forState:UIControlStateNormal];
                    [editBtn setTitleColor:kNameFontColor forState:UIControlStateNormal];
                    editBtn.titleLabel.font = kBoldFont(kLightFontSize);
                    editBtn.layer.borderColor = kUIColorFromRGB(0xDDDDDD).CGColor;
                    editBtn.layer.borderWidth = 1.0;
                    [editBtn addTarget:self action:@selector(userEditOnTapped) forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:editBtn];
                    self.editBtn = editBtn;
                } else {
                    UIButton *(^createBtnBlock)(NSString *imgName, SEL action) = ^(NSString *imgName, SEL action) {
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.backgroundColor = [UIColor whiteColor];
                        btn.layer.borderWidth = 1.0;
                        btn.layer.borderColor = kNameFontColor.CGColor;
                        btn.layer.cornerRadius = kCornerRadius;
                        [btn setImage:[AppContext getImageForKey:imgName] forState:UIControlStateNormal];
                        [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
                        
                        return btn;
                    };
                    
                    UIButton *btn = createBtnBlock(@"profile_message_2", @selector(chatBtnClicked));
                    [view addSubview:btn];
                    self.msgBtn = btn;
                    
                    WLFollowButton *followBtn = [[WLFollowButton alloc] init];
                    followBtn.delegate = self;
                    [view addSubview:followBtn];
                    self.followBtn = followBtn;
                    
                    WLProfileFollowingBtn *followingBtn = [[WLProfileFollowingBtn alloc] init];
                    followingBtn.hidden = YES;
                    followingBtn.delegate = self;
                    [view addSubview:followingBtn];
                    self.smallFollowBtn = followingBtn;
                    
                    UIButton *bigMsgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    bigMsgBtn.hidden = YES;
                    bigMsgBtn.backgroundColor = [UIColor whiteColor];
                    bigMsgBtn.layer.borderColor = kMainColor.CGColor;
                    bigMsgBtn.layer.borderWidth = 1.0;
                    bigMsgBtn.layer.cornerRadius = kCornerRadius;
                    [bigMsgBtn setTitle:[[AppContext getStringForKey:@"mine_user_host_bottom_message" fileName:@"user"] uppercaseString] forState:UIControlStateNormal];
                    [bigMsgBtn setTitleColor:kMainColor forState:UIControlStateNormal];
                    bigMsgBtn.titleLabel.font = kBoldFont(kLightFontSize);
                    [bigMsgBtn addTarget:self action:@selector(chatBtnClicked) forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:bigMsgBtn];
                    self.msgBigBtn = bigMsgBtn;
                }
                
                view;
            });
            [headerView addSubview:operateView];
            self.operateView = operateView;
        }
        
        {
            UILabel *nameLab = [[UILabel alloc] init];
            nameLab.numberOfLines = 1;
            nameLab.textAlignment = NSTextAlignmentLeft;
            [headerView addSubview:nameLab];
            self.nameLabel = nameLab;
            
            nameLab.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userEditOnTapped)];
            [nameLab addGestureRecognizer:tap];
        }
        
        UIView *followInfoView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor clearColor];
            
            _followingLabel = [[UILabel alloc] init];
            _followingLabel.numberOfLines = 2;
            _followingLabel.textAlignment = NSTextAlignmentCenter;
            [view addSubview:_followingLabel];
            {
                _followingLabel.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followingLabelTapped)];
                [_followingLabel addGestureRecognizer:tap];
            }
            
            _followersLabel = [[UILabel alloc] init];
            _followersLabel.numberOfLines = 2;
            _followersLabel.textAlignment = NSTextAlignmentCenter;
            [view addSubview:_followersLabel];
            {
                _followersLabel.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followersLabelTapped)];
                [_followersLabel addGestureRecognizer:tap];
            }
            
            _likesLabel = [[UILabel alloc] init];
            _likesLabel.numberOfLines = 2;
            _likesLabel.textAlignment = NSTextAlignmentCenter;
            [view addSubview:_likesLabel];
            {
                _likesLabel.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likesLabelTapped)];
                [_likesLabel addGestureRecognizer:tap];
            }
            
            view;
        });
        [headerView addSubview:followInfoView];
        self.followInfoView = followInfoView;
        
        {
            WLFoldLabel *descLab = [[WLFoldLabel alloc] init];
            descLab.delegate = self;
//            descLab.textColor = kNameFontColor;
//            descLab.font = kRegularFont(kLightFontSize);
//            descLab.numberOfLines = 0;
//            descLab.textAlignment = NSTextAlignmentLeft;
//            descLab.minNumberOfLines = 2;
            [headerView addSubview:descLab];
            self.descLabel = descLab;
        }
        
        UIView *iconsView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor clearColor];
            
            UIButton *(^btnFactory)(NSString *, NSString *, SEL) = ^(NSString *normal, NSString *selected, SEL sel) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setImage:[AppContext getImageForKey:normal] forState:UIControlStateNormal];
                [btn setImage:[AppContext getImageForKey:selected] forState:UIControlStateSelected];
                [btn sizeToFit];
                btn.selected = NO;
                [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
                return btn;
            };
            
            _fbBtn = btnFactory(@"icon_profile_facebook_20", @"icon_profile_facebook_highlight_20", @selector(linkBtnClicked:));
            [view addSubview:_fbBtn];
            
            _insBtn = btnFactory(@"icon_profile_ins_20", @"icon_profile_ins_highlight_20", @selector(linkBtnClicked:));
            [view addSubview:_insBtn];
            
            _youtBtn = btnFactory(@"icon_profile_youtube_20", @"icon_profile_youtube_highlight_20", @selector(linkBtnClicked:));
            [view addSubview:_youtBtn];
            
            view;
        });
        [headerView addSubview:iconsView];
        self.iconsView = iconsView;
        
        self.genderIcon = ({
            UIImageView *view = [[UIImageView alloc] init];
            view.backgroundColor = [UIColor clearColor];
            view.contentMode = UIViewContentModeScaleAspectFit;
            [headerView addSubview:view];
            
            view;
        });
        
        self.honorsView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor clearColor];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(honorsViewTapped)];
            [view addGestureRecognizer:tap];
            
            [headerView addSubview:view];
            view;
        });
        
        UIView *footView = [[UIView alloc] init];
        footView.backgroundColor = kTableViewBgColor;
        [headerView addSubview:footView];
        self.headerFooterView = footView;
        
        [self p_layoutTableHeaderViewWithUser:self.currentUser];
    }
    return _containerTableView;
}

- (WLSegmentedControl *)segmentedCtr {
    if (!_segmentedCtr) {
        WLSegmentedControl *segmentCtr = [[WLSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kSegmentHeight)];
        segmentCtr.backgroundColor = [UIColor whiteColor];
        segmentCtr.currentIndex = 0;
        segmentCtr.delegate = self;
        _segmentedCtr = segmentCtr;
    }
    return _segmentedCtr;
}

@end
