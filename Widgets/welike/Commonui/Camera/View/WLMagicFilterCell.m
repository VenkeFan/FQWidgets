//
//  WLMagicFilterCell.m
//  welike
//
//  Created by fan qi on 2018/11/30.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLMagicFilterCell.h"
#import "WLMagicBasicModel.h"

@implementation WLMagicFilterCell {
    UIImageView *_imgView;
    UILabel *_txtLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetWidth(frame))];
        [self addSubview:_imgView];
        
        {
            _downloadLayer = [CALayer layer];
            UIImage *img = [AppContext getImageForKey:@"camera_effect_download"];
            _downloadLayer.frame = CGRectMake(0, 0, img.size.width, img.size.height);
            _downloadLayer.position = CGPointMake(CGRectGetWidth(_imgView.frame) - CGRectGetWidth(_downloadLayer.frame) * 0.5, CGRectGetHeight(_imgView.frame) - CGRectGetHeight(_downloadLayer.frame) * 0.5);
            _downloadLayer.contents = (__bridge id)img.CGImage;
            _downloadLayer.hidden = YES;
            [self.layer addSublayer:_downloadLayer];
        }
        
        {
            _progressLayer = [CAShapeLayer layer];
            _progressLayer.frame = _imgView.bounds;
            _progressLayer.cornerRadius = 4.0;
            _progressLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3].CGColor;
            
            CGFloat padding = (CGRectGetWidth(_progressLayer.bounds) - 22) * 0.5; // 28.0;
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, padding, padding)
                                                            cornerRadius:(CGRectGetHeight(_progressLayer.frame) * 0.5 - padding)];
            
            _progressLayer.path = path.CGPath;
            _progressLayer.fillColor = [UIColor clearColor].CGColor;
            _progressLayer.strokeColor = kMainColor.CGColor;
            _progressLayer.lineWidth = 3;
            _progressLayer.lineCap = kCALineCapRound;
            _progressLayer.strokeStart = 0.0;
            _progressLayer.strokeEnd = 0.0;
            _progressLayer.hidden = YES;
            [self.layer addSublayer:_progressLayer];
        }
        
        _txtLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_imgView.frame), CGRectGetWidth(frame), CGRectGetHeight(frame) - CGRectGetMaxY(_imgView.frame))];
        _txtLabel.font = kRegularFont(12.0);
        _txtLabel.textColor = [UIColor whiteColor];
        _txtLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_txtLabel];
    }
    return self;
}

- (void)setCellModel:(WLMagicBasicModel *)cellModel {
    _cellModel = cellModel;
    
    if (cellModel.resourceUrl.length == 0) {
        _imgView.contentMode = UIViewContentModeCenter;
    } else {
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    if (cellModel.iconUrl) {
        CGSize fixedSize = _imgView.size;
        [_imgView fq_setImageWithURLString:cellModel.iconUrl
                                 completed:^(UIImage *image, NSURL *url, NSError *error) {
                                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                         UIImage *icon = nil;
                                         if (image.size.width > fixedSize.width || image.size.height > fixedSize.height) {
                                             icon = [image resizeWithSize:fixedSize];
                                         } else {
                                             icon = image;
                                         }
                                         
                                         if (cellModel.type == WLMagicBasicModelType_Filter) {
                                             icon = [icon imageByRoundCornerRadius:4.0];
                                         }
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             self->_imgView.image = icon;
                                             self->_imgView.backgroundColor = [UIColor clearColor];
                                         });
                                     });
                                 }];
    } else {
        _imgView.image = nil;
        _imgView.backgroundColor = kLightLightFontColor;
        _imgView.layer.cornerRadius = 4.0;
    }
    
    if (cellModel.type == WLMagicBasicModelType_Filter) {
        _txtLabel.hidden = NO;
        _txtLabel.text = cellModel.name;
    } else if (cellModel.type == WLMagicBasicModelType_Paster) {
        _txtLabel.hidden = YES;
        _txtLabel.text = nil;
    }
    
    
    if (cellModel.isSelected) {
        _imgView.layer.borderColor = kMainColor.CGColor;
        _imgView.layer.borderWidth = 2.0;
        _imgView.layer.cornerRadius = 4.0;
        
        _txtLabel.textColor = kMainColor;
    } else {
        _imgView.layer.borderWidth = 0.0;
        
        _txtLabel.textColor = [UIColor whiteColor];
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (cellModel.resourceUrl.length == 0) {
        _downloadLayer.hidden = YES;
        _progressLayer.hidden = YES;
    } else if (cellModel.isDownloading) {
        _downloadLayer.hidden = YES;
        _progressLayer.hidden = NO;
        _progressLayer.strokeEnd = cellModel.downloadProgress;
    } else if (cellModel.isDownloaded) {
        _downloadLayer.hidden = YES;
        _progressLayer.hidden = YES;
    } else {
        _downloadLayer.hidden = NO;
        _progressLayer.hidden = YES;
    }
    [CATransaction commit];
}

//- (void)setSelected:(BOOL)selected {
//    [super setSelected:selected];
//    
//    if (selected) {
//        _imgView.layer.borderColor = kMainColor.CGColor;
//        _imgView.layer.borderWidth = 2.0;
//        _imgView.layer.cornerRadius = 4.0;
//
//        _txtLabel.textColor = kMainColor;
//    } else {
//        _imgView.layer.borderWidth = 0.0;
//
//        _txtLabel.textColor = [UIColor whiteColor];
//    }
//}

@end
