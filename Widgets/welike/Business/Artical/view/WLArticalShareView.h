//
//  WLArticalShareView.h
//  welike
//
//  Created by gyb on 2019/2/25.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WLShareManager;
@class WLArticalPostModel;
@interface WLArticalShareView : UIView
{
   
}

@property (nonatomic, strong) WLShareManager *shareManager;
@property (strong,nonatomic) WLArticalPostModel *postBase;

- (instancetype)initWithFrame:(CGRect)frame withBtnWidth:(CGFloat)btnWidth haveTitle:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END
