//
//  WLShortUrlManager.h
//  welike
//
//  Created by fan qi on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLShareModel.h"

typedef void(^shortUrlSuccessed)(NSString *urlString);
typedef void(^shortUrlFailed)(NSInteger errorCode);

typedef NS_ENUM(NSInteger, WLShortUrlShareMode) {
    WLShortUrlShareMode_More,
    WLShortUrlShareMode_Facebook,
    WLShortUrlShareMode_WhatsApp,
    WLShortUrlShareMode_Instagram,
    WLShortUrlShareMode_Copy
};

@interface WLShortUrlManager : NSObject

@property (nonatomic, assign) WLShortUrlShareMode shareUrlMode;
@property (nonatomic, assign) WLShareModelType shareType;

- (void)loadShortUrlWithShareID:(NSString *)shareID successed:(shortUrlSuccessed)successed failed:(shortUrlFailed)failed;

@end
