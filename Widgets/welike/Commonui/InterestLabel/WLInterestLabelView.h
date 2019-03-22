//
//  WLInterestLabelView.h
//  welike
//
//  Created by luxing on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLInterestLabelModel.h"
#import "UIImageView+WebCache.h"

@class WLInterestLabelView;

@protocol WLInterestLabelViewDelegate<NSObject>

- (void)didClickInterestLabel:(WLInterestLabelView *)label;

- (void)didClickInterestLabelImageView:(WLInterestLabelView *)label;

@end

@interface WLInterestLabelView : UIImageView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) WLInterestLabelModel *labelModel;

@property (nonatomic, weak) id<WLInterestLabelViewDelegate> delegate;

- (void)bindModel:(WLInterestLabelModel *)model;

- (void)clickSelectImageView;

@end
