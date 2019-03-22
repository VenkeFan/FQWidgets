//
//  WLInterestCollectionView.h
//  welike
//
//  Created by fan qi on 2018/12/20.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kInterestForYouID           @"1000"
#define kInterestVideoID            @"1001"

@class WLInterestCollectionView, WLVerticalItem;

@protocol WLInterestCollectionViewDelegate <NSObject>

- (void)interestCollectionView:(WLInterestCollectionView *)view
             didInitLocalItems:(NSArray<WLVerticalItem *> *)localItems;
- (void)interestCollectionView:(WLInterestCollectionView *)view
               didRecviceItems:(NSArray<WLVerticalItem *> *)items;
- (void)interestCollectionView:(WLInterestCollectionView *)view
            didSetCurrentIndex:(NSInteger)currentIndex
                      preIndex:(NSInteger)preIndex;

@end

@interface WLInterestCollectionView : UIView

@property (nonatomic, strong, readonly) NSMutableArray<WLVerticalItem *> *dataArray;
@property (nonatomic, weak) id<WLInterestCollectionViewDelegate> delegate;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign, readonly) NSInteger preIndex;

- (void)fetchData;
- (void)refreshIfError;

@end

