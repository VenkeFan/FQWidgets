//
//  WLRecommendInterestsCell.m
//  welike
//
//  Created by fan qi on 2018/7/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRecommendInterestsCell.h"
#import "WLVerticalItem.h"

#define ItemBtnTag      1000
#define kLeft           12.0
#define kTop            12.0
#define btnHeight       32.0

static CGFloat otherViewsHeight = 0.0;
static CGFloat interestsViewHeight = 0.0;

@interface WLRecommendInterestsCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIView *interestsView;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIView *separateLine;

@property (nonatomic, strong) NSMutableArray *selectedItems;

@end

@implementation WLRecommendInterestsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = [AppContext getStringForKey:@"regist_suggest_interests_title" fileName:@"register"];
        _titleLab.textColor = kNameFontColor;
        _titleLab.font = kBoldFont(kLinkFontSize);
        [_titleLab sizeToFit];
        [self.contentView addSubview:_titleLab];
        
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[AppContext getImageForKey:@"search_sug_del"] forState:UIControlStateNormal];
        [_closeBtn sizeToFit];
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_closeBtn];
        
        _interestsView = [[UIView alloc] initWithFrame:CGRectMake(kLeft, 0, kScreenWidth - kLeft * 2, 0)];
        [self.contentView addSubview:_interestsView];
        
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmBtn setTitle:[AppContext getStringForKey:@"confirm_selection" fileName:@"common"] forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = kBoldFont(kNameFontSize);
        [_confirmBtn sizeToFit];
        _closeBtn.width += kLeft * 2;
        _closeBtn.height += kTop * 2;
        [_confirmBtn addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_confirmBtn];
        
        _separateLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1.0)];
        _separateLine.backgroundColor = kSeparateLineColor;
        [self.contentView addSubview:_separateLine];
        
        otherViewsHeight = CGRectGetHeight(_titleLab.bounds) + CGRectGetHeight(_confirmBtn.bounds) + CGRectGetHeight(_separateLine.bounds);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _titleLab.frame = CGRectMake(kLeft, kTop, CGRectGetWidth(_titleLab.bounds), CGRectGetHeight(_titleLab.bounds));
    _closeBtn.center = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(_closeBtn.bounds) * 0.5, _titleLab.center.y);
    _interestsView.top = CGRectGetMaxY(_titleLab.frame) + kTop;
    _confirmBtn.center = CGPointMake(CGRectGetWidth(self.bounds) - kLeft - CGRectGetWidth(_confirmBtn.bounds) * 0.5, CGRectGetMaxY(_interestsView.frame) + kTop + CGRectGetHeight(_confirmBtn.bounds) * 0.5);
    _separateLine.frame = CGRectMake(0, CGRectGetMaxY(_confirmBtn.frame) + kTop * 0.5, CGRectGetWidth(self.bounds), 1.0);
}

#pragma mark - Public

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    [self createInterestsView:dataArray selectedItemTitle:nil];
}

+ (CGFloat)height {
    return interestsViewHeight + kTop * 3.5 + otherViewsHeight;
}

#pragma mark - Private

- (void)createInterestsView:(NSArray *)subItems selectedItemTitle:(NSString *)selectedItemTitle {
    if (_interestsView.subviews.count == subItems.count) {
        return;
    }
    
    [_interestsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSUInteger itemsCount = subItems.count;
    CGFloat viewWidth = _interestsView.bounds.size.width;
    CGFloat btnX = 0, btnPaddingX = 8, btnPaddingY = 8;
    CGFloat btnY = 0;
    for (int i = 0; i < itemsCount; i ++) {
        WLVerticalItem *industry = subItems[i];
        
        if (![industry isKindOfClass:[WLVerticalItem class]]) {
            continue;
        }
        
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = ItemBtnTag + i;
        [btn setTitle:industry.name forState:UIControlStateNormal];
        [btn setTitleColor:kUIColorFromRGB(0x859EBC) forState:UIControlStateNormal];
        [btn setTitleColor:kUIColorFromRGB(0x3B6393) forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageWithColor:kUIColorFromRGB(0xDCE8F4)] forState:UIControlStateSelected];
        btn.titleLabel.font = kBoldFont(kLinkFontSize);
        btn.titleLabel.numberOfLines = 0;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.layer.borderColor = kUIColorFromRGB(0xDCE8F4).CGColor;
        btn.layer.borderWidth = 1.0;
        btn.layer.cornerRadius = kCornerRadius;
        btn.clipsToBounds = YES;
        [btn sizeToFit];
        [btn addTarget:self action:@selector(itemBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        CGSize btnSize = CGSizeMake(btn.frame.size.width + 20, btnHeight);
        CGRect btnFrame = btn.frame;
        btnFrame.size = btnSize;
        btn.frame = btnFrame;
        
        if (viewWidth - btnX < btn.frame.size.width) {
            btnX = 0;
            btnY += btnHeight + btnPaddingY;
        }
        
        btnFrame.origin = CGPointMake(btnX, btnY);
        btn.frame = btnFrame;
        
        btnX += (btn.frame.size.width + btnPaddingX);
        
        if (selectedItemTitle && [industry.name isEqualToString:selectedItemTitle]) {
            btn.selected = YES;
        }
        
        [_interestsView addSubview:btn];
    }
    
    CGRect frame = _interestsView.frame;
    frame.size.height = btnY + btnHeight;
    _interestsView.frame = frame;
    
    interestsViewHeight = frame.size.height;
}

#pragma mark - Event

- (void)itemBtnClicked:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    
    NSInteger index = sender.tag - ItemBtnTag;
    if (index >= self.dataArray.count) {
        return;
    }
    
    WLVerticalItem *item = self.dataArray[index];
    if (!item.verticalId) {
        return;
    }
    
    if (sender.selected) {
        [self.selectedItems addObject:item.verticalId];
    } else {
        [self.selectedItems removeObject:item.verticalId];
    }
}

- (void)closeBtnClicked {
    [self.selectedItems removeAllObjects];
    
    if ([self.delegate respondsToSelector:@selector(interestsCellDidClosed:)]) {
        [self.delegate interestsCellDidClosed:self];
    }
}

- (void)confirmBtnClicked {
    if (self.selectedItems.count == 0) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(interestsCell:didSelectedItems:)]) {
        [self.delegate interestsCell:self didSelectedItems:self.selectedItems];
    }
}

#pragma mark - Getter

- (NSMutableArray *)selectedItems {
    if (!_selectedItems) {
        _selectedItems = [NSMutableArray array];
    }
    return _selectedItems;
}

@end
