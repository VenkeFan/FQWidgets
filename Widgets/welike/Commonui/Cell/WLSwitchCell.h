//
//  WLSwitchCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLSwitchCellDataSourceItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL switchVal;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, assign) BOOL isTail;

@end

static NSString *WLSwitchCellIdentifier = @"WLSwitchCell";

@protocol WLSwitchCellDelegate <NSObject>

- (void)switchCellTag:(NSString *)tag switchOn:(BOOL)on;

@end

@interface WLSwitchCell : UITableViewCell

@property (nonatomic, weak) id<WLSwitchCellDelegate> delegate;

- (void)setDataSourceItem:(WLSwitchCellDataSourceItem *)item;

@end
