//
//  WLRecommendUserArrayCell.m
//  welike
//
//  Created by fan qi on 2018/12/3.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLRecommendUserArrayCell.h"
#import "WLUser.h"
#import "WLHeadView.h"
#import "WLFollowButton.h"
#import "WLUserDetailViewController.h"
#import "WLRecommendUserViewController.h"
#import "WLUsersManager.h"


@class WLRecommendUserCollectionCell;

static NSString * const kRecommentUserCollCellID = @"WLRecommendUserCollectionCellID";

@protocol WLRecommendUserCollectionCellDelegate <NSObject>

- (void)recommendUserCollCell:(WLRecommendUserCollectionCell *)collCell didClickedClose:(WLUser *)cellModel;
- (void)recommendUserCollCell:(WLRecommendUserCollectionCell *)collCell didFollowed:(WLUser *)cellModel;

@end

@interface WLRecommendUserCollectionCell : UICollectionViewCell <WLFollowButtonDelegate>

@property (nonatomic, strong) WLUser *cellModel;
@property (nonatomic, weak) id<WLRecommendUserCollectionCellDelegate> delegate;

@end

@implementation WLRecommendUserCollectionCell {
    WLHeadView *_avatarImgView;
    UILabel *_nameLab;
    UILabel *_introLab;
    WLFollowButton *_followBtn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = kCornerRadius;
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [AppContext getImageForKey:@"recommend_user_close"];
        closeBtn.frame = CGRectMake(0, 0, img.size.width + 6, img.size.height + 6);
        closeBtn.center = CGPointMake(CGRectGetWidth(frame) - CGRectGetWidth(closeBtn.frame) * 0.5 - 6, CGRectGetHeight(closeBtn.frame) * 0.5 + 6);
        [closeBtn setImage:img forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:closeBtn];
        
        CGFloat x = 12, y = 20, avatarSize = 92, linePadding = 12;
        _avatarImgView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        _avatarImgView.frame = CGRectMake(0, 0, avatarSize, avatarSize);
        _avatarImgView.userInteractionEnabled = NO;
        _avatarImgView.center = CGPointMake(CGRectGetWidth(frame) * 0.5, y + avatarSize * 0.5);
        [self.contentView addSubview:_avatarImgView];
        y += (CGRectGetHeight(_avatarImgView.bounds) + linePadding);
        
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = kNameFontColor;
        _nameLab.font = kRegularFont(kMediumNameFontSize);
        _nameLab.numberOfLines = 1;
        _nameLab.textAlignment = NSTextAlignmentCenter;
        _nameLab.frame = CGRectMake(x, y, CGRectGetWidth(frame) - x * 2, _nameLab.font.pointSize + 2);
        [self.contentView addSubview:_nameLab];
        y += (CGRectGetHeight(_nameLab.bounds) + linePadding * 0.5);
        
        _introLab = [[UILabel alloc] init];
        _introLab.textColor = kLightLightFontColor;
        _introLab.font = kRegularFont(kDateTimeFontSize);
        _introLab.numberOfLines = 2;
        _introLab.textAlignment = NSTextAlignmentCenter;
        _introLab.frame = CGRectMake(x, y, CGRectGetWidth(frame) - x * 2, (_introLab.font.pointSize + 2) * 2);
        [self.contentView addSubview:_introLab];
        y += (CGRectGetHeight(_introLab.bounds) + linePadding * 0.5);
        
        _followBtn = [[WLFollowButton alloc] initWithFrame:CGRectMake(x, y, CGRectGetWidth(frame) - x * 2, CGRectGetHeight(kFollowDefaultFrame))];
        _followBtn.delegate = self;
        [self.contentView addSubview:_followBtn];
    }
    return self;
}

#pragma mark - Public

- (void)setCellModel:(WLUser *)cellModel {
    _cellModel = cellModel;
    
    [_avatarImgView setHeadUrl:cellModel.headUrl];
    _nameLab.text = cellModel.nickName;
    _introLab.text = cellModel.introduction;
    [_followBtn setUser:cellModel];
}

