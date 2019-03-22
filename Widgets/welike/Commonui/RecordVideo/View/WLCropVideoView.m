//
//  WLCropVideoView.m
//  welike
//
//  Created by gyb on 2019/1/8.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLCropVideoView.h"
#import <AVFoundation/AVFoundation.h>

@implementation WLCropVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
       
//        imagesArray = [NSMutableArray arrayWithCapacity:8];
//        [self setupCollectionView];
//        [self setupSubviews];
    }
    return self;
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
    followLayout.itemSize = CGSizeMake(kScreenWidth / 8.0 , kScreenWidth / 8.0);
    followLayout.minimumLineSpacing = 0;
    followLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 12, kScreenWidth, kScreenWidth / 8.0) collectionViewLayout:followLayout];
    collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self addSubview:collectionView];
}

- (void)setupSubviews {
    
    durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, kScreenWidth - 200, 12)];
    durationLabel.textColor = [UIColor whiteColor];
    durationLabel.textAlignment = 1;
    durationLabel.font = [UIFont systemFontOfSize:12];
    durationLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    [self addSubview:durationLabel];
    
    
 
    
    //imageViewWith = kScreenWidth / 8.0 * 0.35;
    imageViewLeft = [[UIImageView alloc] initWithImage:[AppContext getImageForKey:@"LeftCropFlag"]];
    imageViewLeft.frame = CGRectMake(0, 12, 12, kScreenWidth / 8.0);
    imageViewLeft.userInteractionEnabled = YES;
    
    imageViewRight = [[UIImageView alloc] initWithImage:[AppContext getImageForKey:@"RightCropFlag"]];
    imageViewRight.frame = CGRectMake(kScreenWidth - 12, 12, 12, kScreenWidth / 8.0);
    imageViewRight.userInteractionEnabled = YES;
    
    
//    _topLineView = [[UIImageView alloc]initWithFrame:CGRectMake(_imageViewWith - 3 , 12, ScreenWidth - _imageViewWith *2 + 6, 3)];
//    _topLineView.backgroundColor = [AliyunIConfig config].cutTopLineColor;
//
//    _underLineView = [[UIImageView alloc]initWithFrame:CGRectMake(_imageViewWith - 3, _imageViewLeft.frame.size.height + 12 - 3  , ScreenWidth - _imageViewWith *2 + 6, 3)];
//    _underLineView.backgroundColor = [AliyunIConfig config].cutBottomLineColor;
//
//    [self addSubview:_topLineView];
//    [self addSubview:_underLineView];
    
    [self addSubview:imageViewLeft];
    [self addSubview:imageViewRight];
    
    
//    _imageViewLeftMask = [[UIImageView alloc]initWithFrame:CGRectMake(0, 12, 0, _imageViewLeft.frame.size.height)];
//    _imageViewRightMask = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_imageViewRight.frame), 12, 0, _imageViewLeft.frame.size.height)];
//
//    _imageViewLeftMask.backgroundColor = [AliyunIConfig config].backgroundColor;
//    _imageViewLeftMask.alpha = 0.8;
//    _imageViewRightMask.backgroundColor = [AliyunIConfig config].backgroundColor;
//    _imageViewRightMask.alpha = 0.8;
//
//    [self addSubview:_imageViewLeftMask];
//    [self addSubview:_imageViewRightMask];
    
//    _imageViewBackground = [[UIImageView alloc] initWithImage:[AliyunImage imageNamed:@"paster_time_edit_slider_bg"]];
//    _imageViewBackground.frame = CGRectMake(CGRectGetMaxX(_imageViewLeft.frame), CGRectGetMinY(_imageViewLeft.frame), CGRectGetMinX(_imageViewRight.frame) - CGRectGetMaxX(_imageViewLeft.frame), ScreenWidth / 8.0);
//    [self addSubview:_imageViewBackground];
}

- (void)loadThumbnailData {
    
////    durationLabel.text = [NSString stringWithFormat:@"%.1f",_cutInfo.endTime - _cutInfo.startTime];
//    CMTime startTime = kCMTimeZero;
//    NSMutableArray *array = [NSMutableArray array];
//    CMTime addTime = CMTimeMake(1000,1000);
//  //  CGFloat d = _cutInfo.sourceDuration / 7.0;
//    int intd = d * 100;
//    float fd = intd / 100.0;
//    addTime = CMTimeMakeWithSeconds(fd, 1000);
//    
//   // CMTime endTime = CMTimeMakeWithSeconds(_cutInfo.sourceDuration, 1000);
//    
//    while (CMTIME_COMPARE_INLINE(startTime, <=, endTime)) {
//        [array addObject:[NSValue valueWithCMTime:startTime]];
//        startTime = CMTimeAdd(startTime, addTime);
//    }
//    
//    // 第一帧取第0.1s   规避有些视频并不是从第0s开始的
//    array[0] = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(0.1, 1000)];
//    
    __block int index = 0;
//    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:array completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
//
//        if (result == AVAssetImageGeneratorSucceeded) {
//            UIImage *img = [[UIImage alloc] initWithCGImage:image];
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                [_imagesArray addObject:img];
//                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
//                [_collectionView insertItemsAtIndexPaths:@[indexPath]];
//                index++;
//            });
//        }
//    }];
}


@end
