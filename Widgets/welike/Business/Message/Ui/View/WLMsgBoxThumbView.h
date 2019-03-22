//
//  WLMsgBoxThumbView.h
//  welike
//
//  Created by 刘斌 on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLMsgBoxThumbView;

@protocol WLMsgBoxThumbViewDelegate <NSObject>

- (void)msgBoxThumbViewOnClick:(WLMsgBoxThumbView *)view;

@end

@interface WLMsgBoxThumbView : UIControl

@property (nonatomic, copy) NSString *thumbUrl;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, weak) id<WLMsgBoxThumbViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame placeholder:(UIImage *)placeholder;

@end
