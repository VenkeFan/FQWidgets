//
//  WLStatusEditCell.m
//  welike
//
//  Created by gyb on 2018/11/16.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLStatusEditCell.h"
#import "UIImageView+WebCache.h"

@implementation WLStatusEditCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
        bgView.contentMode =  UIViewContentModeScaleAspectFill;
//        bgView.backgroundColor = kPlaceHolderColor;
//        bgView.image = [AppContext getImageForKey:@"post_status_placehoder"];
        [self.contentView addSubview:bgView];
        
//        inputView = [[UITextView alloc] initWithFrame:CGRectMake(25, 48, kScreenWidth - 50, kScreenWidth - 96)];
//        inputView.textAlignment = NSTextAlignmentCenter;
//        inputView.backgroundColor = [UIColor redColor];
////        inputView.font =
//        [self.contentView addSubview:inputView];
        
        if (kScreenHeight == 480)
        {
            bgView.height = 240;
        }
        
    }
    return self;
}

-(void)setPicUrlStr:(NSString *)picUrlStr
{
    _picUrlStr = picUrlStr;
    [bgView sd_setImageWithURL:[NSURL URLWithString:picUrlStr]];
    
    
    
    
}

-(void)changeBg:(UIImage *)image
{
    bgView.image = image;
    
}



@end
