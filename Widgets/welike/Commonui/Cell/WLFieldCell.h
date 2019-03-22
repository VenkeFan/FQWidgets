//
//  WLFieldCell.h
//  welike
//
//  Created by 刘斌 on 2018/4/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLFieldDataSourceItem.h"
#import "WLFieldKindCellDelegate.h"

static NSString *WLFieldCellIdentifier = @"WLFieldCell";

@interface WLFieldCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<WLFieldKindCellDelegate> delegate;

- (void)endEditingStatus;
- (BOOL)isTextFieldFocused;

- (void)setDataSourceItem:(WLFieldDataSourceItem *)item;

@end
