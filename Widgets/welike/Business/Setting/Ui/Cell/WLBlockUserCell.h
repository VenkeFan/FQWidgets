//
//  WLBlockUserCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *WLBlockUserCellIdentifier = @"WLBlockUserCell";

@interface WLBlockUserDataSourceItem : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *head;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, readonly) CGFloat cellHeight;

@end

@protocol WLBlockUserCellDelegate <NSObject>

- (void)onUnblock:(NSIndexPath *)indexPath;

@end

@interface WLBlockUserCell : UITableViewCell

@property (nonatomic, weak) id<WLBlockUserCellDelegate> delegate;

- (void)setDataSourceItem:(WLBlockUserDataSourceItem *)item indexPath:(NSIndexPath *)indexPath;

@end
