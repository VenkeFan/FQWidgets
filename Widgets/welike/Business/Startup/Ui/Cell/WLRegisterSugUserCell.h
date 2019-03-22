//
//  WLRegisterSugUserCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLRegisterSugUserDataSourceItem;

static NSString *WLRegisterSugUserCellIdentifier = @"WLRegisterSugUserCell";

@interface WLRegisterSugUserCell : UITableViewCell

- (void)setDataSourceItem:(WLRegisterSugUserDataSourceItem *)item;

@end
