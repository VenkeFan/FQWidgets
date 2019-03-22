//
//  WLInterestLayout.m
//  welike
//
//  Created by fan qi on 2018/7/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestLayout.h"

@interface WLInterestLayout()

@property (nonatomic, strong) NSMutableArray *attrsArray;
@property (nonatomic, assign) CGFloat left;

@end

@implementation WLInterestLayout

- (instancetype)init {
    if (self = [super init]) {
        _attrsArray = [NSMutableArray array];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self.attrsArray removeAllObjects];
    self.left = 0;
    
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attrsArray addObject:attr];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = self.height;
    CGFloat width = [self.delegate interestLayout:self widthForIndexPath:indexPath];
    CGFloat x = self.left + self.sectionInset.left;
    CGFloat y = 0;
    self.left += (width + self.minimumInteritemSpacing);
    
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attr.frame = CGRectMake(x, y, width, height);
    return attr;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArray;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.left + self.sectionInset.left + self.sectionInset.right, 0);
}

@end
