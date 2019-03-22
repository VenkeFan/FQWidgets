//
//  WLBadgesWearCollectionView.m
//  welike
//
//  Created by fan qi on 2019/2/23.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLBadgesWearCollectionView.h"
#import "WLBadgeModel.h"
#import <objc/runtime.h>

static NSString * const reuseBadgeWearCellID = @"WLBadgeWearCollectionCellKey";

@interface WLBadgeModel (Category)

@property (nonatomic, assign) BOOL selectable;

@end

@implementation WLBadgeModel (Category)

- (void)setSelectable:(BOOL)selectable {
    objc_setAssociatedObject(self, @selector(selectable), @(selectable), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)selectable {
    return [objc_getAssociatedObject(self, @selector(selectable)) boolValue];
}

@end

@interface WLBadgeWearCollectionCell : UICollectionViewCell

@property (nonatomic, strong) WLBadgeModel *cellModel;
@property (nonatomic, strong, readonly) UIImageView *iconView;

@end

@implementation WLBadgeWearCollectionCell {
    UIImageView *_iconView;
    UILabel *_nameLabel;
    UIButton *_selectBtn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
        _iconView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5 - 12);
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.clipsToBounds = YES;
        [self.contentView addSubview:_iconView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) - 3 * 2, 25)];
        _nameLabel.center = CGPointMake(_iconView.center.x, CGRectGetMaxY(_iconView.frame) + 6 + CGRectGetHeight(_nameLabel.frame) * 0.5);
        _nameLabel.textColor = kNameFontColor;
        _nameLabel.font = kRegularFont(kMediumNameFontSize);
        _nameLabel.numberOfLines = 1;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
        
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.enabled = NO;
        _selectBtn.hidden = YES;
        _selectBtn.frame = CGRectMake(0, 0, 42, 18);
        _selectBtn.center = CGPointMake(_iconView.center.x, CGRectGetMaxY(_iconView.frame) - CGRectGetHeight(_selectBtn.frame) * 0.5);
        _selectBtn.backgroundColor = [UIColor whiteColor];
        _selectBtn.layer.cornerRadius = kCornerRadius;
        _selectBtn.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
        _selectBtn.layer.shadowOpacity = 0.2;
        _selectBtn.layer.shadowOffset = CGSizeMake(0, 2);
        _selectBtn.layer.shadowPath = CGPathCreateWithRect(_selectBtn.bounds, NULL);
        [_selectBtn setTitle:[AppContext getStringForKey:@"badges_wear_select" fileName:@"user"] forState:UIControlStateNormal];
        [_selectBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        _selectBtn.titleLabel.font = kBoldFont(10);
        [self addSubview:_selectBtn];
    }
    return self;
}

#pragma mark - Public

- (void)setCellModel:(WLBadgeModel *)cellModel {
    _cellModel = cellModel;
    
    _nameLabel.text = cellModel.name;
    [_iconView fq_setImageWithURLString:cellModel.iconUrl];
    
    _selectBtn.hidden = !cellModel.selectable;
}

@end

@interface WLBadgesWearCollectionView ()

@end

@implementation WLBadgesWearCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.collectionView registerClass:[WLBadgeWearCollectionCell class]
                forCellWithReuseIdentifier:reuseBadgeWearCellID];
    }
    return self;
}

- (void)setSelectable:(BOOL)selectable {
    _selectable = selectable;
    
    for (int i = 0; i < self.dataArray.count; i++) {
        if (![self.dataArray[i] isKindOfClass:[WLBadgeModel class]]) {
            continue;
        }
        
        WLBadgeModel *model = (WLBadgeModel *)self.dataArray[i];
        model.selectable = selectable;
    }
    
    [self.collectionView reloadData];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLBadgeWearCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseBadgeWearCellID forIndexPath:indexPath];
    [cell setCellModel:self.dataArray[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.selectable) {
        return;
    }
    WLBadgeWearCollectionCell *cell = (WLBadgeWearCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(badgesWearCollectionView:selectedView:selectedModel:)]) {
        [self.delegate badgesWearCollectionView:self
                                   selectedView:cell.iconView
                                  selectedModel:self.dataArray[indexPath.row]];
    }
}

@end
