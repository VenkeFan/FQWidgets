//
//  FQCarouselCollectionCell.m
//  FQWidgets
//
//  Created by fan qi on 2018/5/20.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQCarouselCollectionCell.h"

@interface FQCarouselCollectionCell ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation FQCarouselCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    _imgView = [[UIImageView alloc] init];
    [self.contentView addSubview:_imgView];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.textColor = [UIColor cyanColor];
    _textLabel.font = [UIFont systemFontOfSize:30];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.frame = CGRectMake(0, 0, kScreenWidth, 50);
    [self.contentView addSubview:_textLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imgView.frame = self.bounds;
    _textLabel.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
}

#pragma mark - Public

- (void)setTitle:(NSString *)title {
    _textLabel.text = title;
}

@end
