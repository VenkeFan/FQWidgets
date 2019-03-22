//
//  WLUnloginIntrestView.m
//  welike
//
//  Created by gyb on 2018/8/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUnloginIntrestView.h"
#import "WLInterestLayout.h"
#import "WLWatchWithoutLoginRequestManager.h"
#import "WLVerticalItem.h"
#import "UIImageView+Extension.h"

#define kUnloginIntrestViewHeight     44

@interface WLUnloginInterestCell : UICollectionViewCell

@property (nonatomic, strong) WLVerticalItem *itemModel;

+ (CGFloat)widthForItem:(WLVerticalItem *)itemModel;

@end

@implementation WLUnloginInterestCell {
    UIImageView *_imgView;
    UILabel *_titleLabel;
    
//    UIView *selectLine;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kNameFontColor;
        _titleLabel.font = kBoldFont(kLightFontSize);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
        
      
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat centerX = CGRectGetWidth(self.frame) * 0.5;
    
    _titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 44);
    _titleLabel.center = CGPointMake(centerX, 22);
    
   // selectLine.frame = CGRectMake((_titleLabel.width - 16)/2.0, _titleLabel.bottom - 5, 16, 3);
}

- (void)setItemModel:(WLVerticalItem *)itemModel {
    _itemModel = itemModel;
    
    _titleLabel.text = itemModel.name;
    
    _titleLabel.textColor = itemModel.isSelected ? kMainColor : kNameFontColor;
}

+ (CGFloat)widthForItem:(WLVerticalItem *)itemModel {
    if (!itemModel) {
        return 0.0;
    }
    
    CGSize size = [itemModel.name boundingRectWithSize:CGSizeMake(kScreenWidth, kUnloginIntrestViewHeight)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: kBoldFont(kLightFontSize)}
                                               context:nil].size;
    return size.width + 20;
}

@end

static NSString * const reuseInterestCellID = @"WLFeedTableViewCellID";

@interface WLUnloginIntrestView () <UICollectionViewDelegate, UICollectionViewDataSource, WLInterestLayoutDelegate>
{
      UIView *selectLine;
    BOOL loadTypesError;
}

@property (nonatomic, strong) WLWatchWithoutLoginRequestManager *manager;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) WLInterestLayout *collectionViewLayout;
@property (nonatomic, strong, readwrite) NSMutableArray<WLVerticalItem *> *dataArray;
@property (nonatomic, strong) NSMutableDictionary *itemWidthDic;

@end

@implementation WLUnloginIntrestView

- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kUnloginIntrestViewHeight)]) {
        [self addSubview:self.collectionView];
        [self.collectionView addSubview:self.selectLine];
        
        
        
        [self fetchData];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
}

#pragma mark - Network

- (void)fetchData {
    [self.manager listAllVertical:^(NSArray *items, NSInteger errCode) {
        WLVerticalItem *item = [[WLVerticalItem alloc] init];
        item.isSelected = YES;
        item.isDefault = YES;
        item.name = [AppContext getStringForKey:@"interest_foryou" fileName:@"common"];
        item.icon = @"interest_foryou";
        item.verticalId = @"1000";
        [self.dataArray addObject:item];
        
        WLVerticalItem *videoItem = [[WLVerticalItem alloc] init];
        videoItem.isSelected = NO;
        videoItem.isDefault = NO;
        videoItem.name = [AppContext getStringForKey:@"discover_status_video" fileName:@"feed"];
        videoItem.icon = @"";
        videoItem.verticalId = @"1001";
        [self.dataArray addObject:videoItem];
        
        if (errCode == ERROR_SUCCESS) {
            [self.dataArray addObjectsFromArray:items];
             self->loadTypesError = NO;
        }
        else
        {
            self->loadTypesError = YES;
        }
        
        //在这里开始显示
        [self caculatePositionXAndMove:0];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            
            if ([self.delegate respondsToSelector:@selector(interestView:didRecviceItems:)]) {
                [self.delegate interestView:self didRecviceItems:self.dataArray];
            }
        });
    }];
}

