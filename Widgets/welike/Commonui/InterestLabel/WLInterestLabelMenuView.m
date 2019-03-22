//
//  WLInterestLabelMenuView.m
//  welike
//
//  Created by luxing on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestLabelMenuView.h"
#import "UIView+WebCache.h"

@implementation WLInterestLabelMenuView

- (UIColor *)titleTextColor
{
    return [UIColor whiteColor];
}

- (void)labelViewTapped:(UITapGestureRecognizer *)recognizer
{
    if (self.labelModel.folded) {
        self.labelModel.folded = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickInterestLabel:)]) {
            [self.delegate didClickInterestLabel:self];
        }
    } else {
        [self clickSelectImageView];
    }
}

- (void)bindModel:(WLInterestLabelModel *)model
{
    [super bindModel:model];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 4.0;
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowOffset = CGSizeMake(0, 2);
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.labelModel.title attributes:@{NSShadowAttributeName: shadow}];
    [self sd_internalSetImageWithURL:[NSURL URLWithString:self.labelModel.imageUrl] placeholderImage:nil options:0 operationKey:nil setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData) {
        UIImage *img = [UIImage imageWithCGImage:image.CGImage scale:image.size.height/CGRectGetHeight(self.frame)*image.scale orientation:image.imageOrientation];
        self.image = [self image:img stretchWithSize:self.frame.size];
    } progress:nil completed:nil];
}

- (UIImage *)image:(UIImage *)image stretchWithSize:(CGSize)imageViewSize
{
    CGSize bgSize = CGSizeMake(floorf(imageViewSize.width), floorf(imageViewSize.height));
    UIImage *img = [image stretchableImageWithLeftCapWidth:1 topCapHeight:imageViewSize.height/2];
    CGFloat tempWidth = (bgSize.width)/2 + (image.size.width)/2;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tempWidth, bgSize.height), NO, [UIScreen mainScreen].scale);
    [img drawInRect:CGRectMake(0, 0, tempWidth, bgSize.height)];
    UIImage *firstStrechImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *secondStrechImage = [firstStrechImage stretchableImageWithLeftCapWidth:firstStrechImage.size.width-1 topCapHeight:firstStrechImage.size.height/2];
    CGRect frame = CGRectMake(0, 0, imageViewSize.width, imageViewSize.height);
    UIGraphicsBeginImageContextWithOptions(imageViewSize, NO, [UIScreen mainScreen].scale);
    [[UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:kInterestLabelCorners] addClip];
    [secondStrechImage drawInRect:frame];
    UIImage *fImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fImage;
}

@end
