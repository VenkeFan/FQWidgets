//
//  WLRegLikeIcon.m
//  welike
//
//  Created by 刘斌 on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRegLikeIcon.h"

#define kContentHeight           17.f
#define kPart1Content            @"Welike"
#define kPart1IconWidth          12.f
#define kPart1IconHeight         10.f
#define kPart2Content            @"India"
#define kPart2IconWidth          15.f
#define kPart2IconHeight         10.f

@implementation WLRegLikeIcon

- (id)initWithFrame:(CGRect)frame
{
    UIFont *font = [UIFont systemFontOfSize:kLightFontSize];
    CGFloat l1width = [kPart1Content sizeWithFont:font size:CGSizeMake(80, kContentHeight)].width;
    CGFloat l2width = [kPart2Content sizeWithFont:font size:CGSizeMake(80, kContentHeight)].width;
    CGFloat width = l1width + 2 + kPart1IconWidth + 2 + l2width + 2 + kPart2IconWidth;
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, width, kContentHeight)];
    if (self)
    {
        UILabel *w = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, l1width, kContentHeight)];
        w.textColor = kBodyFontColor;
        w.font = font;
        w.text = kPart1Content;
        [self addSubview:w];

        UIImageView *i1 = [[UIImageView alloc] initWithImage:[AppContext getImageForKey:@"register_icon_like"]];
        i1.frame = CGRectMake(w.right + 2, (kContentHeight - kPart1IconHeight) / 2.f, kPart1IconWidth, kPart1IconHeight);
        [self addSubview:i1];
        
        UILabel *i = [[UILabel alloc] initWithFrame:CGRectMake(i1.right + 2, 0, l2width, kContentHeight)];
        i.textColor = kBodyFontColor;
        i.font = font;
        i.text = kPart2Content;
        [self addSubview:i];
        
        UIImageView *i2 = [[UIImageView alloc] initWithImage:[AppContext getImageForKey:@"register_icon_India"]];
        i2.frame = CGRectMake(i.right + 2, (kContentHeight - kPart2IconHeight) / 2.f, kPart2IconWidth, kPart2IconHeight);
        [self addSubview:i2];
    }
    return self;
}

@end
