//
//  WLMessageBox.h
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLMessageBox;

@protocol WLMessageBoxDelegate <NSObject>

- (void)onClick:(WLMessageBox *)messageBox;

@end

@interface WLMessageBox : UIControl

@property (nonatomic, assign) NSUInteger badgeNum;
@property (nonatomic, weak) id<WLMessageBoxDelegate> delegate;

- (id)initWithFrame:(CGRect)frame iconResId:(NSString *)iconResId title:(NSString *)title;

@end
