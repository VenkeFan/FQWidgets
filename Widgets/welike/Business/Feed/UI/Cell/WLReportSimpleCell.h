//
//  WLReportSimpleCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *WLReportSimpleCellIdentifier = @"WLReportSimpleCell";

@interface WLReportSimpleDataSourceItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, readonly) CGFloat titleHeight;
@property (nonatomic, readonly) CGFloat cellHeight;

@end

@interface WLReportSimpleCell : UITableViewCell

- (void)setDataSourceItem:(WLReportSimpleDataSourceItem *)item;

@end
