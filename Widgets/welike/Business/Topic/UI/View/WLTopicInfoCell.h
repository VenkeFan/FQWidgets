//
//  WLTopicInfoCell.h
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLTopicInfoModel, WLTopicInfoCell;

#define kWLTopicInfoCellHeight              120

@protocol WLTopicInfoCellDelegate <NSObject>

- (void)topicInfoCellDidClickedUsers:(WLTopicInfoCell *)cell;

@end

@interface WLTopicInfoCell : UITableViewCell

@property (nonatomic, strong) WLTopicInfoModel *itemModel;
@property (nonatomic, copy) NSArray *userArray;

@property (nonatomic, weak) id<WLTopicInfoCellDelegate> delegate;

@end
