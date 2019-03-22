//
//  WLInterestLayout.h
//  welike
//
//  Created by fan qi on 2018/7/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLInterestLayout;

@protocol WLInterestLayoutDelegate <NSObject>

- (CGFloat)interestLayout:(WLInterestLayout *)layout widthForIndexPath:(NSIndexPath *)indexPath;

@end

@interface WLInterestLayout : UICollectionViewLayout

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (nonatomic, weak) id<WLInterestLayoutDelegate> delegate;

@end
