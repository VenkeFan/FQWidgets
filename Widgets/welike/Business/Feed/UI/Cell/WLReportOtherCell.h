//
//  WLReportOtherCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *WLReportOtherCellIdentifier = @"WLReportOtherCell";

@interface WLReportOtherDataSourceItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, copy) NSString *feedback;

@end

@interface WLReportOtherCell : UITableViewCell

- (void)setDataSourceItem:(WLReportOtherDataSourceItem *)item;

@end
