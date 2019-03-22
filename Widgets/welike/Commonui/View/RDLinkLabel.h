//
//  RDLinkLabel.h
//  welike
//
//  Created by 刘斌 on 2018/4/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RDLinkLabel;

@protocol RDLinkLabelDelegate <NSObject>

- (void)linkLabelClick:(RDLinkLabel *)label;

@end

@interface RDLinkLabel : UILabel

@property (nonatomic, weak) id<RDLinkLabelDelegate> linkTouchDelegate;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) BOOL hideBottomLine;

- (id)initWithFrame:(CGRect)frame defaultTextColor:(UIColor *)color;

@end
