//
//  WLBadgesWearViewController.m
//  welike
//
//  Created by fan qi on 2019/2/22.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLBadgesWearViewController.h"
#import "WLBadgesManager.h"
#import "WLBadgeModel.h"
#import "WLBadgesWearView.h"
#import "WLBadgesWearCollectionView.h"
#import "WLBadgesWearRulePopView.h"

@interface WLBadgesWearViewController () <WLBadgesManagerDelegate, WLBadgesWearViewDelegate, WLBadgesWearCollectionViewDelegate>

@property (nonatomic, strong) WLBadgesManager *manager;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) WLBadgesWearView *wearView;
@property (nonatomic, strong) WLBadgesWearCollectionView *collectionView;

@end

@implementation WLBadgesWearViewController {
    WLBadgeModel *_oldBadge;
    NSInteger _selectedIndex;
    UIView *_toView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [AppContext getStringForKey:@"badges_wall_title" fileName:@"user"];
    
    [self layoutUI];
    
    [self fetchData];
}

- (void)layoutUI {
    CGFloat y = 0;
    {
        UIView *headerView = [[UIView alloc] init];
        headerView.frame = CGRectMake(0, kNavBarHeight, CGRectGetWidth(self.view.frame), 246);
        headerView.layer.contents = (__bridge id)[AppContext getImageForKey:@"badges_wear_bg"].CGImage;
        headerView.layer.contentsGravity = kCAGravityResize;
        [self.view addSubview:headerView];
        y = CGRectGetMaxY(headerView.frame);
        
        CGFloat top = 12;
        
        UILabel *lab = [[UILabel alloc] init];
        lab.text = [AppContext getStringForKey:@"badges_wear_your" fileName:@"user"];
        lab.textColor = [UIColor whiteColor];
        lab.font = kBoldFont(20);
        [lab sizeToFit];
        lab.center = CGPointMake(CGRectGetWidth(headerView.frame) * 0.5, top + CGRectGetHeight(lab.frame) * 0.5);
        [headerView addSubview:lab];
        
        UIButton *ruleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        ruleBtn.frame = CGRectMake(0, 0, 82, 24);
        ruleBtn.center = CGPointMake(CGRectGetWidth(headerView.frame) - CGRectGetWidth(ruleBtn.frame) * 0.5 + 2, lab.center.y);
        ruleBtn.backgroundColor = [UIColor clearColor];
        [ruleBtn setTitle:[AppContext getStringForKey:@"badges_wear_instr" fileName:@"user"] forState:UIControlStateNormal];
        [ruleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        ruleBtn.titleLabel.font = kBoldFont(kLightFontSize);
        ruleBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        ruleBtn.layer.borderWidth = 1.0;
        ruleBtn.layer.cornerRadius = kCornerRadius;
        [ruleBtn addTarget:self action:@selector(ruleBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:ruleBtn];
        
        _wearView = [[WLBadgesWearView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lab.frame) + top, CGRectGetWidth(headerView.frame), CGRectGetHeight(headerView.frame) - CGRectGetMaxY(lab.frame) - top)];
        _wearView.delegate = self;
        [headerView addSubview:_wearView];
    }
    
    {
        UILabel *lab = [[UILabel alloc] init];
        lab.text = [AppContext getStringForKey:@"badges_wear_available" fileName:@"user"];
        lab.textColor = kNameFontColor;
        lab.font = kBoldFont(20);
        [lab sizeToFit];
        lab.center = CGPointMake(CGRectGetWidth(self.view.frame) * 0.5, y + 12 + CGRectGetHeight(lab.frame) * 0.5);
        [self.view addSubview:lab];
        y = (CGRectGetMaxY(lab.frame) + 12);
        
        _collectionView = [[WLBadgesWearCollectionView alloc] init];
        _collectionView.frame = CGRectMake(0, y, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - y);
        _collectionView.delegate = self;
        [self.view addSubview:_collectionView];
    }
}

- (void)fetchData {
    [self showLoading];
    [self.manager fetchUserBadgesWithUserID:[AppContext getInstance].accountManager.myAccount.uid];
}

#pragma mark - WLBadgesManagerDelegate

- (void)badgesManagerFetch:(WLBadgesManager *)manager
                 dataArray:(NSArray *)dataArray
                   errCode:(NSInteger)errCode {
    [self hideLoading];
    
    if (errCode != ERROR_SUCCESS) {
        return;
    }
    
    
    NSMutableArray *wearedArray = [NSMutableArray array];
    for (int i = 0; i < dataArray.count; i++) {
        if (![dataArray[i] isKindOfClass:[WLBadgeModel class]]) {
            continue;
        }
        
        WLBadgeModel *model = (WLBadgeModel *)dataArray[i];
        if (model.weard) {
            [wearedArray addObject:model];
        }
    }
    [self.wearView setDataArray:wearedArray];
    
    [self.collectionView setDataArray:dataArray];
}

#pragma mark - WLBadgesWearViewDelegate

- (void)badgesWearView:(WLBadgesWearView *)wearView editing:(BOOL)editing {
    self.collectionView.selectable = editing;
}

- (void)badgesWearView:(WLBadgesWearView *)wearView
          selectedView:(UIView *)selectedView
         selectedModel:(WLBadgeModel *)selectedModel
                 index:(NSInteger)index {
    _oldBadge = selectedModel;
    _selectedIndex = index;
    _toView = selectedView;
}

#pragma mark - WLBadgesWearCollectionViewDelegate

- (void)badgesWearCollectionView:(WLBadgesWearCollectionView *)collectionView
                    selectedView:(UIImageView *)selectedView
                   selectedModel:(WLBadgeModel *)selectedModel {
    if (!_oldBadge) {
        _oldBadge = selectedModel;
    }
    
    [[AppContext currentViewController] showLoading];
    [self.manager wearBadgeWithUserID:[AppContext getInstance].accountManager.myAccount.uid
                           newBadgeID:selectedModel.ID
                           oldBadgeID:_oldBadge.ID
                                index:_selectedIndex + 1
                             finished:^(BOOL succeed) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [[AppContext currentViewController] hideLoading];
                                     [self.wearView setEditing:NO];
                                     
                                     if (succeed) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:kWLAccountHonorUpdatedNotificationName object:nil];
                                         
                                         [self p_animateFromView:selectedView
                                                          toView:self->_toView
                                                       completed:^{
                                                           [self.wearView changeOldBadge:self->_oldBadge
                                                                                newBadge:selectedModel
                                                                                   index:self->_selectedIndex];
                                                       }];
                                     }
                                 });
                             }];
}

#pragma mark - Private

- (void)p_animateFromView:(UIImageView *)fromView
                   toView:(UIView *)toView
                completed:(void(^)(void))completed {
    if (!fromView || !toView) {
        return;
    }
    
    UIView *parentView = kCurrentWindow;
    CGRect fromFrame = [fromView convertRect:fromView.bounds toView:parentView];
    CGRect toFrame = [toView convertRect:toView.bounds toView:parentView];
    
    UIImageView *tmpView = [[UIImageView alloc] initWithFrame:fromFrame];
    tmpView.image = fromView.image;
    [parentView addSubview:tmpView];
    
    [UIView animateWithDuration:0.45
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         tmpView.frame = toFrame;
                     }
                     completion:^(BOOL finished) {
                         if (completed) {
                             completed();
                         }
                         [tmpView removeFromSuperview];
                     }];
}

#pragma mark - Event

- (void)ruleBtnClicked {
    [[WLBadgesWearRulePopView new] show];
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
