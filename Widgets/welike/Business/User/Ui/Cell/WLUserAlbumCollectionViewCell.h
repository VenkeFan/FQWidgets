//
//  WLUserAlbumCollectionViewCell.h
//  welike
//
//  Created by fan qi on 2018/12/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLAlbumPicModel;

NS_ASSUME_NONNULL_BEGIN

@interface WLUserAlbumCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imgView;
@property (nonatomic, strong) WLAlbumPicModel *cellModel;

@end

NS_ASSUME_NONNULL_END
