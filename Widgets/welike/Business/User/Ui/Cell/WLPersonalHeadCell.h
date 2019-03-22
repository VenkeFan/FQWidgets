//
//  WLPersonalHeadCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLPersonalHeadDataSourceItem : NSObject

@property (nonatomic, copy) NSString *head;
@property (nonatomic, readonly) CGFloat cellHeight;

@end

static NSString *WLPersonalHeadCellIdentifier = @"WLPersonalHeadCell";

@protocol WLPersonalHeadCellDelegate <NSObject>

- (void)onClickHead;

@end

@interface WLPersonalHeadCell : UITableViewCell

@property (nonatomic, weak) id<WLPersonalHeadCellDelegate> delegate;

- (void)setDataSourceItem:(WLPersonalHeadDataSourceItem *)item;

@end
