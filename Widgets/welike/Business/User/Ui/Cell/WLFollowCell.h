//
//  WLFollowCell.h
//  welike
//
//  Created by fan qi on 2018/5/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFollowUserCellHeight               72.f

@class WLUser;

typedef NS_ENUM(NSInteger, WELIKE_FOLLOW_CELL_TYPE)
{
    WELIKE_FOLLOW_CELL_TYPE_NORMAL = 1,
    WELIKE_FOLLOW_CELL_TYPE_SEARCH
};

@interface WLFollowCell : UITableViewCell

@property (nonatomic, strong) WLUser *itemModel;
@property (nonatomic, assign) WELIKE_FOLLOW_CELL_TYPE type;

@end
