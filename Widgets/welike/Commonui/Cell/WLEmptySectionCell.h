//
//  WLEmptySectionCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *WLEmptySectionCellIdentifier = @"WLEmptySectionCell";

@interface WLEmptySectionDataSourceItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) BOOL sectionMark;

@end

@interface WLEmptySectionCell : UITableViewCell

- (void)setDataSourceItem:(WLEmptySectionDataSourceItem *)item;

@end
