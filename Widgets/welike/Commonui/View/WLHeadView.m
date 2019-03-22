//
//  WLHeadView.m
//  welike
//
//  Created by 刘斌 on 2018/4/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLHeadView.h"
#import "UIImageView+Extension.h"
#import "WLUser.h"
#import "WLPostBase.h"
#import "WLComment.h"

@interface WLHeadView ()

@property (nonatomic, weak) UITapGestureRecognizer *singleTap;
@property (nonatomic, copy) NSString *imageId;
@property (nonatomic, strong) CALayer *vipLayer;

- (void)onClick;
- (void)prepare;

@end

@implementation WLHeadView

- (id)initWithDefaultImageId:(NSString *)imageId
{
    self = [super initWithImage:[AppContext getImageForKey:imageId]];
    if (self)
    {
        self.imageId = [imageId copy];
        [self prepare];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self prepare];
    }
    return self;
}

- (void)dealloc
{
    [self removeGestureRecognizer:self.singleTap];
}

- (void)setUser:(WLUserBase *)user {
    _user = user;
    
    [self setHeadUrl:user.headUrl];
    
    [self p_setAvatarTagWithVip:user.vip];
}

- (void)setFeedModel:(WLPostBase *)feedModel {
    _feedModel = feedModel;
    
    [self setHeadUrl:feedModel.headUrl];
    
    [self p_setAvatarTagWithVip:feedModel.vip];
}

- (void)setComment:(WLComment *)comment {
    _comment = comment;
    
    [self setHeadUrl:comment.head];
    
    [self p_setAvatarTagWithVip:comment.vip];
}

- (void)setHeadUrl:(NSString *)headUrl
{
    if ([headUrl length] > 0)
    {
        if ([_headUrl isEqualToString:headUrl] == NO)
        {
            if ([headUrl containsString:@"welike"]) {
                headUrl = [self p_thumbUrlWithHeadUrl:headUrl];
            }

            __weak typeof(self) weakSelf = self;
            _headUrl = [headUrl copy];
            [self fq_setImageWithURLString:headUrl placeholder:[AppContext getImageForKey:weakSelf.imageId] cornerRadius:self.frame.size.width / 2.f completed:^(UIImage *image, NSURL *url, NSError *error) {
                if (image != nil)
                {
                    weakSelf.image = image;
                }
                else
                {
                    weakSelf.image = [AppContext getImageForKey:weakSelf.imageId];
                }
            }];
        }
    }
    else
    {
        self.image = [AppContext getImageForKey:self.imageId];
    }
}

- (void)handleVip:(NSInteger)vipValue
{
    [self p_setAvatarTagWithVip:vipValue];
}

- (void)onClick
{
    if ([self.delegate respondsToSelector:@selector(onClick:)])
    {
        [self.delegate onClick:self];
    }
}

- (void)prepare
{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick)];
    [self addGestureRecognizer:singleTap];
    self.singleTap = singleTap;
    self.image = [AppContext getImageForKey:self.imageId];
}

- (void)addBorder {
    CGRect frame = self.bounds;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = frame;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.lineWidth = 2.5;
    shapeLayer.strokeStart = 0.0;
    shapeLayer.strokeEnd = 1.0;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:CGRectGetWidth(frame) * 0.5];
    shapeLayer.path = path.CGPath;
    [self.layer insertSublayer:shapeLayer below:_vipLayer];
}

- (void)addShadow {
    self.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowOffset = CGSizeMake(0, -2);
}

#pragma mark - Private

- (NSString *)p_thumbUrlWithHeadUrl:(NSString *)headUrl {
    NSString *thumbUrl = [LuuUtils getThumbnailPicUrl:headUrl
                                             strategy:kThumbnailStrategyMFit
                                                width:(long)(CGRectGetWidth(self.frame) * [UIScreen mainScreen].scale)
                                               height:(long)(CGRectGetHeight(self.frame) * [UIScreen mainScreen].scale)];
    
    return thumbUrl;
}

- (void)p_setAvatarTagWithVip:(NSInteger)vip {
    [_vipLayer removeFromSuperlayer];
    
//    if (vip == 0) {
//        return;
//    }
//
//    CGFloat width = self.frame.size.width;
//    UIImage *image = nil;
//
//    if (width >= kAvatarSizeLarge) {
//        image = [AppContext getImageForKey:@"user_vip_large"];
//    } else if (width >= kAvatarSizeMedium) {
//        image = [AppContext getImageForKey:@"user_vip_medium"];
//    } else if (width >= kAvatarSizeSmall) {
//        image = [AppContext getImageForKey:@"user_vip_small"];
//    }
    
    CGFloat width = self.frame.size.width;
    UIImage *image = nil;
    CGFloat imageSize = 0;
    
    if (vip < kUserNoneVIP) {
        return;
    } else if (vip >= kUserVIPStarMinimum && vip <= kUserVIPStarMaximum) {
        image = [AppContext getImageForKey:@"user_vip_star"];
    } else {
        image = [AppContext getImageForKey:@"user_vip_influencer"];
    }
    
    if (!image) {
        return;
    }
    
    if (width >= kAvatarSizeLarge) {
        imageSize = 22;
    } else if (width >= kAvatarSizeMedium) {
        imageSize = 16;
    } else if (width >= kAvatarSizeSmall) {
        imageSize = 12;
    } else if (width < kAvatarSizeMin) {
        return;
    }
    
    _vipLayer = [CALayer layer];
    _vipLayer.frame = CGRectMake(0, 0, imageSize, imageSize);
    _vipLayer.position = CGPointMake(width - imageSize * 0.5, CGRectGetHeight(self.bounds) - imageSize * 0.5);
    _vipLayer.contents = (__bridge id)image.CGImage;
    _vipLayer.contentsGravity = kCAGravityResizeAspect;
    [self.layer addSublayer:_vipLayer];
}

@end
