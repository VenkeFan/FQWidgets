//
//  ZQFilterController.m
//  ZQPhotoEdit
//
//  Created by 肖兆强 on 2017/6/10.
//  Copyright © 2017年 jwzt. All rights reserved.
//

#import "ZQFilterController.h"
#import "EditOperatingToolBar.h"
#import "ImageFilterToolBar.h"
#import <CoreImage/CIFilter.h>

@interface ZQFilterController ()

{
    UIImageView *_imageView;
    ImageBlock _block;
    NSArray *_filterNames;
}

@end

@implementation ZQFilterController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildLayout];
    
     _filterNames = [CIFilter filterNamesInCategory:@"CICategoryBuiltIn"];   
}

-(void)buildLayout
{
//    __weak typeof(self) weakSelf = self;
    self.view.backgroundColor = [UIColor blackColor];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - operaBarHeight - FilterToolBarHeight)];
    _imageView.image = self.image;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    EditOperatingToolBar *bar = [[EditOperatingToolBar alloc] initWithFrame:CGRectMake(0, self.view.height - operaBarHeight, self.view.width, operaBarHeight)];
    [self.view addSubview:bar];
    [bar addTapBlock:^(NSInteger index) {
        switch (index) {
            case 0:
                NSLog(@"取消");
                [self dismissViewControllerAnimated:true completion:nil];
                break;
            case 1:
                NSLog(@"撤销");
                self->_imageView.image = self->_image;
                break;
            case 2:
                NSLog(@"保存");
                if (self->_block) {
                    self->_block(self->_imageView.image);
                }
                [self dismissViewControllerAnimated:true completion:nil];
                break;
                
            default:
                break;
        }
    }];
    
    ImageFilterToolBar *FilterView = [[ImageFilterToolBar alloc] initWithFrame:CGRectMake(0, self.view.height - FilterToolBarHeight - operaBarHeight, self.view.width, FilterToolBarHeight)];
    __weak __typeof(self)weekSelf = self;
    [FilterView addRotateChangeBlock:^(NSString *FilterName) {
        [weekSelf changeImageFilter:FilterName];
    }];
    [self.view addSubview:FilterView];
}

-(void)changeImageFilter:(NSString *)FilterName
{
    
            _imageView.image = [self getNewImageFromFilterWithFilterName:FilterName originImage:_image];

    
}

-(void)addFinishBlock:(ImageBlock)block
{
    _block = block;
}


- (UIImage *)getNewImageFromFilterWithFilterName:(NSString *)filterName
                                     originImage:(UIImage *)originImage
{
    CIImage *ciImage =[[CIImage alloc]initWithImage:originImage];
    
    //CIFilter 滤镜
    CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues:kCIInputImageKey,ciImage,nil];
    
    [filter setDefaults];
    
    CIContext *context =[CIContext contextWithOptions:nil];
    
    CIImage *outputImage =[filter outputImage];
    
    CGImageRef cgImage =[context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *image =[UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return image;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