-(void)refreshWhenError
{
    if (loadTypesError)
    {
        [self.manager listAllVertical:^(NSArray *items, NSInteger errCode){
           
            if (items == nil)
            {
                return;
            }
            
            [self.dataArray removeAllObjects];
            
            WLVerticalItem *item = [[WLVerticalItem alloc] init];
            item.isSelected = NO;
            item.isDefault = YES;
            item.name = [AppContext getStringForKey:@"interest_foryou" fileName:@"common"];
            item.icon = @"interest_foryou";
            item.verticalId = @"1000";
            [self.dataArray addObject:item];
            
            WLVerticalItem *videoItem = [[WLVerticalItem alloc] init];
            videoItem.isSelected = NO;
            videoItem.isDefault = NO;
            videoItem.name = [AppContext getStringForKey:@"discover_status_video" fileName:@"feed"];
            videoItem.icon = @"";
            videoItem.verticalId = @"1001";
            [self.dataArray addObject:videoItem];
            
            if (errCode == ERROR_SUCCESS) {
                [self.dataArray addObjectsFromArray:items];
             
          //      self->_currentIndex = 0;
                if (self.dataArray.count > self->_currentIndex)
                {
                    WLVerticalItem *item = self.dataArray[self->_currentIndex];
                    item.isSelected = YES;
                }
                self->loadTypesError = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                    //在这里开始显示
                    [self caculatePositionXAndMove:self->_currentIndex];
                    
                    if ([self.delegate  respondsToSelector:@selector(interestView:refreshWhenIntrestErrorReload: withCurrentIndex:)])
                    {
                        [self.delegate interestView:self refreshWhenIntrestErrorReload:self.dataArray withCurrentIndex:self->_currentIndex];
                    }
                    
                });
            }
            else
            {
                self->loadTypesError = YES;
            }
        }];
    }
}



#pragma mark - WLInterestLayoutDelegate

- (CGFloat)interestLayout:(WLInterestLayout *)layout widthForIndexPath:(NSIndexPath *)indexPath {
    WLVerticalItem *itemModel = self.dataArray[indexPath.row];
    if (![self.itemWidthDic.allKeys containsObject:indexPath]) {
        [self.itemWidthDic setObject:@([WLUnloginInterestCell widthForItem:itemModel]) forKey:indexPath];
    }
    return [self.itemWidthDic[indexPath] floatValue];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLUnloginInterestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseInterestCellID forIndexPath:indexPath];
    [cell setItemModel:self.dataArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self setCurrentIndex:indexPath.row];
     [self caculatePositionXAndMove:indexPath.row];
}

#pragma mark - Setter
- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (currentIndex == _currentIndex) {
        return;
    }
    _preIndex = _currentIndex;
    _currentIndex = currentIndex;
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
    
    [self.dataArray enumerateObjectsUsingBlock:^(WLVerticalItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isSelected = (idx == currentIndex);
    }];
    
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(interestView:didSetCurrentIndex:preIndex:)]) {
        [self.delegate interestView:self didSetCurrentIndex:currentIndex preIndex:_preIndex];
        [self caculatePositionXAndMove:currentIndex];
    }
}

#pragma mark - Getter

- (WLWatchWithoutLoginRequestManager *)manager {
    if (!_manager) {
        _manager = [[WLWatchWithoutLoginRequestManager alloc] init];
    }
    return _manager;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[WLUnloginInterestCell class] forCellWithReuseIdentifier:reuseInterestCellID];
    }
    return _collectionView;
}
- (WLInterestLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[WLInterestLayout alloc] init];
        _collectionViewLayout.delegate = self;
        _collectionViewLayout.height = kUnloginIntrestViewHeight;
        _collectionViewLayout.minimumInteritemSpacing = 0;
        _collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    }
    return _collectionViewLayout;
}

-(UIView *)selectLine{
    if (!selectLine)
    {
        selectLine = [[UIView alloc] initWithFrame:CGRectMake(0, kUnloginIntrestViewHeight - 5, 16, 3)];
        selectLine.backgroundColor = kMainColor;
    }
    return selectLine;
}


- (NSMutableArray<WLVerticalItem *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

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
        WLVerticalItem *itemModel = self.dataArray[indexPath.row];
        if (![self.itemWidthDic.allKeys containsObject:indexPath]) {
            [self.itemWidthDic setObject:@([WLUnloginInterestCell widthForItem:itemModel]) forKey:indexPath];
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
