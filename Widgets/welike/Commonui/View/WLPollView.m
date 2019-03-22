//
//  WLPollView.m
//  welike
//
//  Created by fan qi on 2018/10/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPollView.h"
#import "WLPollPost.h"
#import "WLFeedLayout.h"
#import "UIImageView+Extension.h"
#import "WLSingleContentManager.h"
#import "WLTrackerLogin.h"

#define kAnimationInterval              0.2
#define kTouchBeganAnimationKey         @"touchBeganAnimationKey"
#define kTouchEndAnimationKey           @"touchEndAnimationKey"

#define kProgressSelectedTintColor      kUIColorFromRGB(0x2B98EE)
#define kProgressNormalTintColor        kUIColorFromRGB(0xE6EBF0)

@class WLVoteContentView;

@protocol WLVoteContentViewDelegate <NSObject>

- (void)voteContentViewTouchesEnded:(WLVoteContentView *)contentView;

@end

@interface WLVoteContentView : UIView

@property (nonatomic, assign) BOOL needRespond;

@property (nonatomic, strong) CABasicAnimation *beginAnimation;
@property (nonatomic, strong) CABasicAnimation *endAnimation;

@property (nonatomic, weak) id<WLVoteContentViewDelegate> delegate;

- (void)addMaskLayer;

@end

@implementation WLVoteContentView {
    CFTimeInterval _beginTime;
    CFTimeInterval _endTime;
    
    CALayer *_maskLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)layoutSubviews {
    _maskLayer.frame = self.bounds;
}

#pragma mark - Public

- (void)addMaskLayer {
    if (_maskLayer) {
        [_maskLayer removeFromSuperlayer];
        _maskLayer = nil;
    }
    
    _maskLayer = [CALayer layer];
    _maskLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0].CGColor;
    [self.layer addSublayer:_maskLayer];
}

#pragma mark - Responder

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.needRespond) {
        return self.superview;
    }

    return [super hitTest:point withEvent:event];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _beginTime = CACurrentMediaTime();
    
    [self p_touchesBeganAnimation];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _endTime = CACurrentMediaTime();
    
    CFTimeInterval stepDuration = _endTime - _beginTime;
    if (stepDuration < kAnimationInterval) {
        [self performSelector:@selector(p_touchesEnded) withObject:nil afterDelay:kAnimationInterval - stepDuration];
    } else {
        [self p_touchesEnded];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self p_touchesEndedAnimation];
}

#pragma mark - Private

- (void)p_touchesEnded {
    [self p_touchesEndedAnimation];
    
    if ([self.delegate respondsToSelector:@selector(voteContentViewTouchesEnded:)]) {
        [self.delegate voteContentViewTouchesEnded:self];
    }
}

- (void)p_touchesBeganAnimation {
    _maskLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.15].CGColor;
    [self.layer removeAnimationForKey:kTouchBeganAnimationKey];
    [self.layer addAnimation:self.beginAnimation forKey:kTouchBeganAnimationKey];
}

- (void)p_touchesEndedAnimation {
    _maskLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0].CGColor;
    [self.layer removeAnimationForKey:kTouchEndAnimationKey];
    [self.layer addAnimation:self.endAnimation forKey:kTouchEndAnimationKey];
}

#pragma mark - Getter

- (CABasicAnimation *)beginAnimation {
    if (!_beginAnimation) {
        _beginAnimation = [self animation];
        
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / 500;
        transform = CATransform3DTranslate(transform, 0, 0, -30);
        _beginAnimation.toValue = [NSValue valueWithCATransform3D:transform];
    }
    return _beginAnimation;
}

- (CABasicAnimation *)endAnimation {
    if (!_endAnimation) {
        _endAnimation = [self animation];
        
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / 500;
        _endAnimation.toValue = [NSValue valueWithCATransform3D:transform];
    }
    return _endAnimation;
}

- (CABasicAnimation *)animation {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform";
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = kAnimationInterval;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}

@end

@interface WLPollView () <WLVoteContentViewDelegate>

@end

@implementation WLPollView {
    NSString *_pollID;
    WLPollPost *_pollModel;
    
    BOOL _isRepost;
}

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _isRepost = YES;
    }
    
    return self;
}

#pragma mark - Public

