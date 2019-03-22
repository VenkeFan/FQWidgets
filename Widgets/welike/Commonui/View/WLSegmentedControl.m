//
//  WLSegmentedControl.m
//  welike
//
//  Created by fan qi on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSegmentedControl.h"

@interface WLSegmentedControl ()

@property (nonatomic, weak) UIView *markLine;
@property (nonatomic, weak) UIView *hSeparateLine;
@property (nonatomic, strong) NSMutableArray<UIButton *> *btnArray;

@end

@implementation WLSegmentedControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _btnArray = [NSMutableArray array];
        _showShadow = NO;
    }
    return self;
}

- (void)dealloc {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutUI];
}

#pragma mark - View

- (void)layoutUI {
    if (self.items.count == 0 || _btnArray.count > 0) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(self.bounds) / self.items.count;
    CGFloat actualWidth = 0;
    
    for (int i = 0; i < self.items.count; i++) {
        if ([self.items[i] isKindOfClass:[NSString class]]) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i;
            btn.selected = i == _currentIndex;
            [btn setTitle:self.items[i] forState:UIControlStateNormal];
            [btn setTitleColor:self.tintColor forState:UIControlStateNormal];
            [btn setTitleColor:self.onTintColor forState:UIControlStateSelected];
            btn.titleLabel.font = btn.selected ? self.onTintFont : self.tintFont;
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btn sizeToFit];
            actualWidth = btn.width > actualWidth ? btn.width : actualWidth;
            btn.width = width;
            btn.center = CGPointMake((i * width) + width * 0.5, self.frame.size.height * 0.5);
            [self addSubview:btn];
            
            [_btnArray addObject:btn];
            
            if (i == 0 || !self.hasSeparateLine) {
                continue;
            }
            UIView *separateLine = [[UIView alloc] init];
            separateLine.frame = CGRectMake(i * width, 10, 1, self.frame.size.height - 20);
            separateLine.backgroundColor = kUIColorFromRGB(0xD8D8D8);
            [self addSubview:separateLine];
        }
    }
    
    
    UIView *hLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, CGRectGetWidth(self.bounds), 1)];
    hLineView.backgroundColor = self.hSeparateLineColor;
    [self addSubview:hLineView];
    _hSeparateLine = hLineView;
    
  //  CGFloat lineWith = (actualWidth + 20) > width ? width : (actualWidth + 20);
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 3, 16, 3)];
    lineView.layer.cornerRadius = CGRectGetHeight(lineView.bounds) * 0.5;
    lineView.backgroundColor = self.markLineColor;
    lineView.center = CGPointMake(_btnArray[_currentIndex].center.x, lineView.center.y);
    [self addSubview:lineView];
    _markLine = lineView;
}

#pragma mark - Public

- (void)setItems:(NSArray *)items {
    _items = items;
    
    if (_btnArray.count > items.count) {
        return;
    }
    
    [_btnArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setTitle:items[idx] forState:UIControlStateNormal];
    }];
}

- (void)setLineOffsetX:(CGFloat)x {
    _markLine.center = CGPointMake(CGRectGetWidth(self.bounds) / self.items.count * 0.5 + x / self.items.count, _markLine.center.y);
}

- (void)hideTitleTipWithIndex:(NSInteger)index {
    if (index < _btnArray.count && index < self.items.count) {
        UIButton *btn = _btnArray[index];
        [btn setTitle:self.items[index] forState:UIControlStateNormal];
    }
}

- (void)addShadow {
    if (self.isShowShadow) {
        return;
    }
    
    _showShadow = YES;
    self.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowPath = CGPathCreateWithRect(CGRectMake(0, 5, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - 5), NULL);
}

- (void)clearShadow {
    if (!self.isShowShadow) {
        return;
    }
    
    _showShadow = NO;
    self.layer.shadowColor = kUIColorFromRGBA(0x000000, 0.0).CGColor;
}

#pragma mark - Events

- (void)btnClicked:(UIButton *)sender {
    if (sender.isSelected) {
        return;
    }
    
    _preIndex = _currentIndex;
    _currentIndex = sender.tag;
    
    [self p_updateBtn:sender];
}

#pragma mark - Private

- (void)p_updateBtn:(UIButton *)sender {
    sender.selected = YES;
    sender.titleLabel.font = self.onTintFont;
    
    for (UIButton *tempBtn in _btnArray) {
        if (![sender isEqual:tempBtn]) {
            tempBtn.selected = NO;
            tempBtn.titleLabel.font = self.tintFont;
        }
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self->_markLine.center = CGPointMake(sender.center.x, self->_markLine.center.y);
    }];
    
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(segmentedControl:didSelectedIndex:)]) {
            [_delegate segmentedControl:self didSelectedIndex:_currentIndex];
        } else if ([_delegate respondsToSelector:@selector(segmentedControl:didSelectedIndex:preIndex:)]) {
            [_delegate segmentedControl:self didSelectedIndex:_currentIndex preIndex:_preIndex];
        }
    }
}

#pragma mark - Setter & Getter

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex == currentIndex) {
        return;
    }
    
    _preIndex = _currentIndex;
    _currentIndex = currentIndex;
    
    if (currentIndex >= 0 && currentIndex < _btnArray.count) {
        [self p_updateBtn:_btnArray[currentIndex]];
    }
}

- (UIColor *)tintColor {
    if (!_tintColor) {
        _tintColor = kLightLightFontColor;
    }
    return _tintColor;
}

- (UIColor *)onTintColor {
    if (!_onTintColor) {
        _onTintColor = kNameFontColor;
    }
    return _onTintColor;
}

- (UIFont *)tintFont {
    if (!_tintFont) {
        _tintFont = kBoldFont(kNameFontSize);
    }
    return _tintFont;
}

- (UIFont *)onTintFont {
    if (!_onTintFont) {
        _onTintFont = kBoldFont(kNameFontSize);
    }
    return _onTintFont;
}

- (UIColor *)markLineColor {
    if (!_markLineColor) {
        _markLineColor = kMainColor;
    }
    return _markLineColor;
}

- (UIColor *)hSeparateLineColor {
    if (!_hSeparateLineColor) {
        _hSeparateLineColor = kSeparateLineColor;
    }
    return _hSeparateLineColor;
}

@end
