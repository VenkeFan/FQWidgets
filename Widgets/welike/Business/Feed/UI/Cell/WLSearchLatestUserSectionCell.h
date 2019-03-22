//
//  WLSearchLatestUserSectionCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *WLSearchLatestUserSectionCellIdentifier = @"WLSearchLatestUserSectionCell";

@interface WLSearchLatestUserSectionDataSourceItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CGFloat cellHeight;

@end

@protocol WLSearchLatestUserSectionCellDelegate <NSObject>

- (void)goToAll;

@end

@interface WLSearchLatestUserSectionCell : UITableViewCell

@property (nonatomic, weak) id<WLSearchLatestUserSectionCellDelegate> delegate;

- (void)setDataSourceItem:(WLSearchLatestUserSectionDataSourceItem *)item;

@end
