//
//  WLBadgeCollectionView.h
//  welike
//
//  Created by fan qi on 2019/2/21.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLBadgeCollectionView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;

@end

NS_ASSUME_NONNULL_END
