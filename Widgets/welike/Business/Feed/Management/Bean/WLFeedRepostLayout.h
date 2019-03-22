//
//  WLFeedRepostLayout.h
//  welike
//
//  Created by fan qi on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLPostBase.h"

#define reCellPaddingTop                      (8)
#define reCellPaddingLeft                     (12)
#define reCellAvatarSize                      (kAvatarSizeSmall)
#define reCellPaddingX                        (12)
#define reCellContentWidth                    (kScreenWidth - reCellPaddingLeft * 2 - reCellAvatarSize - reCellPaddingX)
#define reCellLineHeight                      (1.0)

#define reCellNameFont                        kRegularFont(12.0)
#define reCellBodyFont                        kRegularFont(14.0)
#define reCellDateTimeFont                    kRegularFont(10.0)

@interface WLFeedRepostLayout : NSObject

+ (instancetype)layoutWithFeedModel:(WLPostBase *)feedModel;

@property (nonatomic, strong, readonly) WLPostBase *feedModel;
@property (nonatomic, strong) WLHandledFeedModel *handledFeedModel;
@property (nonatomic, strong) WLHandledFeedModel *rootPostHandledFeedModel;

@property (nonatomic, copy) NSString *souceTail;

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, assign) CGRect avatarFrame;
@property (nonatomic, assign) CGRect nameFrame;
@property (nonatomic, assign) CGRect timeFrame;
@property (nonatomic, assign) CGRect textFrame;

@property (nonatomic, assign) CGRect lineFrame;

@end
