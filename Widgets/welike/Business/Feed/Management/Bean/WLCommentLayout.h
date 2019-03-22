//
//  WLCommentLayout.h
//  welike
//
//  Created by fan qi on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLComment.h"
#import "WLHandledFeedModel.h"

#define commentPaddingTop                      (12)
#define commentPaddingLeft                     (15)
#define commentAvatarSize                      (kAvatarSizeSmall)
#define commentPaddingX                        (10)
#define commentPaddingY                        (6)
#define commentContentWidth                    (kScreenWidth - commentPaddingLeft * 2 - commentAvatarSize - commentPaddingX)
#define commentLineHeight                      (1.0)
#define commentToolBarHeight                   (30)
#define commentBarBtnWidth                     (48)

#define commentNameFont                     kRegularFont(12.0)
#define commentBodyFont                     kRegularFont(14.0)
#define commentTimeFont                     kRegularFont(10.0)
#define commentChildBodyFont                kRegularFont(12.0)

@interface WLCommentLayout : NSObject

- (instancetype)initWithComment:(WLComment *)comment;

@property (nonatomic, strong, readonly) WLComment *commentModel;
@property (nonatomic, strong) WLHandledFeedModel *handledFeedModel;
@property (nonatomic, strong) NSArray<WLHandledFeedModel *> *childrenHandledFeedModels;

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, assign) CGRect avatarFrame;
@property (nonatomic, assign) CGRect nameFrame;
@property (nonatomic, assign) CGRect textFrame;

@property (nonatomic, assign) CGRect childContentFrame;

@property (nonatomic, assign) CGFloat toolBarTop;

@property (nonatomic, copy) NSString *timeString;

@end
