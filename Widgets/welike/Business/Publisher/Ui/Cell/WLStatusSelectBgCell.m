//
//  WLStatusSelectBgCell.m
//  welike
//
//  Created by gyb on 2018/11/20.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLStatusSelectBgCell.h"
#import "WLPicInfo.h"


@implementation WLStatusSelectBgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        bgView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, 60, 60)];
        bgView.contentMode =  UIViewContentModeScaleAspectFill;
//        bgView.layer.borderColor = kMainColor.CGColor;
//        bgView.layer.borderWidth = 2;
//        bgView.backgroundColor = kPlaceHolderColor;
        //        bgView.image = [AppContext getImageForKey:@"post_status_placehoder"];
        [self.contentView addSubview:bgView];
    }
    return self;
}

-(void)setPicUrlStr:(NSString *)picUrlStr
{
    _picUrlStr = picUrlStr;
    
    WLPicInfo *picInfo = [[WLPicInfo alloc] init];
    picInfo.picUrl = picUrlStr;

    [picInfo calculatePicThumbnailInfoWithWidth:60*3];
    
    [bgView fq_setImageWithURLString:picInfo.thumbnailPicUrl placeholder:[AppContext getImageForKey:@"rectangle_placeholder"] cornerRadius:7 completed:^(UIImage *image, NSURL *url, NSError *error) {
        
    }];
}


@end
