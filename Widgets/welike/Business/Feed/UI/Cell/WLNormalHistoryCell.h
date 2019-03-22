//
//  WLNormalHistoryCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLNormalHisDataSourceItem.h"

@protocol WLNormalHistoryCellDelegate <NSObject>

- (void)onRemove:(NSIndexPath *)indexPath;

@end

static NSString *WLNormalHistoryCellIdentifier = @"WLNormalHistoryCell";

@interface WLNormalHistoryCell : UITableViewCell

@property (nonatomic, weak) id<WLNormalHistoryCellDelegate> delegate;

- (void)setDataSourceItem:(WLNormalHisDataSourceItem *)item indexPath:(NSIndexPath *)indexPath;

@end
