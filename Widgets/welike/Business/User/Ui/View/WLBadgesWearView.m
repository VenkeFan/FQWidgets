//
//  WLBadgesWearView.m
//  welike
//
//  Created by fan qi on 2019/2/22.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLBadgesWearView.h"
#import "WLBadgeModel.h"

@class WLBadgesWearCellView;

#define kMaxWearBadgesCount             6

@protocol WLBadgesWearCellViewDelegate <NSObject>

- (void)badgesWearCellViewDidSelected:(WLBadgesWearCellView *)cell;

@end

@interface WLBadgesWearCellView : UIView

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL hideChangeBtn;
@property (nonatomic, weak) id<WLBadgesWearCellViewDelegate> delegate;
@property (nonatomic, strong) WLBadgeModel *cellModel;

@property (nonatomic, strong, readonly) UIImageView *iconView;

@end

@implementation WLBadgesWearCellView {
    UILabel *_indexLabel;
    UIImageView *_iconView;
    UILabel *_nameLabel;
    UIButton *_changeBtn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _selected = NO;
        
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
        _iconView.image = [AppContext getImageForKey:@"badge_unwear"];
        _iconView.center = CGPointMake(CGRectGetWidth(frame) * 0.5, 12 + CGRectGetHeight(_iconView.frame) * 0.5);
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.clipsToBounds = YES;
        [self addSubview:_iconView];
        
        _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 22)];
        _indexLabel.center = CGPointMake(CGRectGetMinX(_iconView.frame), CGRectGetHeight(_indexLabel.frame) * 0.5);
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.font = kRegularFont(kMediumNameFontSize);
        [self addSubview:_indexLabel];
        
        _changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeBtn.enabled = NO;
        _changeBtn.frame = CGRectMake(0, 0, 42, 18);
        _changeBtn.center = CGPointMake(_iconView.center.x, CGRectGetMaxY(_iconView.frame) - CGRectGetHeight(_changeBtn.frame) * 0.5);
        _changeBtn.backgroundColor = [UIColor whiteColor];
        _changeBtn.layer.cornerRadius = kCornerRadius;
        [_changeBtn setTitle:[AppContext getStringForKey:@"badges_wear_change" fileName:@"user"] forState:UIControlStateNormal];
        [_changeBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        _changeBtn.titleLabel.font = kBoldFont(10);
        [self addSubview:_changeBtn];
        
//        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_iconView.frame) + 4, CGRectGetWidth(frame), 20)];
//        _nameLabel.textColor = [UIColor whiteColor];
//        _nameLabel.font = kRegularFont(kLightFontSize);
//        _nameLabel.textAlignment = NSTextAlignmentCenter;
//        [self addSubview:_nameLabel];
    }
    return self;
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    _indexLabel.text = [NSString stringWithFormat:@"%zd.", index + 1];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    
    if (selected) {
        [_changeBtn setTitle:[AppContext getStringForKey:@"common_cancel" fileName:@"common"] forState:UIControlStateNormal];
    } else {
        [_changeBtn setTitle:[AppContext getStringForKey:@"badges_wear_change" fileName:@"user"] forState:UIControlStateNormal];
    }
}

- (void)setHideChangeBtn:(BOOL)hideChangeBtn {
    _hideChangeBtn = hideChangeBtn;
    
    _changeBtn.hidden = hideChangeBtn;
}

- (void)setCellModel:(WLBadgeModel *)cellModel {
    _cellModel = cellModel;
    
    if (cellModel.iconUrl.length > 0) {
        [_iconView fq_setImageWithURLString:cellModel.iconUrl];
    } else {
        _iconView.image = [AppContext getImageForKey:@"badge_unwear"];
    }
//    _nameLabel.text = cellModel.name;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(badgesWearCellViewDidSelected:)]) {
        [self.delegate badgesWearCellViewDidSelected:self];
    }
}

@end


@interface WLBadgesWearView () <WLBadgesWearCellViewDelegate>

@property (nonatomic, strong) NSMutableArray<WLBadgesWearCellView *> *cellArray;

@end

@implementation WLBadgesWearView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _editing = NO;
        _cellArray = [[NSMutableArray alloc] initWithCapacity:kMaxWearBadgesCount];
        
        NSInteger numberInRow = 3;
        CGFloat width = CGRectGetWidth(self.frame) / (float)numberInRow;
        CGFloat height = CGRectGetHeight(self.frame) * 0.5;
        
        for (int i = 0; i < kMaxWearBadgesCount; i++) {
            WLBadgesWearCellView *cell = [[WLBadgesWearCellView alloc] initWithFrame:CGRectMake((i % numberInRow) * width, (i / numberInRow) * height, width, height)];
            cell.index = i;
            cell.delegate = self;
            [self addSubview:cell];
            
            [_cellArray addObject:cell];
        }
    }
    return self;
}

- (void)setDataArray:(NSMutableArray *)dataArray {
    _dataArray = dataArray;
    
    for (int i = 0; i < dataArray.count; i++) {
        if (![dataArray[i] isKindOfClass:[WLBadgeModel class]]) {
            continue;
        }
        
        WLBadgeModel *model = (WLBadgeModel *)dataArray[i];
        if (model.index >= 0 && model.index < self.cellArray.count) {
            [self.cellArray[model.index] setCellModel:model];
        }
    }
}

- (void)changeOldBadge:(WLBadgeModel *)oldBadge
              newBadge:(WLBadgeModel *)newbadge
                 index:(NSInteger)index {
    for (int i = 0; i < self.dataArray.count; i++) {
        if (![self.dataArray[i] isKindOfClass:[WLBadgeModel class]]) {
            continue;
        }
        
        WLBadgeModel *model = (WLBadgeModel *)self.dataArray[i];
        if ([model.ID isEqualToString:newbadge.ID]
            && model.index >= 0 && model.index < self.cellArray.count) {
            [self.cellArray[model.index] setCellModel:nil];
        }
    }
    
    if (index >= 0 && index < self.cellArray.count) {
        [self.cellArray[index] setCellModel:newbadge];
    }
    
    newbadge.index = index;
    [self.dataArray removeObject:oldBadge];
    [self.dataArray addObject:newbadge];
}

#pragma mark - WLBadgesWearCellViewDelegate

- (void)badgesWearCellViewDidSelected:(WLBadgesWearCellView *)cell {
    if (self.editing) {
        self.editing = NO;
        return;
    }
    
    cell.selected = !cell.selected;
    if (cell.selected && [self.delegate respondsToSelector:@selector(badgesWearView:selectedView:selectedModel:index:)]) {
        [self.delegate badgesWearView:self
                         selectedView:cell.iconView
                        selectedModel:cell.cellModel
                                index:cell.index];
    }
    
    self.editing = YES;
}

#pragma mark - Setter

- (void)setEditing:(BOOL)editing {
    if (_editing == editing) {
        return;
    }
    
    _editing = editing;
    
    if ([self.delegate respondsToSelector:@selector(badgesWearView:editing:)]) {
        [self.delegate badgesWearView:self editing:editing];
    }
    
    for (int i = 0; i < self.cellArray.count; i++) {
        if (editing) {
            self.cellArray[i].hideChangeBtn = !self.cellArray[i].selected;
        } else {
            self.cellArray[i].selected = NO;
            self.cellArray[i].hideChangeBtn = NO;
        }
    }
}

@end
