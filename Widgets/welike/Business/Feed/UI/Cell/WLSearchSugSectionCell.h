//
//  WLSearchSugSectionCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *WLSearchSugSectionCellIdentifier = @"WLSearchSugSectionCell";

@interface WLSearchSugSectionItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CGFloat cellHeight;

@end

@protocol WLSearchSugSectionCellDelegate <NSObject>

- (void)deleteAll;

@end

@interface WLSearchSugSectionCell : UITableViewCell

@property (nonatomic, weak) id<WLSearchSugSectionCellDelegate> delegate;

- (void)setDataSourceItem:(WLSearchSugSectionItem *)item;

@end
