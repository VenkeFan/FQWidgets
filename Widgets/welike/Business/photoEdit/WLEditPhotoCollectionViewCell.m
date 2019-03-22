//
//  EditPhotoCollectionViewCell.m
//  CuctvWeibo
//
//  Created by cuctv-gyb on 17/2/23.
//
//

#import "WLEditPhotoCollectionViewCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "WLImageHelper.h"
#import "WLAssetsManager.h"


@interface WLEditPhotoCollectionViewCell ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIImage *realImage;
@property (strong, nonatomic) UIImage *showImage;

@property (assign, nonatomic) CGRect cutFrame;


@end

@implementation WLEditPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = RGBCOLOR(227, 227, 227);
        
        self.scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        [self addSubview:self.scrollView];
        self.scrollView.maximumZoomScale = 1;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.delegate = self;
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.bounds];
//        imageView.backgroundColor = [UIColor redColor];
        [self.scrollView addSubview:imageView];
        self.imageView = imageView;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return self;
}

- (void)prepareForReuse{
    self.scrollView.zoomScale = 1;
    
}

#pragma mark - ScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.imageView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize boundsSize = scrollView.bounds.size;
    CGRect imgFrame = self.imageView.frame;
    CGSize contentSize = scrollView.contentSize;
    CGPoint centerPoint = CGPointMake(contentSize.width/2, contentSize.height/2);
    // center horizontally
    if (imgFrame.size.width <= boundsSize.width)
    {
        centerPoint.x = boundsSize.width/2;
    }
    // center vertically
    if (imgFrame.size.height <= boundsSize.height)
    {
        centerPoint.y = boundsSize.height/2;
    }
    self.imageView.center = centerPoint;
    
}

#pragma mark - 照片剪裁
- (void)cropImage {
//    记录剪切位置
    [self setSignalImage:[self reduceImage:self.realImage]];
}


-(UIImage *)reduceImage:(UIImage *)image
{
    self.cutFrame = CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.width, self.height);

    CGFloat width= _imageView.frame.size.width;
    CGFloat rationScale = (width /image.size.width);
    
    CGFloat origX = (self.cutFrame.origin.x - _imageView.frame.origin.x) / rationScale;
    CGFloat origY = (self.cutFrame.origin.y - _imageView.frame.origin.y) / rationScale;
    CGFloat oriWidth = self.cutFrame.size.width / rationScale;
    CGFloat oriHeight = self.cutFrame.size.height / rationScale;
    CGRect myRect = CGRectMake(origX, origY, oriWidth, oriHeight);
//    CGRect myRect = CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.width, self.height);
    
    CGImageRef  imageRef = CGImageCreateWithImageInRect(image.CGImage, myRect);
    UIGraphicsBeginImageContext(myRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myRect, imageRef);
    UIImage * clipImage = [UIImage imageWithCGImage:imageRef];
    UIGraphicsEndImageContext();
    
    return clipImage;
}

#pragma mark - 照片旋转
- (void)photoRotate {
     [self setSignalImage:[self.realImage imageByRotateRight90]];
}

#pragma mark - 剪裁位置调整
- (void)adjustCutPhotoState {
    self.scrollView.maximumZoomScale = 3;

//    [UIView animateWithDuration:0.2 animations:^{
    
        CGFloat imageScale = self.realImage.size.width / self.realImage.size.height;
        
        if (self.realImage.size.height > self.realImage.size.width) {
            self.imageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth / imageScale);
            
        }else{
            self.imageView.frame = CGRectMake(0, 0, kScreenWidth * imageScale, kScreenWidth);
            
        }
        
        self.scrollView.contentSize = self.imageView.size;
//    }];
}

- (void)adjustOriginPhotoState {
    
//    self.imageView.image = [UIImage imageWithContentsOfFile:self.picType.smallPicPathCopy];
    
    self.scrollView.maximumZoomScale = 1;
    [UIView animateWithDuration:0.2 animations:^{
        
        self.imageView.frame = self.bounds;
        
        self.scrollView.contentSize = self.imageView.size;
    }];
}


-(void)setAssetModel:(WLAssetModel *)assetModel
{
    _assetModel = assetModel;
    
    if (!_assetModel.asset)
    {
        return;
    }
    
    //拿到图片
    [WLImageHelper imageFromAsset:_assetModel.asset size:PHImageManagerMaximumSize result:^(UIImage *thumbImage) {
       
        self.imageView.image = thumbImage;
        self.realImage = thumbImage;
        self.showImage = thumbImage;
        
        [self adjustCutPhotoState];
        
       // [self adjustOriginPhotoState];
        
      //  self.imageView.frame = CGRectMake(0, 0, kScreenWidth, (thumbImage.size.height * kScreenWidth)/thumbImage.size.width);
        
      //  self.scrollView.contentSize = CGSizeMake(kScreenWidth, self.imageView.height);
        
    }];
    
//    [self adjustOriginPhotoState];
}


-(void)setSignalImage:(UIImage *)signalImage
{
    _signalImage = signalImage;
    
    self.assetModel = [WLAssetModel modelWithImage:signalImage];
    
    self.imageView.image = signalImage;

    self.realImage =  signalImage;

    self.showImage =  signalImage;

      [self adjustCutPhotoState];
    
//    [self adjustOriginPhotoState];
}

-(void)saveAndFinish:(saveFinish)finishBlock
{
  //  [self setSignalImage:[self reduceImage:self.realImage]];
    
    UIImage *finalCropImage = [self reduceImage:self.realImage];
    

    [WLAssetsManager saveImageToCustomAblum:finalCropImage finished:^(PHAsset *asset) {
        
        self->_assetModel.asset = asset;
        
        //主线程中做
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (finishBlock)
            {
                finishBlock(self->_assetModel);
            }
            
        });
        
    }];
    
//    [WLAssetsManager saveImageToCameraRoll:finalCropImage
//                                  finished:^(PHAsset *asset) {
//                                      self->_assetModel.asset = asset;
//
//                                      //主线程中做
//                                      dispatch_async(dispatch_get_main_queue(), ^{
//
//                                          if (finishBlock)
//                                          {
//                                              finishBlock(self->_assetModel);
//                                          }
//
//                                      });
//                                  }];
}


@end
