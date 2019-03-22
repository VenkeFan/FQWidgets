//
//  EditSinglePhotoView.m
//  CuctvWeibo
//
//  Created by cuctv-gyb on 17/2/22.
//
//

#import "WLEditSinglePhotoView.h"
#import "WLEditPhotoCollectionViewCell.h"

@interface WLEditSinglePhotoView ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,WLEditPhotoCollectionViewCellDelegate>


@end


@implementation WLEditSinglePhotoView
static NSString *EditPhotoCell = @"EditPhotoCell";

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        
        self.backgroundColor = RGBCOLOR(227, 227, 227);
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(kScreenWidth, self.height);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        self.collectionViewLayout = flowLayout;
        
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.dataSource = self;
        self.delegate = self;
        
        [self registerClass:[WLEditPhotoCollectionViewCell class] forCellWithReuseIdentifier:EditPhotoCell];
    }
    return self;
}

#pragma mark - CollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WLEditPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EditPhotoCell forIndexPath:indexPath];
    
    if (_signalImage || cell.imageView.image)
    {
        cell.signalImage = _signalImage;
    }
    else
    {
          cell.assetModel = self.photoArray[indexPath.row];
    }
    
    cell.delegate = self;
    
    return cell;
}


#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    int pageNum = (scrollView.contentOffset.x + kScreenWidth * 0.5) / kScreenWidth;
    if (self.pageNumBlock) {
        self.pageNumBlock(pageNum);
    }
    
}

#pragma mark - Lazy Load
- (void)setPhotoArray:(NSMutableArray *)photoArray {
    _photoArray = photoArray;
    
    [self reloadData];    
}

-(void)setSignalImage:(UIImage *)signalImage
{
    _signalImage = signalImage;
    
    WLEditPhotoCollectionViewCell *cell = self.visibleCells.firstObject;
    
    cell.imageView.image = signalImage;
}

-(void)imageIsEditFinish
{
    
//    [self reloadData];
    
    
    
}

@end
