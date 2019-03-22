//
//  WLLargeBtnCell.h
//  welike
//
//  Created by 刘斌 on 2018/4/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLLargeBtnDataSourceItem.h"

static NSString *WLLargeBtnCellIdentifier = @"WLLargeBtnCell";

@protocol WLLargeBtnCellDelegate <NSObject>

- (void)onClickLargeBtn:(NSIndexPath *)indexPath;

@end

@interface WLLargeBtnCell : UITableViewCell

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *disableTitleColor;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *selBgColor;
@property (nonatomic, strong) UIColor *disableBgColor;
@property (nonatomic, assign) BOOL btnDisable;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<WLLargeBtnCellDelegate> delegate;

- (void)setDataSourceItem:(WLLargeBtnDataSourceItem *)item;

@end
