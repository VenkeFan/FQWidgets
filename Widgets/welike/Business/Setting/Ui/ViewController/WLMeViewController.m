//
//  WLMeViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQTabBarController.h"
#import "WLMeViewController.h"
#import "WLSingleUserManager.h"
#import "WLProfileViewModel.h"
#import "WLHeadView.h"
#import "WLSettingCell.h"
#import "WLUserDetailViewController.h"
#import "WLSettingViewController.h"
#import "WLFollowViewController.h"
#import "WLShareViewController.h"
#import "WLUserFollowTabView.h"
#import "WLUser.h"
#import "WLDraftViewController.h"
#import "WLDraftManager.h"
#import "WLTrackerMe.h"
#import "WLMeRequestManager.h"
#import "WLWebViewController.h"
#import "WLUserLikesViewController.h"
#import "WLIMSession.h"
#import "WLPrivateMessageViewController.h"

#define kViewHiddenObserveKey       @"self.view.hidden"
#define shitYellowColor             kUIColorFromRGB(0xB06E00)

static NSString * const kMeReuseCellID = @"meReuseCellID";

@interface WLMeViewController () <UITableViewDelegate, UITableViewDataSource, WLUserFollowTabViewDelegate, WLHeadViewDelegate>

@property (nonatomic, strong) WLProfileViewModel *viewModel;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) WLHeadView *headView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *descLabel;
@property (nonatomic, strong) UIView *honorsView;
@property (nonatomic, weak) WLUserFollowTabView *followView;
@property (nonatomic, strong) WLMeRequestManager *meRequestManager;
@property (nonatomic, copy) NSString *influlencerStr;
@property (nonatomic, strong) WLUser *talkUser;


@end

@implementation WLMeViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - LifeCycle

- (instancetype)init {
    if (self = [super init]) {
//        [self addObserver:self
//               forKeyPath:kViewHiddenObserveKey
//                  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
//                  context:nil];
        _viewModel = [WLProfileViewModel new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _meRequestManager = [[WLMeRequestManager alloc] init];
    
    [_meRequestManager listInfluencer:^(NSString *forwardUrl, NSInteger errCode) {
      
        self->_influlencerStr = forwardUrl;
//        NSLog(@"%@",forwardUrl);
    }];
    
    [_meRequestManager listCustomerService:^(WLUser *user, NSInteger errCode) {
        self->_talkUser = user;
    }];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDraft) name:WLNotificationUpdateDraft object:nil];
    
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self handleDraftData];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Notification
-(void)refreshDraft
{
    [self handleDraftData];
}

-(void)handleDraftData
{
    __weak typeof(self) weakSelf = self;
    
    [[AppContext getInstance].draftManager countAll:^(NSInteger count) {
        
        weakSelf.viewModel.draftNum = count;
        [weakSelf.tableView reloadData];
        
    }];
}