- (void)setPollModel:(WLPollPost *)pollModel
           viewWidth:(CGFloat)viewWidth
          viewHeight:(CGFloat)viewHeight
      imgCellSpacing:(CGFloat)imgCellSpacing
        noImgSpacing:(CGFloat)noImgSpacing {
    if (!pollModel.isNeedReDraw && [_pollID isEqualToString:pollModel.pollID]) {
        return;
    }
    
    _pollID = pollModel.pollID;
    _pollModel = pollModel;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (pollModel.voteList.count == 0) {
        return;
    }
    
    if (viewWidth == 0 || viewHeight == 0) {
        return;
    }
    
    NSInteger numberInRow = 2;
    CGFloat textCellHeight = 40.0 / kVoteImageCellDefaultHeight * viewHeight;
    
    for (int i = 0; i < pollModel.voteList.count; i++) {
        WLVoteModel *voteModel = pollModel.voteList[i];
        
        BOOL needShowPercent = pollModel.hasPolled || pollModel.isExpiredPoll || pollModel.isMyPoll;
        
        if (voteModel.imgUrlString.length > 0) {
            [self drawImageVoteViewWithVoteModel:voteModel
                                       viewWidth:viewWidth
                                      viewHeight:viewHeight
                                         spacing:imgCellSpacing
                                     numberInRow:numberInRow
                                  textCellHeight:textCellHeight
                                  totalVoteCount:pollModel.totalCount
                                 needShowPercent:needShowPercent
                                               i:i];
        } else {
            [self drawNoImageVoteViewWithVoteModel:voteModel
                                         viewWidth:viewWidth
                                        viewHeight:viewHeight
                                           spacing:noImgSpacing
                                       numberInRow:numberInRow
                                    textCellHeight:textCellHeight
                                    totalVoteCount:pollModel.totalCount
                                   needShowPercent:needShowPercent
                                                 i:i];
        }
    }
    
    CGFloat y = pollModel.isImagePoll
    ? ceilf((pollModel.voteList.count / (float)numberInRow)) * (viewHeight + imgCellSpacing) - imgCellSpacing
    : pollModel.voteList.count * (viewHeight + noImgSpacing) - noImgSpacing;
    
    [self drawInfoViewWithPollModel:pollModel
                                  x:cellPaddingLeft
                                  y:y];
}

- (void)drawImageVoteViewWithVoteModel:(WLVoteModel *)voteModel
                             viewWidth:(CGFloat)viewWidth
                            viewHeight:(CGFloat)viewHeight
                               spacing:(CGFloat)spacing
                           numberInRow:(NSInteger)numberInRow
                        textCellHeight:(CGFloat)textCellHeight
                        totalVoteCount:(NSUInteger)totalVoteCount
                       needShowPercent:(BOOL)needShowPercent
                                     i:(int)i {
    WLVoteContentView *contentView = [[WLVoteContentView alloc] init];
    contentView.needRespond = !_pollModel.hasPolled && !_pollModel.isExpiredPoll;
    contentView.delegate = self;
    contentView.tag = i;
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.frame = CGRectMake((i % numberInRow) * (viewWidth + spacing),
                                   (i / numberInRow) * (viewHeight + spacing),
                                   viewWidth, viewHeight);
    contentView.layer.borderColor = kUIColorFromRGB(0xC9C9C9).CGColor;
    contentView.layer.borderWidth = 0.5;
    [self addSubview:contentView];
    
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.backgroundColor = kUIColorFromRGB(0xE9E9E9);
    imgView.frame = CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height - textCellHeight);
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    [imgView fq_setImageWithURLString:voteModel.imgUrlString];
    [contentView addSubview:imgView];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, imgView.bounds.size.height - 35, imgView.bounds.size.width, 35);
    gradientLayer.colors = @[(__bridge id)kUIColorFromRGBA(0x000000, 0.4).CGColor, (__bridge id)kUIColorFromRGBA(0x000000, 0.0).CGColor];
    gradientLayer.startPoint = CGPointMake(0.5, 1.0);
    gradientLayer.endPoint = CGPointMake(0.5, 0.0);
    [imgView.layer addSublayer:gradientLayer];
    
    if (needShowPercent) {
        UIView *percentView = ({
            CGFloat padding = 8.0;
            
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor clearColor];
            view.frame = CGRectMake(0, 0, imgView.frame.size.width - padding * 2, 25);
            view.center = CGPointMake(imgView.bounds.size.width * 0.5, imgView.bounds.size.height - padding - view.bounds.size.height * 0.5);
            
            CGFloat ratio = 0.0;
            CGFloat percent = 0.0;
            [self p_calculatePercent:voteModel.count totalCount:totalVoteCount ratio:&ratio percent:&percent];
            
            UILabel *lab = [[UILabel alloc] init];
            lab.textColor = [UIColor whiteColor];
            lab.font = kBoldFont(kMediumNameFontSize);
            lab.text = [self p_percentStr:percent];
            [lab sizeToFit];
            lab.center = CGPointMake(lab.bounds.size.width * 0.5, view.bounds.size.height * 0.5);
            [view addSubview:lab];
            
            UIProgressView *progressView = [[UIProgressView alloc] init];
            progressView.frame = CGRectMake(0, 0, view.bounds.size.width - CGRectGetMaxX(lab.frame) - padding, 0.0);
            progressView.center = CGPointMake(padding + CGRectGetMaxX(lab.frame) + progressView.bounds.size.width * 0.5, view.bounds.size.height * 0.5);
            progressView.transform = CGAffineTransformMakeScale(1.0, 3.0);
            progressView.trackTintColor = [UIColor clearColor];
            
            if (kiOS9Later) {
                UIImage *image = nil;
                if (voteModel.isSelected) {
                    image = [AppContext getImageForKey:@"poll_progress_dark"];
                } else {
                    image = [AppContext getImageForKey:@"poll_progress_light"];
                }
                CGFloat capInsets = image.size.width * 0.5;
                image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, capInsets, 0, capInsets) resizingMode:UIImageResizingModeStretch];
                progressView.progressImage = image;
            } else {
                if (voteModel.isSelected) {
                    progressView.progressTintColor = kProgressSelectedTintColor;
                } else {
                    progressView.progressTintColor = kProgressNormalTintColor;
                }
            }
            
            [progressView setProgress:[self p_progress:ratio] animated:NO];
            [view addSubview:progressView];
            
            view;
        });
        [imgView addSubview:percentView];
    }
    
    UILabel *txtLab = [[UILabel alloc] init];
    txtLab.frame = CGRectMake(8, imgView.size.height, contentView.frame.size.width - 8 * 2, textCellHeight);
    txtLab.textAlignment = NSTextAlignmentCenter;
    txtLab.textColor = kBodyFontColor;
    txtLab.font = kRegularFont(kMediumNameFontSize);
    txtLab.numberOfLines = 2;
    txtLab.text = voteModel.name;
    [contentView addSubview:txtLab];
    
    [contentView addMaskLayer];
}

