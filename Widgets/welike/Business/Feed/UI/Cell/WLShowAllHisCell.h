//
//  WLShowAllHisCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *WLShowAllHisCellIdentifier = @"WLShowAllHisCell";

@interface WLShowAllHisDataSourceItem : NSObject

@property (nonatomic, readonly) CGFloat cellHeight;

@end

@interface WLShowAllHisCell : UITableViewCell

- (void)setDataSourceItem:(WLShowAllHisDataSourceItem *)item;

@end
