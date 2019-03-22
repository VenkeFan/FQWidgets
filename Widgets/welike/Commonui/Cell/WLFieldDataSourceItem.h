//
//  WLFieldDataSourceItem.h
//  welike
//
//  Created by 刘斌 on 2018/4/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLFieldDataSourceItem : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, assign) UIKeyboardType editingKeyboardType;
@property (nonatomic, assign) BOOL secureTextEntry;
@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat rightMargin;

- (CGFloat)calculateCellHeight;

@end