- (void)drawNoImageVoteViewWithVoteModel:(WLVoteModel *)voteModel
                               viewWidth:(CGFloat)viewWidth
                              viewHeight:(CGFloat)viewHeight
                                 spacing:(CGFloat)spacing
                             numberInRow:(NSInteger)numberInRow
                          textCellHeight:(CGFloat)textCellHeight
                          totalVoteCount:(NSUInteger)totalVoteCount
                         needShowPercent:(BOOL)needShowPercent
                                       i:(int)i {
    WLVoteContentView *contentView = [[WLVoteContentView alloc] init];
    contentView.needRespond = !_pollModel.hasPolled && !_pollModel.isExpiredPoll;
    contentView.delegate = self;
    contentView.tag = i;
    if (needShowPercent && totalVoteCount != 0) {
        contentView.backgroundColor = [UIColor clearColor];
        contentView.layer.cornerRadius = 0.0;
    } else {
        contentView.backgroundColor = kProgressNormalTintColor;
        contentView.layer.cornerRadius = 4.0;
        contentView.layer.masksToBounds = YES;
    }
    contentView.frame = CGRectMake(cellPaddingLeft,
                                   i * (viewHeight + spacing),
                                   viewWidth - cellPaddingLeft * 2, viewHeight);
    [self addSubview:contentView];
    
    CGFloat ratio = 0.0;
    CGFloat percent = 0.0;
    [self p_calculatePercent:voteModel.count totalCount:totalVoteCount ratio:&ratio percent:&percent];
    
    
    CGFloat padding = 8;
    CGFloat perWidth = 0;
    
    if (needShowPercent) {
        UIProgressView *progressView = [[UIProgressView alloc] init];
        progressView.frame = CGRectMake(0, 0, contentView.bounds.size.width, 0.0);
        progressView.center = CGPointMake(contentView.bounds.size.width * 0.5, contentView.bounds.size.height * 0.5);
        progressView.transform = CGAffineTransformMakeScale(1.0, viewHeight * 0.5);
        progressView.trackTintColor = [UIColor clearColor];
        
        if (kiOS9Later) {
            UIImage *image = nil;
            if (voteModel.isSelected) {
                image = [AppContext getImageForKey:@"poll_progress_dark_noImg"];
            } else {
                image = [AppContext getImageForKey:@"poll_progress_light_noImg"];
            }
            CGFloat capInsets = image.size.width * 0.5;
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, capInsets, 0, capInsets) resizingMode:UIImageResizingModeStretch];
            progressView.progressImage = image;
        } else {
            if (voteModel.isSelected) {
                progressView.progressTintColor = kProgressSelectedTintColor;
            } else {
                progressView.progressTintColor = kProgressNormalTintColor;
            }
        }
        
        [progressView setProgress:totalVoteCount == 0 ? 0.0 :[self p_progress:ratio] animated:NO];
        [contentView addSubview:progressView];
        
        UILabel *perLab = [[UILabel alloc] init];
        perLab.textColor = kBodyFontColor;
        perLab.font = voteModel.isSelected ? kBoldFont(kMediumNameFontSize) : kRegularFont(kMediumNameFontSize);
        perLab.text = [self p_percentStr:percent];
        [perLab sizeToFit];
        perLab.center = CGPointMake(contentView.bounds.size.width - perLab.bounds.size.width * 0.5 - padding, contentView.bounds.size.height * 0.5);
        [contentView addSubview:perLab];
        
        perWidth = perLab.bounds.size.width;
    }
    
    UILabel *txtLab = [[UILabel alloc] init];
    txtLab.textColor = kBodyFontColor;
    txtLab.font = voteModel.isSelected ? kBoldFont(kMediumNameFontSize) : kRegularFont(kMediumNameFontSize);
    txtLab.numberOfLines = 1;
    txtLab.text = voteModel.name;
    [txtLab sizeToFit];
    txtLab.width = contentView.bounds.size.width - padding * 2 - perWidth;
    txtLab.center = CGPointMake(padding + txtLab.bounds.size.width * 0.5, contentView.bounds.size.height * 0.5);
    [contentView addSubview:txtLab];
    
    [contentView addMaskLayer];
}

