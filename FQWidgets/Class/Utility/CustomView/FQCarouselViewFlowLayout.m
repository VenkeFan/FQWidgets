//
//  FQCarouselViewFlowLayout.m
//  FQWidgets
//
//  Created by fan qi on 2018/5/20.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQCarouselViewFlowLayout.h"

@implementation FQCarouselViewFlowLayout

- (instancetype)init {
    if (self = [super init]) {
        _pagingEnabled = YES;

        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{

    if (!self.pagingEnabled) {
        return [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
    }

    CGRect rect = CGRectZero;
    rect.origin = proposedContentOffset;
    rect.size = self.collectionView.frame.size;

    NSArray<UICollectionViewLayoutAttributes *> *tempArray  = [self layoutAttributesForElementsInRect:rect];

    CGFloat  gap = 1000.f;

    CGFloat  f1_MidX = 0.f;
    for (int i = 0; i < tempArray.count; i++) {

        if (gap > ABS([tempArray[i] center].x - proposedContentOffset.x - self.collectionView.frame.size.width * 0.5)) {
            gap =  ABS([tempArray[i] center].x - proposedContentOffset.x - self.collectionView.frame.size.width * 0.5);
            f1_MidX = [tempArray[i] center].x - proposedContentOffset.x - self.collectionView.frame.size.width * 0.5;
        }
    }
    
    CGPoint  point = CGPointMake(proposedContentOffset.x + f1_MidX , proposedContentOffset.y);
    return point;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *tempArray  = [super  layoutAttributesForElementsInRect:rect];
    return tempArray;
}

- (void)prepareLayout {
    [super prepareLayout];
}

@end
