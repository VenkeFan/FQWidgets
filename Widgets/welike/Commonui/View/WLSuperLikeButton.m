//
//  WLSuperLikeButton.m
//  welike
//
//  Created by luxing on 2018/6/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSuperLikeButton.h"
#import <AudioToolbox/AudioToolbox.h>
#import "WLTrackerLogin.h"

#define kSuperLikeLevel3                        30
#define kSuperLikeLevel5                        50
#define kSuperLikeLevel10                       100
#define kSuperLikeSystemSoundId                      1519

#define kSuperLikeWordTopPading                      32.0
#define kSuperLikeWordLeftPading                     15.0
#define kSuperLikeSmallWordScale                     0.7
#define kSuperLikeButtonWidth                        200
#define kSuperLikeButtonHeight                       52
#define kSuperLikeButtonLeftPadding                  -50
#define kSuperLikeButtonTopPadding                   -80
#define kSuperLikeButtonTitleFontSize                13.0
#define kSuperLikeButtonTitleColor                   kUIColorFromRGB(0xFF6A49)

@interface WLSuperLikeButton ()

@property (strong, nonatomic) CAEmitterLayer *streamerLayer;

@property (nonatomic, strong) NSMutableArray *imagesArr;

@property (nonatomic, strong) NSMutableArray *CAEmitterCellArr;

@property (nonatomic, strong) UILabel *zanLabel;

@property (nonatomic, assign) NSUInteger clickCount;

@end

@implementation WLSuperLikeButton
{
    NSTimer *_timer;
    NSTimer *_soundTimer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.expCount = 1;
    self.zanLabel = [[UILabel alloc]init];
    self.zanLabel.frame = CGRectMake(kSuperLikeButtonLeftPadding ,kSuperLikeButtonTopPadding, kSuperLikeButtonWidth, kSuperLikeButtonHeight);
    self.zanLabel.hidden = YES;
    
    [self setTitleColor:kSuperLikeButtonTitleColor forState:UIControlStateNormal];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    self.titleLabel.font =  [UIFont systemFontOfSize:kSuperLikeButtonTitleFontSize];

    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pressOnece:)]];
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)]];
}

- (void)pressOnece:(UIGestureRecognizer *)ges
{
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Like];
    kNeedLogin
    
    [self heartbeatAnimation];
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [self changClickedTextInView:window];
    for (NSInteger i = 1; i <= 6; i++) {
        [self clickWindHeatAtIndex:i inView:window];
    }
    self.clickCount++;
    [self performSelector:@selector(clickExplode) withObject:nil afterDelay:1];
}

- (void)clickExplode
{
    self.clickCount--;
    if (self.clickCount == 0) {
        _zanLabel.hidden = YES;
        _zanLabel.attributedText = nil;
        [self.zanLabel removeFromSuperview];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(superLikeButton:expCount:)]) {
        [self.delegate superLikeButton:self expCount:self.expCount];
    }
}

