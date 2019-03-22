//
//  WLTrendingTopicCell.m
//  welike
//
//  Created by gyb on 2018/8/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrendingTopicCell.h"
#import "WLTopicThumbView.h"
#import "WLTopicInfoModel.h"
#import "WLPicPost.h"
#import "WLPicInfo.h"
#import "UIImageView+WebCache.h"

@implementation WLTrendingTopicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    
    topicTitleLabel =  [[UILabel alloc] initWithFrame:CGRectMake(12, 8, kScreenWidth/2.0, 16)];
    topicTitleLabel.font = kBoldFont(14);
    topicTitleLabel.textColor = kNameFontColor;
    topicTitleLabel.textAlignment = NSTextAlignmentLeft;
    topicTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//    topicTitleLabel.text = @"Guo Yibo";
    [self.contentView addSubview:topicTitleLabel];
   
    iconView =  [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:iconView];
    iconView.hidden = YES;
    
    
    topicDesLabel =  [[UILabel alloc] initWithFrame:CGRectMake(12, topicTitleLabel.bottom + 4, kScreenWidth*0.6, 14)];
    topicDesLabel.font = kRegularFont(12);
    topicDesLabel.textColor = kLightLightFontColor;
//    topicDesLabel.text = @"intresting";
    topicDesLabel.textAlignment = NSTextAlignmentLeft;
    topicDesLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:topicDesLabel];
    
    UIImage *indicateImage = [AppContext getImageForKey:@"common_arrow_right_orange"];
    indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - indicateImage.size.width - 10, 18, indicateImage.size.width, indicateImage.size.height)];
    indicatorView.image = indicateImage;
    [self.contentView addSubview:indicatorView];
  
    viewsCountLabel =  [[UILabel alloc] initWithFrame:CGRectMake(indicatorView.left - 80 - 10, 14, 80, 20)];
    viewsCountLabel.font = kRegularFont(12);
    viewsCountLabel.textColor = kLightLightFontColor;
    viewsCountLabel.textAlignment = NSTextAlignmentCenter;
    viewsCountLabel.backgroundColor = kLabelBgColor;
    viewsCountLabel.layer.cornerRadius = 3;
    viewsCountLabel.clipsToBounds = YES;
    [self.contentView addSubview:viewsCountLabel];
    
    CGFloat thumbHeight = (kScreenWidth - 16 - 6*3)/4.0;
    
    
    topicThumbView = [[WLTopicThumbView alloc] initWithFrame:CGRectMake(0, 48, kScreenWidth, thumbHeight)];
    [self.contentView addSubview:topicThumbView];
    topicThumbView.hidden = YES;
    
    
    gapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 8)];
    gapView.backgroundColor = kLabelBgColor;
    [self .contentView addSubview:gapView];
    gapView.hidden = YES;
}

-(void)setModel:(WLTopicInfoModel *)model
{
    _model = model;
    
    pics = [self picsFromTopicInfo];
    
    topicTitleLabel.text = model.topicName;
    
    CGFloat labelWidth = 0;
    
    if (kScreenWidth == 320)
    {
        labelWidth = kScreenWidth/2.0;
    }
    else
    {
        labelWidth = kScreenWidth*0.6;
    }
    
    CGSize titleSize = [model.topicName sizeWithFont:topicTitleLabel.font size:CGSizeMake(labelWidth, topicTitleLabel.height)];
    topicTitleLabel.width = titleSize.width;
    topicDesLabel.width = labelWidth;
    
    
    iconView.frame = CGRectMake(topicTitleLabel.right + 5, topicTitleLabel.top + 2, 12, 12);
    
    if (_model.icon.length > 0)
    {
        iconView.hidden = NO;
        [iconView sd_setImageWithURL:[NSURL URLWithString:_model.icon]];
    }
    else
    {
        iconView.hidden = YES;
        iconView.image = nil;
    }

    topicDesLabel.text = model.desc;

     gapView.hidden = NO;
    if (pics.count > 0)
    {
        CGFloat thumbHeight = (kScreenWidth - 16 - 6*3)/4.0;
        
        gapView.top =  48 + thumbHeight + 8 + 8 - gapView.height;
        topicThumbView.pics = pics;
        topicThumbView.hidden = NO;
    }
    else
    {
        gapView.top = 62 - gapView.height;
        topicThumbView.hidden = YES;
    }
    
    
    
    CGFloat count = 0;
    NSString *countStr;
    if (model.viewsCount > 9999)
    {
        count = model.viewsCount/1000.0;
        countStr = [NSString stringWithFormat:@"%.1fk views",count];
    }
    else
    {
        countStr = [NSString stringWithFormat:@"%ld views",(long)model.viewsCount];
    }
    
    viewsCountLabel.text = countStr;
    CGSize countStrSize = [countStr sizeWithFont:viewsCountLabel.font size:CGSizeMake(150, viewsCountLabel.height)];
    viewsCountLabel.frame = CGRectMake(indicatorView.left - (countStrSize.width + 10) - 10, 14, countStrSize.width + 10, 20);
}


-(NSMutableArray *)picsFromTopicInfo{
    
    NSMutableArray *pics = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < _model.postArray.count; i++)
    {
        WLPostBase *post = _model.postArray[i];
        
        if ([post isKindOfClass:[WLPicPost class]])
        {
            WLPicPost *picPost = (WLPicPost *)post;
            
            for (int j = 0; j < picPost.picInfoList.count; j++)
            {
                WLPicInfo *info = picPost.picInfoList[j];
                if (info.picUrl.length != 0)
                {
                    [pics addObject:info.picUrl];
                }
            }
        }
    }
    
    return pics;
}




@end