#pragma mark - KVO

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if ([keyPath isEqualToString:kViewHiddenObserveKey]) {
//        if (change[NSKeyValueChangeNewKey] && [change[NSKeyValueChangeNewKey] boolValue] == NO) {
//            [self fetchUserInfo];
//        }
//    }
//}

#pragma mark - Network

- (void)fetchUserInfo {
    [[AppContext getInstance].singleUserManager loadUserDetailWithUid:self.viewModel.account.uid
                                  successed:^(WLUser *user) {
                                      
                                      [self setTableHeaderView:user];
                                      
                                      [self.tableView reloadData];
                                  }
                                      error:^(NSString *uid, NSInteger errCode) {
                                          
                                          [self.tableView reloadData];
                                      }];
}

- (void)setTableHeaderView:(WLUserBase *)currentUser {
    [self.headView setUser:currentUser];
    self.nameLabel.text = currentUser.nickName;
    self.descLabel.text = currentUser.introduction;
    self.followView.user = currentUser;
    
    [self p_updateHonorsViewWithUser:currentUser];
}

- (void)p_updateHonorsViewWithUser:(WLUserBase *)currentUser {
    [self.honorsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger count = currentUser.honors.count >= 2 ? 2 : currentUser.honors.count;
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
    self.honorsView.center = CGPointMake(CGRectGetMaxX(self.nameLabel.frame) + CGRectGetWidth(self.honorsView.frame) * 0.5, CGRectGetMidY(self.nameLabel.frame));
}

#pragma mark - Share

- (void)showShareController:(WLUserBase *)user {
    WLShareModel *shareModel = [WLShareModel modelWithID:user.uid
                                                    type:WLShareModelType_App
                                                   title:user.nickName
                                                    desc:user.introduction
                                                  imgUrl:user.headUrl
                                                 linkUrl:nil];
    
    WLShareViewController *ctr = [[WLShareViewController alloc] init];
    ctr.shareModel = shareModel;
    [self presentViewController:ctr animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataArray[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WLSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kMeReuseCellID];
    [cell setDataSourceItem:self.viewModel.dataArray[indexPath.section][indexPath.row]];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    if (indexPath.section == 0)
    {
         if (indexPath.row == 0)
         {
             if (_influlencerStr.length > 0)
             {
                 WLWebViewController *webViewController = [[WLWebViewController alloc] initWithUrl:_influlencerStr];
                 [[AppContext currentViewController].navigationController pushViewController:webViewController animated:YES];
             }
         }
        
        if (indexPath.row == 1)
        {
            WLUserLikesViewController *ctr = [[WLUserLikesViewController alloc] initWithUserID:self.viewModel.account.uid];
            [self.navigationController pushViewController:ctr animated:YES];
        }
        
        
        if (indexPath.row == 2)
        {
            [self showShareController:self.viewModel.account];
            [WLTrackerMe appendTrackerWithMeAction:WLTrackerMeActionType_ShareApp];
        }
        
        
        if (indexPath.row == 3)
        {
            if (_talkUser)
            {
                WLPrivateMessageViewController *contrloller = [[WLPrivateMessageViewController alloc] initWithUser:_talkUser];
                [[AppContext rootViewController] pushViewController:contrloller animated:YES];
            }
            
        }
        
        if (indexPath.row == 4)
        {
            WLSettingViewController *ctr = [WLSettingViewController new];
            [self.navigationController pushViewController:ctr animated:YES];
            
            [WLTrackerMe appendTrackerWithMeAction:WLTrackerMeActionType_Setting];
        }
        
        
    }
   
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            WLDraftViewController *draftViewController = [[WLDraftViewController alloc] init];
            
            [self.navigationController pushViewController:draftViewController animated:YES];
            
            [WLTrackerMe appendTrackerWithMeAction:WLTrackerMeActionType_Draftbox];
        }
    }
}

#pragma mark - WLUserFollowTabViewDelegate

- (void)userFollowTabViewDidSelectedFollowing:(WLUserFollowTabView *)followView {
    WLFollowViewController *ctr = [[WLFollowViewController alloc] initWithUserID:self.viewModel.account.uid followType:WLFollowType_Following];
    [self.navigationController pushViewController:ctr animated:YES];
    
    [WLTrackerMe appendTrackerWithMeAction:WLTrackerMeActionType_Following];
}

- (void)userFollowTabViewDidSelectedFollowed:(WLUserFollowTabView *)followView {
    WLFollowViewController *ctr = [[WLFollowViewController alloc] initWithUserID:self.viewModel.account.uid followType:WLFollowType_Followed];
    [self.navigationController pushViewController:ctr animated:YES];
    
    [WLTrackerMe appendTrackerWithMeAction:WLTrackerMeActionType_Followers];
}

- (void)userFollowTabViewDidSelectedPosts:(WLUserFollowTabView *)followView {
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithOriginalUserInfo:self.viewModel.account];
    [self.navigationController pushViewController:ctr animated:YES];
    
    [WLTrackerMe appendTrackerWithMeAction:WLTrackerMeActionType_Posts];
}

#pragma mark - FQTabBarControllerProtocol

- (void)viewControllerDidAppeared {
    [self fetchUserInfo];
    
    [WLTrackerMe appendTrackerWithMeAction:WLTrackerMeActionType_Display];
}

#pragma mark - WLHeadViewDelegate

- (void)onClick:(WLHeadView *)headView {
    [self profileViewTapped];
}

#pragma mark - Event