- (void)clickWindHeatAtIndex:(NSInteger)index inView:(UIView *)inView
{
    CGPoint point = [self convertPoint:self.imageView.center toView:inView];
    [CATransaction begin];
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGPoint start = point;
    CGFloat offsetX = arc4random()%40;
    CGFloat offsetY = arc4random()%50;
    if (index%2) {
        offsetX*=-1;
    }
    NSValue *value1 =  [NSValue valueWithCGPoint:start];
    NSValue *value2 =  [NSValue valueWithCGPoint:CGPointMake(start.x+offsetX*0.8, start.y-20-offsetY)];
    NSValue *value3 =  [NSValue valueWithCGPoint:CGPointMake(start.x+offsetX, start.y-30-offsetY)];
    NSValue *value4 =  [NSValue valueWithCGPoint:CGPointMake(start.x+offsetX*1.1, start.y-40-offsetY)];
    NSValue *value5 =  [NSValue valueWithCGPoint:CGPointMake(start.x+offsetX*1.2, start.y-50-offsetY)];
    NSValue *value6 =  [NSValue valueWithCGPoint:CGPointMake(start.x+offsetX, start.y-30-offsetY)];
    positionAnimation.values = @[value1,value2,value3,value4,value5,value6,value1];
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    positionAnimation.duration = 1;
    
    CAKeyframeAnimation *animationScale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animationScale.values = @[@(0.0),@(0.8),@(1.0),@(0.0)];
    animationScale.duration = 1;
    animationScale.calculationMode = kCAAnimationCubic;
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[@(0.0),@(1.0),@(0.0)];
    opacityAnimation.duration = 1;
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[positionAnimation,animationScale,opacityAnimation];
    groupAnimation.duration = 1;
    groupAnimation.fillMode = kCAFillModeForwards;
    
    CALayer *layer = [CALayer layer];
    __weak typeof(layer) weakLayer = layer;
    [CATransaction setCompletionBlock:^{
        [weakLayer removeFromSuperlayer];
    }];
    layer.bounds = self.imageView.layer.bounds;
    layer.position = point;
    UIImage *image = [AppContext getImageForKey:[@"click_heart_" stringByAppendingFormat:@"%ld",(long)index]];
    CGImageRef image2 = image.CGImage;
    layer.contents= (__bridge id _Nullable)(image2);
    [layer addAnimation:groupAnimation forKey:nil];
    [inView.layer addSublayer:layer];
    [CATransaction commit];
}

- (void)longPress:(UIGestureRecognizer *)ges
{
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Like];
    kNeedLogin
    
    UIButton * sender = (UIButton *)ges.view;
    sender.selected = YES;
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self animation];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
            [self explode:sender];
        }
            break;
        default:
            break;
    }
}

- (void)heartbeatAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@1.5 ,@0.8, @1.0,@1.2,@1.0];
    animation.duration = 0.5;
    animation.calculationMode = kCAAnimationCubic;
    [self.imageView.layer addAnimation:animation forKey:@"transform.scale"];
}

- (void)animation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    if (self.selected) {
        animation.values = @[@1.5 ,@0.8, @1.0,@1.2,@1.0];
        animation.duration = 0.5;
        [self startAnimate];
    }else
    {
        animation.values = @[@0.8, @1.0];
        animation.duration = 0.4;
    }
    animation.calculationMode = kCAAnimationCubic;
    [self.imageView.layer addAnimation:animation forKey:@"transform.scale"];
}

- (void)startAnimate {
    [self.imagesArr removeAllObjects];
    [self.CAEmitterCellArr removeAllObjects];
    for (int i = 0; i < 9; i++)
    {
        NSString * imageStr = [NSString stringWithFormat:@"wind_heart_%d",i+1];
        [self.imagesArr addObject:imageStr];
    }

    for (NSInteger i = 0;i < self.imagesArr.count;i++) {
        CAEmitterCell * cell = [self emitterCellAtIndex:i];
        [self.CAEmitterCellArr addObject:cell];
    }
    self.streamerLayer               = [CAEmitterLayer layer];
    self.streamerLayer.emitterSize   = CGSizeMake(30, 30);
    self.streamerLayer.masksToBounds = NO;
    self.streamerLayer.renderMode = kCAEmitterLayerAdditive;
    self.streamerLayer.emitterCells  = self.CAEmitterCellArr;
    self.clickCount++;
    self.zanLabel.hidden = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeLongPressedText) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    _soundTimer = [NSTimer scheduledTimerWithTimeInterval:0.067 target:self selector:@selector(changeLongPressedSound) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_soundTimer forMode:NSRunLoopCommonModes];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@0.8, @1.0];
    animation.duration = 0.4;
    [self.zanLabel.layer addAnimation:animation forKey:@"transform.scale"];
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    CGPoint position = [self convertPoint:self.imageView.center toView:window];
    CGFloat maxX = CGRectGetMaxX(window.frame);
    CGFloat padingX = 0;
    if (maxX-position.x < 30) {
        padingX = -30;
    }
    self.zanLabel.center = CGPointMake(position.x+padingX, position.y+kSuperLikeButtonTopPadding);
    if (self.zanLabel.superview != nil) {
        [self.zanLabel removeFromSuperview];
    }
    [window addSubview:self.zanLabel];
    self.streamerLayer.position = position;
    if (self.streamerLayer.superlayer != nil) {
        [self.streamerLayer removeFromSuperlayer];
    }
    [window.layer addSublayer:self.streamerLayer];
