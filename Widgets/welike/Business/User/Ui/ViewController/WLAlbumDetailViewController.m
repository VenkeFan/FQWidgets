//
//  WLAlbumDetailViewController.m
//  welike
//
//  Created by fan qi on 2018/12/17.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLAlbumDetailViewController.h"
#import "WLAlbumPicModel.h"
#import "WLAlbumDetailCollectionViewCell.h"
#import "WLFeedDetailViewController.h"
#import "WLShareViewController.h"

static NSString * const reuseAlbumDetailCellID = @"WLAlbumDetailCollectionViewCellKey";

@interface WLAlbumDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, WLAlbumDetailCollectionViewCellDelegate>

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong, readwrite) WLAlbumPicModel *itemModel;
@property (nonatomic, strong) NSArray<NSArray<WLAlbumPicModel *> *> *itemArray;
@property (nonatomic, strong) NSMutableArray<WLAlbumPicModel *> *dataArray;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation WLAlbumDetailViewController

- (instancetype)initWithPicModel:(WLAlbumPicModel *)itemModel
                       itemArray:(NSArray<NSArray<WLAlbumPicModel *> *> *)itemArray {
    if (self = [super init]) {
        _itemModel = itemModel;
        _itemArray = itemArray;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.alpha = 0.0;
    self.navigationBar.rightBtn.hidden = NO;
    [self.navigationBar.rightBtn setImage:[[AppContext getImageForKey:@"common_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.navigationBar.rightBtn addTarget:self action:@selector(navRightBtnOnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationBar.tintColor = kUIColorFromRGB(0xFFFFFF);
    
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _layout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight);
    _layout.minimumLineSpacing = 0;
    _layout.minimumInteritemSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[WLAlbumDetailCollectionViewCell class]
        forCellWithReuseIdentifier:reuseAlbumDetailCellID];
    [self.view addSubview:_collectionView];
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self refreshData];
}

- (void)refreshData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.dataArray = [NSMutableArray array];
        
        for (int i = 0; i < self.itemArray.count; i++) {
            NSArray *subArray = self.itemArray[i];
            for (int j = 0; j < subArray.count; j++) {
                
                WLAlbumPicModel *model = subArray[j];
                if (![model isKindOfClass:[WLAlbumPicModel class]]) {
                    continue;
                }
                
                [self.dataArray addObject:model];
                if ([model.ID isEqualToString:self.itemModel.ID]) {
                    self.currentIndex = self.dataArray.count - 1;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.collectionView.contentOffset = CGPointMake(self.currentIndex * kScreenWidth, 0);
            [self.collectionView reloadData];
        });
    });
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLAlbumDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseAlbumDetailCellID forIndexPath:indexPath];
    [cell setCellModel:self.dataArray[indexPath.row]];
    cell.delegate = self;
    return cell;
}

#pragma mark - WLAlbumDetailCollectionViewCellDelegate

- (void)albumDetailCellDidTapped:(WLAlbumDetailCollectionViewCell *)cell {
    WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:cell.cellModel.postID];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - Event

- (void)navRightBtnOnClicked {
    WLShareModel *shareModel = [WLShareModel modelWithID:self.itemModel.postID
                                                    type:WLShareModelType_Feed
                                                   title:self.itemModel.userName
                                                    desc:self.itemModel.postContent];
    
    WLShareViewController *ctr = [[WLShareViewController alloc] init];
    ctr.shareModel = shareModel;
    [self presentViewController:ctr animated:YES completion:nil];
}

@end
