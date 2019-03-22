//
//  WLHeadView.h
//  welike
//
//  Created by 刘斌 on 2018/4/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLHeadView, WLUserBase, WLPostBase, WLComment;

@protocol WLHeadViewDelegate <NSObject>

@optional
- (void)onClick:(WLHeadView *)headView;

@end

@interface WLHeadView : UIImageView

@property (nonatomic, copy) NSString *headUrl;
@property (nonatomic, weak) id<WLHeadViewDelegate> delegate;

@property (nonatomic, strong) WLPostBase *feedModel;
@property (nonatomic, strong) WLUserBase *user;
@property (nonatomic, strong) WLComment *comment;

- (id)initWithDefaultImageId:(NSString *)imageId;

- (void)handleVip:(NSInteger)vipValue;

- (void)addBorder;
- (void)addShadow;

@end