//    self.streamerLayer.beginTime = CACurrentMediaTime();
    for (NSString * imgStr in self.imagesArr) {
        NSString * keyPathStr = [NSString stringWithFormat:@"emitterCells.%@.birthRate",imgStr];
        [self.streamerLayer setValue:@4 forKeyPath:keyPathStr];
    }
}

- (void)explode:(UIButton *)button{
    for (NSString * imgStr in self.imagesArr) {
        NSString * keyPathStr = [NSString stringWithFormat:@"emitterCells.%@.birthRate",imgStr];
        [self.streamerLayer setValue:@0 forKeyPath:keyPathStr];
    }
    self.clickCount--;
    _zanLabel.hidden = YES;
    _zanLabel.attributedText = nil;
    [self.streamerLayer removeFromSuperlayer];
    [self.zanLabel removeFromSuperview];
    [_timer invalidate];
    _timer = nil;
    [_soundTimer invalidate];
    _soundTimer = nil;
    AudioServicesRemoveSystemSoundCompletion(kSuperLikeSystemSoundId);
    if (self.delegate && [self.delegate respondsToSelector:@selector(superLikeButton:expCount:)]) {
        [self.delegate superLikeButton:self expCount:self.expCount];
    }
}

- (void)changeLongPressedSound
{
    AudioServicesPlaySystemSound(kSuperLikeSystemSoundId);
}

- (void)changeLongPressedText
{
    if (_timer == nil) {
        return;
    }
    self.expCount ++;
    self.zanLabel.attributedText = [self getLongPressedAttributedString:self.expCount];
    self.zanLabel.textAlignment = NSTextAlignmentCenter;
    if (self.expCount == kSuperLikeLevel3) {
        [self zanLabelScale];
    } else if (self.expCount == kSuperLikeLevel5) {
        [self zanLabelScale];
    } else if (self.expCount == kSuperLikeLevel10) {
        [self zanLabelScale];
    }
    
    AudioServicesPlaySystemSound(kSuperLikeSystemSoundId);
    if(self.expCount%5 == 0) {
        [self heartbeatAnimation];
    }
    [self changeLikeImageWithExp:self.expCount];
}

- (void)zanLabelScale
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@1.5, @1.0];
    animation.duration = 0.4;
    [self.zanLabel.layer addAnimation:animation forKey:@"transform.scale"];
}

- (void)changClickedTextInView:(UIView *)inView
{
    CGPoint point = [self convertPoint:self.imageView.center toView:inView];
    CGFloat maxX = CGRectGetMaxX(inView.frame);
    CGFloat padingX = 0;
    if (maxX-point.x < 30) {
        padingX = -10;
    }
    
    self.expCount ++;
    self.zanLabel.hidden = NO;
    [CATransaction begin];
    CGPoint startPoint = CGPointMake(point.x+padingX, point.y-30);
    NSValue *value0 = [NSValue valueWithCGPoint:startPoint];
    NSValue *value1 = [NSValue valueWithCGPoint:CGPointMake(startPoint.x, startPoint.y-10)];
    NSValue *value2 = [NSValue valueWithCGPoint:CGPointMake(startPoint.x, startPoint.y-50)];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.values = @[value0,value1, value2,value0];
    animation.duration = 1.0 ;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[@(0.0),@(1.0),@(1.0),@(0.0)];
    opacityAnimation.duration = 1.0;
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[animation,opacityAnimation];
    groupAnimation.duration = 1.0;
    groupAnimation.fillMode = kCAFillModeForwards;
    
    self.zanLabel.attributedText = [self getClickedAttributedString:self.expCount];
    self.zanLabel.textAlignment = NSTextAlignmentCenter;
    [self.zanLabel.layer addAnimation:groupAnimation forKey:@"position"];
    if (self.zanLabel.superview == nil) {
        [inView addSubview:self.zanLabel];
    }
    [CATransaction commit];
    
    [self changeLikeImageWithExp:self.expCount];
}

