//
//  WLResidentTopicCell.h
//  welike
//
//  Created by fan qi on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDefaultButtonCount                 4

#define kWLResidentTopicContentHeight       64
#define kWLResidentTopicCellHeight          (kWLResidentTopicContentHeight)

@class WLTopicInfoModel, WLResidentTopicCell;

@protocol WLResidentTopicCellDelegate <NSObject>

- (void)residentTopicCell:(WLResidentTopicCell *)cell didClickedTopic:(NSString *)topicID;

@end

@interface WLResidentTopicCell : UITableViewCell

@property (nonatomic, copy) NSArray<WLTopicInfoModel *> *dataArray;
@property (nonatomic, weak) id<WLResidentTopicCellDelegate> delegate;

@end
