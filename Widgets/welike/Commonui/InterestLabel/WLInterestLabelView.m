//
//  WLInterestLabelView.m
//  welike
//
//  Created by luxing on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestLabelView.h"

@interface WLInterestLabelView ()

@property (nonatomic, strong) UIImageView *selectImageView;

@end

@implementation WLInterestLabelView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.layer.cornerRadius = kInterestLabelCorners;
    self.backgroundColor = kInterestLabelFillColor;
//    self.contentMode = UIViewContentModeScaleAspectFit;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kInterestLabelLeftPadding, 0, CGRectGetWidth(self.bounds)-2*kInterestLabelLeftPadding, CGRectGetHeight(self.bounds))];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [self titleTextColor];
    self.titleLabel.font = [UIFont systemFontOfSize:kInterestLabelTitleFontSize];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
    
    self.selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)-kInterestLabelSelectPading, CGRectGetHeight(self.bounds)-kInterestLabelSelectImageSize, kInterestLabelSelectImageSize, kInterestLabelSelectImageSize)];
    self.selectImageView.image = [AppContext getImageForKey:@"normal_checkbox_selected"];
    [self addSubview:self.selectImageView];
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelViewTapped:)];
    [self addGestureRecognizer:tap];
}

- (void)labelViewTapped:(UITapGestureRecognizer *)recognizer
{
    [self clickSelectImageView];
}

- (void)clickSelectImageView
{
    self.labelModel.isSelected = !self.labelModel.isSelected;
    self.selectImageView.hidden = !self.labelModel.isSelected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickInterestLabelImageView:)]) {
        [self.delegate didClickInterestLabelImageView:self];
    }
}

- (UIColor *)titleTextColor
{
    return kInterestLabelTitleColor;
}

- (void)bindModel:(WLInterestLabelModel *)model
{
    self.labelModel = model;
    self.titleLabel.text = self.labelModel.title;
    self.selectImageView.hidden = !self.labelModel.isSelected;
}

@end