- (void)drawInfoViewWithPollModel:(WLPollPost *)pollModel
                                x:(CGFloat)x
                                y:(CGFloat)y {
    if (!pollModel.hasPolled && !pollModel.isExpiredPoll && !pollModel.isMyPoll) {
        CGFloat insets = 4.0;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor clearColor];
        btn.selected = _isRepost;
        btn.frame = CGRectMake(x, y, 0, 0);
        [btn setImage:[AppContext getImageForKey:@"small_check"] forState:UIControlStateNormal];
        [btn setImage:[AppContext getImageForKey:@"small_check_select"] forState:UIControlStateSelected];
        [btn setTitle:[AppContext getStringForKey:@"poll_about_info_1" fileName:@"feed"] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, insets, 0, 0)];
        [btn setTitleColor:kLightLightFontColor forState:UIControlStateNormal];
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        btn.titleLabel.font = kRegularFont(kMediumNameFontSize);
        [btn sizeToFit];
        btn.width += insets;
        btn.height = kPollInfoHeight;
        [btn addTarget:self action:@selector(checkBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        y += btn.frame.size.height;
    }
    
    UILabel *infoLab = [[UILabel alloc] init];
    infoLab.backgroundColor = [UIColor clearColor];
    infoLab.frame = CGRectMake(x, y, self.bounds.size.width - x * 2, kPollInfoHeight);
    infoLab.textAlignment = NSTextAlignmentRight;
    infoLab.textColor = kLightLightFontColor;
    infoLab.font = kRegularFont(kMediumNameFontSize);
    infoLab.text = pollModel.remainText;
    [self addSubview:infoLab];
}

#pragma mark - WLVoteContentViewDelegate

- (void)voteContentViewTouchesEnded:(WLVoteContentView *)contentView {
    if (_pollModel.isExpiredPoll) {
        return;
    }
    
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    if (_pollModel.hasPolled) {
        return;
    }
    
    if (_pollModel.isMyPoll) {
        [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"poll_cannot_vote_yourself" fileName:@"feed"]];
        return;
    }
    
    NSInteger index = contentView.tag;
    if (index < 0 || index >= _pollModel.voteList.count) {
        return;
    }
    
    NSArray *choiceArray = @[_pollModel.voteList[index]];
    [self postVoteWithChoiceArray:choiceArray];
}

#pragma mark - Event

- (void)checkBtnClicked:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    
    _isRepost = sender.isSelected;
}

#pragma mark - Network

- (void)postVoteWithChoiceArray:(NSArray<WLVoteModel *> *)choiceArray {
    [[AppContext currentViewController] showLoading];
    
    WLSingleContentManager *manager = [AppContext getInstance].singleContentManager;
    [manager postVoteWithPollModel:_pollModel
                       choiceArray:choiceArray
                          isRepost:_isRepost
                          finished:^(BOOL succeed, WLPollPost *pollModel) {
                              [[AppContext currentViewController] hideLoading];
                              
                              if (succeed && pollModel) {
                                  if ([self.delegate respondsToSelector:@selector(pollView:didPolled:)]) {
                                      [self.delegate pollView:self didPolled:pollModel];
                                  }
                              }
                          }];
}

#pragma mark - Private

- (void)p_calculatePercent:(NSUInteger)count totalCount:(NSUInteger)totalCount ratio:(CGFloat *)ratio percent:(CGFloat *)percent {
    CGFloat r = totalCount > 0 ? count / (float)totalCount : 0;
    *ratio = r;
    *percent = roundf(r * 100);
}

- (float)p_progress:(float)ratio {
    return ratio > 0 ? ratio : 0.01;
}

- (NSString *)p_percentStr:(CGFloat)percent {
    return [NSString stringWithFormat:@"%.0f%@", percent, @"%"];
}

@end
