//
//  WLTopicSelectCell.h
//  welike
//
//  Created by gyb on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WELIKE_TOPIC_TYPE)
{
    WELIKE_TOPIC_TYPE_hot = 0,
    WELIKE_TOPIC_TYPE_recently = 1,
    WELIKE_TOPIC_TYPE_recommand = 2,
    WELIKE_TOPIC_TYPE_add = 3
};


@interface WLTopicSelectCell : UITableViewCell
{
    UIImageView *flagView;
    UILabel *topicNameLabel;
    UILabel *topicDesLabel;
    UIView *lineView;
}


@property (assign,nonatomic) WELIKE_TOPIC_TYPE type; //0 hot  1 recently  2 recommand
@property (strong,nonatomic) NSString *topicName;
@property (strong,nonatomic) NSString *topicDes;
@property (strong,nonatomic) NSString *compareStr;

@end
