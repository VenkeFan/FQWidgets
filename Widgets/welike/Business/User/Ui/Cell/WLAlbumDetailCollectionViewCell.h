//
//  WLAlbumDetailCollectionViewCell.h
//  welike
//
//  Created by fan qi on 2018/12/17.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLAlbumPicModel, WLAlbumDetailCollectionViewCell;

NS_ASSUME_NONNULL_BEGIN

@protocol WLAlbumDetailCollectionViewCellDelegate <NSObject>

- (void)albumDetailCellDidTapped:(WLAlbumDetailCollectionViewCell *)cell;

@end

@interface WLAlbumDetailCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) WLAlbumPicModel *cellModel;
@property (nonatomic, weak) id<WLAlbumDetailCollectionViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
