//
//  RDLinkLabel.m
//  welike
//
//  Created by 刘斌 on 2018/4/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDLinkLabel.h"
#import "UIView+LuuBase.h"
#import "WLUIResourceDefine.h"

@interface RDLinkLabel ()

@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UIColor *defaultTextColor;

@end

@implementation RDLinkLabel

- (id)initWithFrame:(CGRect)frame defaultTextColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _hideBottomLine = NO;
        self.defaultTextColor = color;
        self.textColor = self.defaultTextColor;
        self.backgroundColor = [UIColor clearColor];
        [self setUserInteractionEnabled:YES];
        _enable = YES;
        self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.bottom - 1.f, self.width, 1.f)];
        [self.bottomLine setBackgroundColor:self.textColor];
        [self addSubview:self.bottomLine];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.textColor = kClickableTextColor;
    [self.bottomLine setBackgroundColor:kClickableTextColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.textColor = self.defaultTextColor;
    [self.bottomLine setBackgroundColor:self.defaultTextColor];
    
    UITouch *touch = [touches anyObject];
    CGPoint points = [touch locationInView:self];
    CGRect selfFrame = CGRectMake(0, 0, self.width, self.height);
    if (points.x >= selfFrame.origin.x && points.y >= selfFrame.origin.x && points.x <= selfFrame.size.width && points.y <= selfFrame.size.height)
    {
        if ([self.linkTouchDelegate respondsToSelector:@selector(linkLabelClick:)])
        {
            [self.linkTouchDelegate linkLabelClick:self];
        }
    }
}

- (void)setEnable:(BOOL)enable
{
    _enable = enable;
    if (_enable == YES)
    {
        self.textColor = self.defaultTextColor;
        self.bottomLine.hidden = NO;
        [self setUserInteractionEnabled:YES];
    }
    else
    {
        self.textColor = kNameFontColor;
        self.bottomLine.hidden = YES;
        [self setUserInteractionEnabled:NO];
    }
}

- (void)setHideBottomLine:(BOOL)hideBottomLine
{
    _hideBottomLine = hideBottomLine;
    self.bottomLine.hidden = _hideBottomLine;
}

@end
