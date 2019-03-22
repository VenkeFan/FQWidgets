//
//  WLPersonalCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLPersonalDataSourceItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *warning;
@property (nonatomic, assign) BOOL contentSingleLine;
@property (nonatomic, assign) BOOL isTail;
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, readonly) CGFloat contentHeight;
@property (nonatomic, assign) NSInteger userTag;

@end

static NSString *WLPersonalCellIdentifier = @"WLPersonalCell";

@interface WLPersonalCell : UITableViewCell

- (void)setDataSourceItem:(WLPersonalDataSourceItem *)item;

@end
