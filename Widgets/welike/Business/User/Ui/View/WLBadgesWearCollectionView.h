//
//  WLBadgesWearCollectionView.h
//  welike
//
//  Created by fan qi on 2019/2/23.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLBadgeCollectionView.h"

@class WLBadgesWearCollectionView, WLBadgeModel;

@protocol WLBadgesWearCollectionViewDelegate <NSObject>

- (void)badgesWearCollectionView:(WLBadgesWearCollectionView *)collectionView
                    selectedView:(UIImageView *)selectedView
                   selectedModel:(WLBadgeModel *)selectedModel;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WLBadgesWearCollectionView : WLBadgeCollectionView

@property (nonatomic, assign) BOOL selectable;
@property (nonatomic, weak) id<WLBadgesWearCollectionViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
