//
//  WLBadgeCollectionView.m
//  welike
//
//  Created by fan qi on 2019/2/21.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLBadgeCollectionView.h"
#import "WLBadgeModel.h"
#import "WLBadgeInfoPopView.h"

static NSString * const reuseBadgeCellID = @"WLBadgeCollectionCellKey";

@interface WLBadgeCollectionCell : UICollectionViewCell

@property (nonatomic, strong) WLBadgeModel *cellModel;

@end

@implementation WLBadgeCollectionCell {
    UIImageView *_iconView;
    UILabel *_nameLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
        _iconView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5 - 12);
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.clipsToBounds = YES;
        [self.contentView addSubview:_iconView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) - 3 * 2, 25)];
        _nameLabel.center = CGPointMake(_iconView.center.x, CGRectGetMaxY(_iconView.frame) + 6 + CGRectGetHeight(_nameLabel.frame) * 0.5);
        _nameLabel.textColor = kNameFontColor;
        _nameLabel.font = kRegularFont(kMediumNameFontSize);
        _nameLabel.numberOfLines = 1;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
    }
    return self;
}

#pragma mark - Public

- (void)setCellModel:(WLBadgeModel *)cellModel {
    _cellModel = cellModel;
    
    _nameLabel.text = cellModel.name;
    
    if (!cellModel.have) {
        __weak typeof(self) weakSelf = self;
        [_iconView fq_setImageWithURLString:cellModel.iconUrl
                                  completed:^(UIImage *image, NSURL *url, NSError *error) {
                                      if (image) {
                                          __strong typeof(weakSelf) strongSelf = weakSelf;
                                          
                                          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                              UIImage *newImg = [strongSelf p_filterImage:image];
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                 strongSelf->_iconView.image = newImg;
                                              });
                                          });
                                      }
                                  }];
    } else {
        [_iconView fq_setImageWithURLString:cellModel.iconUrl];
    }
}

- (UIImage *)p_filterImage:(UIImage *)originalImg {
    CIImage *inputciImage = [[CIImage alloc] initWithImage:originalImg];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIFalseColor"];
    [filter setValue:inputciImage forKey:kCIInputImageKey];
    [filter setValue:[CIColor colorWithCGColor:[UIColor blackColor].CGColor] forKey:@"inputColor0"];
    [filter setValue:[CIColor colorWithCGColor:[UIColor whiteColor].CGColor] forKey:@"inputColor1"];
    
    CIImage *outputciImg = filter.outputImage;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imgRef = [context createCGImage:outputciImg fromRect:outputciImg.extent];
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    return img;
}

@end

@interface WLBadgeCollectionView ()

@property (nonatomic, strong, readwrite) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation WLBadgeCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSInteger numberInRow = 3;
        CGFloat width = kScreenWidth / (float)numberInRow;
        
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.itemSize = CGSizeMake(width, 130);
        _layout.minimumLineSpacing = 0;
        _layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = YES;
        [_collectionView registerClass:[WLBadgeCollectionCell class]
            forCellWithReuseIdentifier:reuseBadgeCellID];
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _collectionView.frame = self.bounds;
}

#pragma mark - Public

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLBadgeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseBadgeCellID forIndexPath:indexPath];
    [cell setCellModel:self.dataArray[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WLBadgeInfoPopView *view = [[WLBadgeInfoPopView alloc] init];
    view.itemModel = self.dataArray[indexPath.row];
    [view show];
}

@end
