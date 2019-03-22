//
//  WLSelectStatusCell.h
//  welike
//
//  Created by gyb on 2018/11/20.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WLStatusInfo;
@interface WLSelectStatusCell : UICollectionViewCell
{
    UILabel *titleLabel;
}

@property (nonatomic, strong) WLStatusInfo *itemModel;

+ (CGFloat)widthForItem:(WLStatusInfo *)itemModel;

@end

