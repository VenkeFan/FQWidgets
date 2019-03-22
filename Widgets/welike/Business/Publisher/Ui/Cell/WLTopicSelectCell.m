//
//  WLTopicSelectCell.m
//  welike
//
//  Created by gyb on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicSelectCell.h"

@implementation WLTopicSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        flagView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 11, 16, 10)];
        flagView.image = [AppContext getImageForKey:@"topic_hot"];
        [self.contentView addSubview:flagView];
        flagView.hidden = YES;

        topicNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(flagView.right + 7, 10, kScreenWidth - flagView.right - 7 - 15, 16)];
        topicNameLabel.font = kRegularFont(14);
        topicNameLabel.textAlignment = NSTextAlignmentLeft;
        topicNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        topicNameLabel.textColor = kNameFontColor;
        topicNameLabel.text = @"";
//        topicNameLabel.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:topicNameLabel];
        
        topicDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,topicNameLabel.bottom + 4, 70, 14)];
        topicDesLabel.font = kRegularFont(12);
        topicDesLabel.textAlignment = NSTextAlignmentLeft;
        topicDesLabel.textColor = kDescriptionColor;
        topicDesLabel.numberOfLines = 1;
        topicDesLabel.text = @"";
        topicDesLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//         topicDesLabel.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:topicDesLabel];
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(13, 50 - 1, kScreenWidth - 13, 1)];
        lineView.backgroundColor = kSeparateLineColor;
        [self.contentView addSubview:lineView];
        
    }
    return self;
}


-(void)setType:(WELIKE_TOPIC_TYPE)type
{
    _type = type;
    
    flagView.hidden = YES;
    
    topicNameLabel.left = flagView.right + 7;
    
    if (_type == WELIKE_TOPIC_TYPE_hot)
    {
        flagView.hidden = NO;
        topicNameLabel.left = 15;
        topicNameLabel.top = 8;
        topicDesLabel.top = 28;
        flagView.top = 11;
        lineView.top = 50 - 1;
        topicNameLabel.font = kRegularFont(14);
        
    }

    if (_type == WELIKE_TOPIC_TYPE_recently)
    {
        flagView.top = 10;
        topicNameLabel.left = 15;
        topicNameLabel.font = kRegularFont(16);
        topicNameLabel.top = 12;
        
        topicNameLabel.width = kScreenWidth - 30;
        lineView.top = 40 - 1;
        topicDesLabel.frame = CGRectZero;
        
    }
    if (_type == WELIKE_TOPIC_TYPE_recommand)
    {
        flagView.top = 10;
        flagView.image = nil;
        
        topicNameLabel.frame = CGRectMake(15, (40 - 18)/2.0, kScreenWidth - 30, 18);
        topicNameLabel.font = kRegularFont(16);
        topicDesLabel.frame = CGRectZero;
        
        lineView.top = 40 - 1;
        
    }
    if (_type == WELIKE_TOPIC_TYPE_add)
    {
        flagView.top = 10;
        flagView.image = nil;
        
        topicNameLabel.frame = CGRectMake(15, (40 - 18)/2.0, kScreenWidth - 30 - topicDesLabel.width - 10, 18);
        topicNameLabel.font = kRegularFont(16);
        topicDesLabel.frame = CGRectZero;
        
        lineView.top = 40 - 1;
    }
}

-(void)setTopicName:(NSString *)topicName
{
    _topicName = topicName;
    topicNameLabel.text = [NSString stringWithFormat:@"# %@",_topicName];
    
    //计算文字长度
    CGSize strSize = [topicNameLabel.text sizeWithFont:topicNameLabel.font size:CGSizeMake(kScreenWidth - 30 - 15, 16)];
    flagView.left = 15 + strSize.width + 2;
    
    
//    if (_type == WELIKE_TOPIC_TYPE_hot)
//    {
//        topicNameLabel.top = 10;
//    }
//    else
//    {
//        topicNameLabel.top = 8.5;
//    }
}

-(void)setTopicDes:(NSString *)topicDes
{
    _topicDes = topicDes;
    topicDesLabel.text = topicDes;
    
    if (_type == WELIKE_TOPIC_TYPE_add)
    {
        topicNameLabel.width = kScreenWidth - 30 - 70 - 10;
        topicDesLabel.frame = CGRectMake(topicNameLabel.right + 15, topicNameLabel.top, 70, topicNameLabel.height);
    }
    else
    {
        topicNameLabel.width = kScreenWidth - 30;
        topicDesLabel.frame = CGRectMake(15, topicNameLabel.bottom + 4, kScreenWidth  - 30, 16);
    }
}

-(void)setCompareStr:(NSString *)compareStr
{
    NSString *highLightTopicStr = [NSString stringWithFormat:@"# %@",_topicName];
    
    NSRange range = [highLightTopicStr rangeOfString:compareStr options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:highLightTopicStr] ;
        [attributedText addAttribute:NSForegroundColorAttributeName value:kMainColor range:range];
        
        topicNameLabel.attributedText = attributedText;
        
    }
    else
    {
         topicNameLabel.attributedText = [[NSAttributedString alloc] initWithString:highLightTopicStr];
    }
}



@end
