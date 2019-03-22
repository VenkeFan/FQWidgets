//
//  WLLanguageSelectCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLLanguageSelectDataSourceItem : NSObject

@property (nonatomic, copy) NSString *display;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL isTail;
@property (nonatomic, assign, readonly) CGFloat cellHeight;

@end

static NSString *WLLanguageSelectCellIdentifier = @"WLLanguageSelectCell";

@interface WLLanguageSelectCell : UITableViewCell

- (void)setDataSourceItem:(WLLanguageSelectDataSourceItem *)item;

@end