#pragma mark - WLFollowButtonDelegate

- (void)followButtonFinished:(WLFollowButton *)followBtn {
    if ([self.delegate respondsToSelector:@selector(recommendUserCollCell:didFollowed:)]) {
        [self.delegate recommendUserCollCell:self didFollowed:self.cellModel];
    }
}

#pragma mark - Event

- (void)closeBtnClicked {
    if ([self.delegate respondsToSelector:@selector(recommendUserCollCell:didClickedClose:)]) {
        [self.delegate recommendUserCollCell:self didClickedClose:self.cellModel];
    }
}

@end

@interface WLRecommendUserArrayCell () <UICollectionViewDelegate, UICollectionViewDataSource, WLRecommendUserCollectionCellDelegate>

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) WLUsersManager *userManager;

@end

@implementation WLRecommendUserArrayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = kTableViewBgColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = [AppContext getStringForKey:@"feed_recommend_user" fileName:@"feed"];
        _titleLab.font = kBoldFont(kMediumNameFontSize);
        [_titleLab sizeToFit];
        [self.contentView addSubview:_titleLab];
        
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn setTitle:[AppContext getStringForKey:@"feed_summary_more" fileName:@"feed"] forState:UIControlStateNormal];
        [_moreBtn setTitleColor:kClickableTextColor forState:UIControlStateNormal];
        _moreBtn.titleLabel.font = kBoldFont(kMediumNameFontSize);
        [_moreBtn sizeToFit];
        [_moreBtn addTarget:self action:@selector(moreBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_moreBtn];
        
        CGFloat spacing = 12;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(136, 210);
        layout.minimumInteritemSpacing = spacing;
        layout.sectionInset = UIEdgeInsetsMake(0, spacing, 0, spacing);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[WLRecommendUserCollectionCell class] forCellWithReuseIdentifier:kRecommentUserCollCellID];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:_collectionView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat x = 12, y = 14;
    _titleLab.frame = CGRectMake(x, y, CGRectGetWidth(_titleLab.bounds), CGRectGetHeight(_titleLab.bounds));
    _moreBtn.center = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(_moreBtn.bounds) * 0.5 - x, _titleLab.center.y);
    
    _collectionView.frame = CGRectMake(0, CGRectGetHeight(_titleLab.bounds) + y * 2, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - (CGRectGetHeight(_titleLab.bounds) + y * 2 + y));
}

#pragma mark - Public

- (void)setCellDataArray:(NSMutableArray<WLUser *> *)cellDataArray {
    _cellDataArray = cellDataArray;
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLRecommendUserCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRecommentUserCollCellID forIndexPath:indexPath];
    [cell setCellModel:self.cellDataArray[indexPath.row]];
    cell.delegate = self;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.cellDataArray.count) {
        WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:self.cellDataArray[indexPath.row].uid];
        [[AppContext rootViewController] pushViewController:ctr animated:YES];
    }
}

#pragma mark - WLRecommendUserCollectionCellDelegate

- (void)recommendUserCollCell:(WLRecommendUserCollectionCell *)collCell didClickedClose:(WLUser *)cellModel {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:collCell];
    if (!indexPath) {
        return;
    }
    [self.cellDataArray removeObject:cellModel];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    
    [self.userManager removeRecommendUser:cellModel.uid];
}

- (void)recommendUserCollCell:(WLRecommendUserCollectionCell *)collCell didFollowed:(WLUser *)cellModel {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:collCell];
    if (!indexPath) {
        return;
    }
    if (indexPath.row + 1 >= self.cellDataArray.count) {
        return;
    }
    
    NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    [self.collectionView scrollToItemAtIndexPath:nextIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - Event

- (void)moreBtnClicked {
    WLRecommendUserViewController *ctr = [[WLRecommendUserViewController alloc] init];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

#pragma mark - Getter

- (WLUsersManager *)userManager {
    if (!_userManager) {
        _userManager = [[WLUsersManager alloc] init];
    }
    return _userManager;
}

@end
