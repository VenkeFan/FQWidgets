//
//  WLTopicSearchSectionView.m
//  welike
//
//  Created by gyb on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicSearchSectionView.h"

@implementation WLTopicSearchSectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        lightView = [[UIView alloc] initWithFrame:CGRectMake(-4, (frame.size.height - 16)/2.0, 8, 16)];
        lightView.backgroundColor = kMainColor;
        lightView.layer.cornerRadius = 3;
        lightView.clipsToBounds = YES;
        [self addSubview:lightView];
        
        promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, lightView.top, kScreenWidth - 8, 16)];
        promptLabel.textColor = kNameFontColor;
        promptLabel.font = kBoldFont(14);
        promptLabel.text = @"";
        promptLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:promptLabel];
        
        desLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth - 8, 14)];
        desLabel.textColor = kNameFontColor;
        desLabel.font = kRegularFont(12);
        desLabel.text = @"";
        desLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:desLabel];
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(15, frame.size.height - 1, kScreenWidth, 1)];
        lineView.backgroundColor = kSeparateLineColor;
        [self addSubview:lineView];
        
    }
    return self;
}


-(void)setTitleStr:(NSString *)titleStr
{
    _titleStr = titleStr;
    promptLabel.text = titleStr;
    
    
    
}

-(void)setDesStr:(NSString *)desStr
{
    _desStr = desStr;
    desLabel.text = desStr;
    
    lightView.top = 10;
    promptLabel.top = lightView.top;
    desLabel.top = 28;
}


-(void)hideLine
{
    lineView.hidden = YES;
}



//-(void)setSymbolImage:(UIImage *)symbolImage
//{
//    _symbolImage = symbolImage;
//    symbolView.image = _symbolImage;
//    if (_symbolImage == nil)
//    {
//        symbolView.hidden = YES;
//        titleLabel.left = 15;
//    }
//    else
//    {
//        symbolView.hidden = NO;
//        titleLabel.left = 15 + 15 + 7;
//
//    }
//}



@end
