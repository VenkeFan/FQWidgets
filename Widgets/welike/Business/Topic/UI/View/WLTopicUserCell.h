//
//  WLTopicUserCell.h
//  welike
//
//  Created by fan qi on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTopicUserCellHeight            75

@class WLUser;

@interface WLTopicUserCell : UITableViewCell

@property (nonatomic, strong) WLUser *itemModel;

@end