- (void)changeLikeImageWithExp:(NSUInteger)count
{
    UIImage *image = nil;
    if (self.isDetail) {
//        image = [UIImage imageWithCGImage:image.CGImage scale:image.scale*0.7 orientation:image.imageOrientation];
        image = [WLSingleContentManager superLikeImageWithExp:count imgType:WLSuperLikeType_FeedDetail];
    } else {
        image = [WLSingleContentManager superLikeImageWithExp:count];
    }
    [self setImage:image forState:UIControlStateNormal];
}

- (NSMutableAttributedString *)getLongPressedAttributedString:(NSUInteger)num
{
    NSInteger ge = num % 10;
    NSInteger shi = num % 100 / 10;
    NSMutableAttributedString * mutStr = [[NSMutableAttributedString alloc]init];
    CGFloat padingX = 0;
    if (num < kSuperLikeLevel3) {
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        attch.image = [AppContext getImageForKey:@"multi_digg_word_level_1"];
        attch.bounds = CGRectMake(0, 0, attch.image.size.width, attch.image.size.height);
        NSAttributedString *z_string = [NSAttributedString attributedStringWithAttachment:attch];
        [mutStr appendAttributedString:z_string];
        padingX = attch.image.size.width-kSuperLikeWordLeftPading;
    } else if (num < kSuperLikeLevel5) {
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        attch.image = [AppContext getImageForKey:@"multi_digg_word_level_3"];
        attch.bounds = CGRectMake(0, 0, attch.image.size.width, attch.image.size.height);
        NSAttributedString *z_string = [NSAttributedString attributedStringWithAttachment:attch];
        [mutStr appendAttributedString:z_string];
        padingX = attch.image.size.width-kSuperLikeWordLeftPading;
    } else if (num < kSuperLikeLevel10) {
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        attch.image = [AppContext getImageForKey:@"multi_digg_word_level_5"];
        attch.bounds = CGRectMake(0, 0, attch.image.size.width, attch.image.size.height);
        NSAttributedString *z_string = [NSAttributedString attributedStringWithAttachment:attch];
        [mutStr appendAttributedString:z_string];
        padingX = attch.image.size.width-kSuperLikeWordLeftPading;
    } else {
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        attch.image = [AppContext getImageForKey:@"multi_digg_word_level_10"];
        attch.bounds = CGRectMake(0, 0, attch.image.size.width, attch.image.size.height);
        NSAttributedString *z_string = [NSAttributedString attributedStringWithAttachment:attch];
        [mutStr appendAttributedString:z_string];
    }
    
    if (num < kSuperLikeLevel10) {
        if (shi != 0) {
            NSTextAttachment *s_attch = [[NSTextAttachment alloc] init];
            s_attch.image = [AppContext getImageForKey:[NSString stringWithFormat:@"multi_digg_num_%ld",(long)shi ]];
            s_attch.bounds = CGRectMake(-1*padingX, kSuperLikeWordTopPading, s_attch.image.size.width, s_attch.image.size.height);
            NSAttributedString *s_string = [NSAttributedString attributedStringWithAttachment:s_attch];
            [mutStr appendAttributedString:s_string];
        }
        if (ge >= 0) {
            CGFloat scale = 1;
            if (shi != 0) {
                scale = kSuperLikeSmallWordScale;
            }
            NSTextAttachment *g_attch = [[NSTextAttachment alloc] init];
            g_attch.image = [AppContext getImageForKey:[NSString stringWithFormat:@"multi_digg_num_%ld",(long)ge]];
            g_attch.bounds = CGRectMake(-1*padingX, kSuperLikeWordTopPading, g_attch.image.size.width*scale, g_attch.image.size.height*scale);
            NSAttributedString *g_string = [NSAttributedString attributedStringWithAttachment:g_attch];
            [mutStr appendAttributedString:g_string];
        }
    } else {
        NSTextAttachment *g_attch = [[NSTextAttachment alloc] init];
        g_attch.bounds = CGRectMake(0, 0, 50, 40);
        NSAttributedString *g_string = [NSAttributedString attributedStringWithAttachment:g_attch];
        [mutStr appendAttributedString:g_string];
    }
    return mutStr;
}

