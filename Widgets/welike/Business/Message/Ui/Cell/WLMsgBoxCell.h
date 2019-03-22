//
//  WLMsgBoxCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLMsgBoxNotificationBase.h"

#define kMsgBoxCellThumbSize              46.f

@class WLHandledFeedModel;

@interface WLMsgBoxDataSourceItem : NSObject

@property (nonatomic, strong) WLMsgBoxNotificationBase *notification;
@property (nonatomic, assign) BOOL end;
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, weak) UIImage *placeholder;

- (void)calcCellHeigth;

@end

static NSString *WLMsgBoxCellIdentifier = @"WLMsgBoxCell";

@interface WLMsgBoxCell : UITableViewCell

- (void)setDataSourceItem:(WLMsgBoxDataSourceItem *)item;

@end
