//
//  WLMsgBoxThumbView.m
//  welike
//
//  Created by 刘斌 on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMsgBoxThumbView.h"
#import "UIImageView+WebCache.h"
//#import "UIImageView+Extension.h"

@interface WLMsgBoxThumbView ()

@property (nonatomic, strong) UIImageView *thumbView;
@property (nonatomic, strong) UIImageView *playIcon;
@property (nonatomic, strong) UIView *cover;
@property (nonatomic, strong) UIImage *placeholder;
@property (nonatomic, strong) UILabel *label;

@end

@implementation WLMsgBoxThumbView

- (id)initWithFrame:(CGRect)frame placeholder:(UIImage *)placeholder
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.isVideo = NO;
        self.placeholder = placeholder;
        [self addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setSummary:(NSString *)summary
{
    if ([summary length] > 0)
    {
        if (self.label == nil)
        {
            self.label = [[UILabel alloc] init];
            [self addSubview:self.label];
        }
        self.label.frame = CGRectMake(0, 0, self.width, self.height);
        self.label.font = [UIFont systemFontOfSize:kLightFontSize];
        self.label.textColor = kDescFontColor;
        self.label.textAlignment = NSTextAlignmentRight;
        self.label.text = summary;
        self.label.numberOfLines = 0;
    }
    else
    {
        if (self.label != nil)
        {
            [self.label removeFromSuperview];
            self.label = nil;
        }
    }
}

- (void)setThumbUrl:(NSString *)thumbUrl
{
    if ([thumbUrl length] > 0)
    {
        if (self.thumbView == nil)
        {
            self.thumbView = [[UIImageView alloc] init];
            [self addSubview:self.thumbView];
        }
        self.thumbView.frame = CGRectMake(0, 0, self.width, self.height);
        [self.thumbView sd_setImageWithURL:[NSURL URLWithString:thumbUrl] placeholderImage:self.placeholder];
    }
    else
    {
        if (self.thumbView != nil)
        {
            [self.thumbView removeFromSuperview];
            self.thumbView = nil;
        }
    }
}

- (void)setIsVideo:(BOOL)isVideo
{
    if (isVideo == YES)
    {
        if (self.thumbView == nil)
        {
            self.thumbView = [[UIImageView alloc] init];
            [self addSubview:self.thumbView];
        }
        self.thumbView.frame = CGRectMake(0, 0, self.width, self.height);
        if (self.cover == nil)
        {
            self.cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
            [self addSubview:self.cover];
        }
        self.cover.backgroundColor = [UIColor grayColor];
        self.cover.alpha = 0.5f;
        if (self.playIcon == nil)
        {
            self.playIcon = [[UIImageView alloc] initWithImage:[AppContext getImageForKey:@"thumb_video_mark_small"]];
            [self addSubview:self.playIcon];
        }
        self.playIcon.frame = CGRectMake((self.width - self.playIcon.width) / 2.f, (self.height - self.playIcon.height) / 2.f, self.playIcon.width, self.playIcon.height);
    }
    else
    {
        if (self.cover != nil)
        {
            [self.cover removeFromSuperview];
            self.cover = nil;
        }
        if (self.playIcon != nil)
        {
            [self.playIcon removeFromSuperview];
            self.playIcon = nil;
        }
    }
}

- (void)onClick
{
    if ([self.delegate respondsToSelector:@selector(msgBoxThumbViewOnClick:)])
    {
        [self.delegate msgBoxThumbViewOnClick:self];
    }
}

@end