- (NSMutableAttributedString *)getClickedAttributedString:(NSUInteger)num
{
    NSInteger ge = num % 10;
    NSInteger shi = num % 100 / 10;
    NSMutableAttributedString * mutStr = [[NSMutableAttributedString alloc]init];

    if (num < kSuperLikeLevel10) {
        if (shi != 0) {
            NSTextAttachment *s_attch = [[NSTextAttachment alloc] init];
            s_attch.image = [AppContext getImageForKey:[NSString stringWithFormat:@"multi_digg_num_%ld",(long)shi]];
            s_attch.bounds = CGRectMake(0, 0, s_attch.image.size.width, s_attch.image.size.height);
            NSAttributedString *s_string = [NSAttributedString attributedStringWithAttachment:s_attch];
            [mutStr appendAttributedString:s_string];
        }
        if (ge >= 0) {
            CGFloat scale = 1;
            if (shi != 0) {
                scale = kSuperLikeSmallWordScale;
            }
            NSTextAttachment *g_attch = [[NSTextAttachment alloc] init];
            g_attch.image = [AppContext getImageForKey:[NSString stringWithFormat:@"multi_digg_num_%ld",(long)ge]];
            g_attch.bounds = CGRectMake(0, 0, g_attch.image.size.width*scale, g_attch.image.size.height*scale);
            NSAttributedString *g_string = [NSAttributedString attributedStringWithAttachment:g_attch];
            [mutStr appendAttributedString:g_string];
        }
    } else {
        NSTextAttachment *g_attch = [[NSTextAttachment alloc] init];
        g_attch.image = [AppContext getImageForKey:@"multi_digg_num_10"];
        g_attch.bounds = CGRectMake(0, 0, g_attch.image.size.width, g_attch.image.size.height);
        NSAttributedString *g_string = [NSAttributedString attributedStringWithAttachment:g_attch];
        [mutStr appendAttributedString:g_string];
    }
    return mutStr;
}

- (CAEmitterCell *)emitterCellAtIndex:(NSInteger)index
{
    NSString *imageStr = [self.imagesArr objectAtIndex:index];
    UIImage *image = [AppContext getImageForKey:imageStr];

    CAEmitterCell * smoke = [CAEmitterCell emitterCell];
    smoke.birthRate = 0;
    smoke.lifetime = 2;
    smoke.lifetimeRange = 2;
    smoke.scale = 0.35;

    smoke.alphaRange = 1;
    smoke.alphaSpeed = -1.0;
    smoke.yAcceleration = 450;

    CGImageRef image2 = image.CGImage;
    smoke.contents= (__bridge id _Nullable)(image2);
    smoke.name = imageStr;

    smoke.velocity = 450;
    smoke.velocityRange = 30;
    smoke.emissionLongitude = -1*(index%5+1) * M_PI_4 ;
    smoke.emissionRange = M_PI_4;
    return smoke;
}

- (NSMutableArray *)imagesArr
{
    if (_imagesArr == nil) {
        _imagesArr = [NSMutableArray array];
    }
    return _imagesArr;
}

- (NSMutableArray *)CAEmitterCellArr
{
    if (_CAEmitterCellArr == nil) {
        _CAEmitterCellArr = [NSMutableArray array];
    }
    return _CAEmitterCellArr;
}

@end
