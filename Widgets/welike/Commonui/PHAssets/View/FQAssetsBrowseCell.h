//
//  FQAssetsBrowseCell.h
//  welike
//
//  Created by fan qi on 2018/12/24.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLAssetModel, FQAssetsBrowseCell;

@protocol FQAssetsBrowseCellDelegate <NSObject>

@optional
- (void)assetsBrowseCellDidTapped:(FQAssetsBrowseCell *)cell;
- (void)assetsBrowseCellDidClickPlay:(FQAssetsBrowseCell *)cell;

@end

@interface FQAssetsBrowseCell : UICollectionViewCell

@property (nonatomic, strong) WLAssetModel *itemModel;
@property (nonatomic, weak) id<FQAssetsBrowseCellDelegate> delegate;

@end
