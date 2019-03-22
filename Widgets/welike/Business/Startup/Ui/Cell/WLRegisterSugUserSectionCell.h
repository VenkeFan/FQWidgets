//
//  WLRegisterSugUserSectionCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLRegisterSugUserSectionDataSourceItem;

static NSString *WLRegisterSugUserSectionCellIdentifier = @"WLRegisterSugUserSectionCell";

@interface WLRegisterSugUserSectionCell : UITableViewCell

- (void)setDataSourceItem:(WLRegisterSugUserSectionDataSourceItem *)item;

@end
