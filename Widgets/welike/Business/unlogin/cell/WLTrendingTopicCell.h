//
//  WLTrendingTopicCell.h
//  welike
//
//  Created by gyb on 2018/8/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLTopicThumbView;
@class WLTopicInfoModel;
@interface WLTrendingTopicCell : UITableViewCell
{
    UILabel *topicTitleLabel;
    UIImageView *iconView;
    
    
    UILabel *topicDesLabel;
    UILabel *viewsCountLabel;
    
    UIImageView *indicatorView;
    
    WLTopicThumbView *topicThumbView;
    
    UIView *gapView;
    
    NSArray *pics;
}

@property (strong,nonatomic) WLTopicInfoModel *model;

@end
