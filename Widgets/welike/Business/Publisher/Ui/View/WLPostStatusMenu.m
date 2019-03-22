//
//  WLPostStatusMenu.m
//  welike
//
//  Created by gyb on 2018/11/20.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLPostStatusMenu.h"
#import "WLInterestLayout.h"
#import "WLStatusInfo.h"
#import "WLSelectStatusCell.h"

static NSString * const reuseStatusCellID = @"WLSelectStatusCell";

@interface WLPostStatusMenu () <UICollectionViewDelegate, UICollectionViewDataSource,WLInterestLayoutDelegate>
{
    UIView *selectLine;
}

//@property (nonatomic, strong) WLWatchWithoutLoginRequestManager *manager;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) WLInterestLayout *collectionViewLayout;
//@property (nonatomic, strong, readwrite) NSMutableArray<WLVerticalItem *> *dataArray;
@property (nonatomic, strong) NSMutableDictionary *itemWidthDic;

@end

@implementation WLPostStatusMenu

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        [self.collectionView addSubview:self.selectLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
}


#pragma mark - WLInterestLayoutDelegate

- (CGFloat)interestLayout:(WLInterestLayout *)layout widthForIndexPath:(NSIndexPath *)indexPath {
    WLStatusInfo *itemModel = self.dataArray[indexPath.row];
    if (![self.itemWidthDic.allKeys containsObject:indexPath]) {
        [self.itemWidthDic setObject:@([WLSelectStatusCell widthForItem:itemModel]) forKey:indexPath];
    }
    return [self.itemWidthDic[indexPath] floatValue];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLSelectStatusCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseStatusCellID forIndexPath:indexPath];
    [cell setItemModel:self.dataArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self setCurrentIndex:indexPath.row];
    [self caculatePositionXAndMove:indexPath.row];
}

#pragma mark - Setter

-(void)setDataArray:(NSArray * _Nonnull)dataArray
{
    _dataArray = dataArray;
    
    //在这里开始显示
    [self caculatePositionXAndMove:0];
    
    [_collectionView reloadData];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (currentIndex == _currentIndex) {
        return;
    }
    _preIndex = _currentIndex;
    _currentIndex = currentIndex;

    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];

    [self.dataArray enumerateObjectsUsingBlock:^(WLStatusInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isSelected = (idx == currentIndex);
    }];

    [self.collectionView reloadData];

    if ([self.delegate respondsToSelector:@selector(interestView:didSetCurrentIndex:preIndex:)]) {
        [self.delegate interestView:self didSetCurrentIndex:currentIndex preIndex:_preIndex];
        [self caculatePositionXAndMove:currentIndex];
    }
}

#pragma mark - Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[WLSelectStatusCell class] forCellWithReuseIdentifier:reuseStatusCellID];
    }
    return _collectionView;
}
- (WLInterestLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[WLInterestLayout alloc] init];
        _collectionViewLayout.delegate = self;
        _collectionViewLayout.height = self.height;
        _collectionViewLayout.minimumInteritemSpacing = 0;
        _collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    }
    return _collectionViewLayout;
}

-(UIView *)selectLine{
    if (!selectLine)
    {
        selectLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 5, 16, 3)];
        selectLine.backgroundColor = kMainColor;
    }
    return selectLine;
}


//- (NSMutableArray *)dataArray {
//    if (!_dataArray) {
//        _dataArray = [NSMutableArray array];
//    }
//    return _dataArray;
//}

- (NSMutableDictionary *)itemWidthDic {
    if (!_itemWidthDic) {
        _itemWidthDic = [NSMutableDictionary dictionary];
    }
    return _itemWidthDic;
}

-(void)caculatePositionXAndMove:(NSInteger)indexNum
{
    CGFloat desX = 0;
    
    for (int i = 0; i <= indexNum; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        WLStatusInfo *itemModel = self.dataArray[indexPath.row];
        if (![self.itemWidthDic.allKeys containsObject:indexPath]) {
            [self.itemWidthDic setObject:@([WLSelectStatusCell widthForItem:itemModel]) forKey:indexPath];
        }
        
        if ( i == indexNum)
        {
            desX +=  ([self.itemWidthDic[indexPath] floatValue] - 16)/2.0;
        }
        else
        {
            desX +=  [self.itemWidthDic[indexPath] floatValue];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    //动画移动
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.selectLine.left = desX;
    } completion:^(BOOL finished) {
        //NSLog(@"finsh");
    }];
}



@end
