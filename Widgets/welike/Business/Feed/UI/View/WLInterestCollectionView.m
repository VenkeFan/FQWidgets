//
//  WLInterestCollectionView.m
//  welike
//
//  Created by fan qi on 2018/12/20.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLInterestCollectionView.h"
#import "WLInterestLayout.h"
#import "WLWatchWithoutLoginRequestManager.h"
#import "WLVerticalItem.h"

#define kInterestCollectionViewHeight     30.0

@interface WLInterestCollectionCell : UICollectionViewCell

@property (nonatomic, strong) WLVerticalItem *itemModel;

+ (CGFloat)widthForItem:(WLVerticalItem *)itemModel;

@end

@implementation WLInterestCollectionCell {
    UILabel *_titleLabel;
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
    
    _titleLabel.frame = self.bounds;
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
    
    CGSize size = [itemModel.name boundingRectWithSize:CGSizeMake(kScreenWidth, kInterestCollectionViewHeight)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: kBoldFont(kLightFontSize)}
                                               context:nil].size;
    return size.width + 20;
}

@end

static NSString * const reuseInterestCellID = @"WLInterestCollectionCellID";

@interface WLInterestCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, WLInterestLayoutDelegate>

@property (nonatomic, strong) WLWatchWithoutLoginRequestManager *manager;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) WLInterestLayout *collectionViewLayout;
@property (nonatomic, strong, readwrite) NSMutableArray<WLVerticalItem *> *dataArray;
@property (nonatomic, strong) NSMutableDictionary *itemWidthDic;

@end

@implementation WLInterestCollectionView {
    BOOL _loadError;
}

- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kInterestCollectionViewHeight)]) {
        self.backgroundColor = kUIColorFromRGB(0xFAFAFA);
        self.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowOpacity = 0.08;
        self.layer.shadowPath = CGPathCreateWithRect(self.bounds, NULL);
        
        [self addSubview:self.collectionView];
        
        _loadError = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
}

#pragma mark - Public

- (void)fetchData {
    [self initializeLocalData];
    [self fetchNetworkData];
}

- (void)refreshIfError {
    if (!_loadError) {
        return;
    }
    
    [self fetchNetworkData];
}

#pragma mark - Network

- (void)initializeLocalData {
    WLVerticalItem *item = [[WLVerticalItem alloc] init];
    item.isSelected = YES;
    item.isDefault = YES;
    item.name = [AppContext getStringForKey:@"interest_foryou" fileName:@"common"];
    item.verticalId = kInterestForYouID;
    [self.dataArray addObject:item];
    
    WLVerticalItem *videoItem = [[WLVerticalItem alloc] init];
    videoItem.isSelected = NO;
    videoItem.isDefault = NO;
    videoItem.name = [AppContext getStringForKey:@"discover_status_video" fileName:@"feed"];
    videoItem.verticalId = kInterestVideoID;
    [self.dataArray addObject:videoItem];
    
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(interestCollectionView:didInitLocalItems:)]) {
        [self.delegate interestCollectionView:self didInitLocalItems:self.dataArray];
    }
}

- (void)removeNetworkData {
    for (NSInteger i = self.dataArray.count - 1; i >= 0; i--) {
        if ([self.dataArray[i].verticalId isEqualToString:kInterestForYouID]
            || [self.dataArray[i].verticalId isEqualToString:kInterestVideoID]) {
            continue;
        }
        
        [self.dataArray removeObject:self.dataArray[i]];
    }
}

- (void)fetchNetworkData {
    [self.manager listAllVertical:^(NSArray *items, NSInteger errCode) {
        if (errCode != ERROR_SUCCESS) {
            self->_loadError = YES;
            return;
        }
        
        self->_loadError = NO;
        
        [self removeNetworkData];
        [self.dataArray addObjectsFromArray:items];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            
            if ([self.delegate respondsToSelector:@selector(interestCollectionView:didRecviceItems:)]) {
                [self.delegate interestCollectionView:self didRecviceItems:items];
            }
        });
    }];
}

#pragma mark - WLInterestLayoutDelegate

- (CGFloat)interestLayout:(WLInterestLayout *)layout widthForIndexPath:(NSIndexPath *)indexPath {
    WLVerticalItem *itemModel = self.dataArray[indexPath.row];
    if (![self.itemWidthDic objectForKey:indexPath]) {
        [self.itemWidthDic setObject:@([WLInterestCollectionCell widthForItem:itemModel]) forKey:indexPath];
    }
    
    return [self.itemWidthDic[indexPath] floatValue];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLInterestCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseInterestCellID forIndexPath:indexPath];
    [cell setItemModel:self.dataArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self setCurrentIndex:indexPath.row];
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
    
    if ([self.delegate respondsToSelector:@selector(interestCollectionView:didSetCurrentIndex:preIndex:)]) {
        [self.delegate interestCollectionView:self didSetCurrentIndex:currentIndex preIndex:_preIndex];
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
        [_collectionView registerClass:[WLInterestCollectionCell class] forCellWithReuseIdentifier:reuseInterestCellID];
    }
    return _collectionView;
}

- (WLInterestLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[WLInterestLayout alloc] init];
        _collectionViewLayout.delegate = self;
        _collectionViewLayout.height = kInterestCollectionViewHeight;
        _collectionViewLayout.minimumInteritemSpacing = 0;
        _collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    }
    return _collectionViewLayout;
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

@end
