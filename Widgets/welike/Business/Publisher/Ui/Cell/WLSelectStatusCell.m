//
//  WLSelectStatusCell.m
//  welike
//
//  Created by gyb on 2018/11/20.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLSelectStatusCell.h"
#import "WLStatusInfo.h"

@implementation WLSelectStatusCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = kNameFontColor;
        titleLabel.font = kBoldFont(kLightFontSize);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat centerX = CGRectGetWidth(self.frame) * 0.5;
    
    titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 44);
    titleLabel.center = CGPointMake(centerX, 22);
}

- (void)setItemModel:(WLStatusInfo *)itemModel {
    _itemModel = itemModel;
    
    titleLabel.text = itemModel.text;
    
    titleLabel.textColor = itemModel.isSelected ? kMainColor : kNameFontColor;
}

+ (CGFloat)widthForItem:(WLStatusInfo *)itemModel {
    if (!itemModel) {
        return 0.0;
    }
    
    CGSize size = [itemModel.text boundingRectWithSize:CGSizeMake(kScreenWidth, 44)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: kBoldFont(kLightFontSize)}
                                               context:nil].size;
    return size.width + 20;
}

@end