- (void)profileViewTapped {
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithOriginalUserInfo:self.viewModel.account];
    [self.navigationController pushViewController:ctr animated:YES];
    
    [WLTrackerMe appendTrackerWithMeAction:WLTrackerMeActionType_Profile];
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds),
                                                                               kScreenHeight - kTabBarHeight)];
        tableView.backgroundColor = kLightBackgroundViewColor;
        if (kSystemStatusBarHeight == 20) {
            tableView.contentInset = UIEdgeInsetsMake(kSystemStatusBarHeight, 0, 0, 0);
        }
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.sectionHeaderHeight = 10;
        [tableView registerClass:[WLSettingCell class] forCellReuseIdentifier:kMeReuseCellID];
        [self.view addSubview:tableView];
        _tableView = tableView;
        
        [tableView addSubview:({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -kScreenHeight, CGRectGetWidth(self.view.bounds), kScreenHeight)];
            view.backgroundColor = [UIColor whiteColor];
            view;
        })];
        
        
        CGFloat x = 12, y = 8, avatarSize = 64;
        CGFloat profileHeight = 74;
        CGFloat paddingX = 8, paddingY = 10;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                      CGRectGetWidth(self.view.bounds),
                                                                      profileHeight + kUserFollowTabViewHeight)];
        headerView.backgroundColor = [UIColor whiteColor];
        tableView.tableHeaderView = headerView;
        
        UIView *profileView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), profileHeight)];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileViewTapped)];
            [view addGestureRecognizer:tap];
            
            WLHeadView *avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
            avatarView.delegate = self;
            avatarView.frame = CGRectMake(0, 0, avatarSize, avatarSize);
            avatarView.center = CGPointMake(x + avatarSize * 0.5, y + avatarSize * 0.5);
            [avatarView setUser:self.viewModel.account];
            [view addSubview:avatarView];
            self.headView = avatarView;
            
            UIImageView *iconView = [[UIImageView alloc] init];
            iconView.image = [AppContext getImageForKey:@"profile_enter_thin"];
            [iconView sizeToFit];
            iconView.center = CGPointMake(CGRectGetWidth(view.frame) - CGRectGetWidth(iconView.frame) * 0.5 - x, avatarView.center.y);
            [view addSubview:iconView];
            
            UILabel *label = [[UILabel alloc] init];
            label.text = [AppContext getStringForKey:@"view_my_profile" fileName:@"user"];
            label.textColor = kMainColor;
            label.font = kRegularFont(kMediumNameFontSize);
            [label sizeToFit];
            label.center = CGPointMake(CGRectGetMinX(iconView.frame) - CGRectGetWidth(label.frame) * 0.5 - paddingX, avatarView.center.y);
            [view addSubview:label];
            
            UILabel *nameLab = [[UILabel alloc] init];
            nameLab.text = self.viewModel.account.nickName;
            nameLab.textColor = kNameFontColor;
            nameLab.font = kBoldFont(kNameFontSize);
            nameLab.numberOfLines = 1;
            [nameLab sizeToFit];
            nameLab.center = CGPointMake(CGRectGetMaxX(avatarView.frame) + CGRectGetWidth(nameLab.frame) * 0.5 + paddingX, avatarView.center.y - CGRectGetHeight(nameLab.frame) * 0.5 - paddingY * 0.5);
            [view addSubview:nameLab];
            self.nameLabel = nameLab;
            
            UIView *honorsView = [[UIView alloc] init];
            honorsView.backgroundColor = [UIColor clearColor];
            [view addSubview:honorsView];
            self.honorsView = honorsView;
            
            UILabel *descLab = [[UILabel alloc] init];
            descLab.text = self.viewModel.account.introduction;
            descLab.textColor = kLightLightFontColor;
            descLab.font = kRegularFont(kMediumNameFontSize);
            descLab.numberOfLines = 1;
            [descLab sizeToFit];
            descLab.frame = CGRectMake(0, 0, CGRectGetMinX(label.frame) - CGRectGetMinX(nameLab.frame), CGRectGetHeight(descLab.frame));
            descLab.center = CGPointMake(CGRectGetMaxX(avatarView.frame) + CGRectGetWidth(descLab.frame) * 0.5 + paddingX, avatarView.center.y + CGRectGetHeight(descLab.frame) * 0.5 + paddingY * 0.5);
            [view addSubview:descLab];
            self.descLabel = descLab;
            
            view;
        });
        [headerView addSubview:profileView];
        
        WLUserFollowTabView *followView = [[WLUserFollowTabView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(profileView.frame), CGRectGetWidth(headerView.bounds), kUserFollowTabViewHeight)];
        followView.user = self.viewModel.account;
        followView.delegate = self;
        [headerView addSubview:followView];
        self.followView = followView;
    }
    return _tableView;
}

@end
