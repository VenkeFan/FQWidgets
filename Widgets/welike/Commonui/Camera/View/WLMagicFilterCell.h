//
//  WLMagicFilterCell.h
//  welike
//
//  Created by fan qi on 2018/11/30.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLMagicBasicModel;

static NSString * const reuseCellID = @"WLMagicFilterCellKey";

NS_ASSUME_NONNULL_BEGIN

@interface WLMagicFilterCell : UICollectionViewCell

@property (nonatomic, strong) WLMagicBasicModel *cellModel;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CALayer *downloadLayer;

@end

NS_ASSUME_NONNULL_END
