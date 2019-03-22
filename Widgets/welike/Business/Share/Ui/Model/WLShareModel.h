//
//  WLShareModel.h
//  welike
//
//  Created by fan qi on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLPostBase.h"

typedef NS_ENUM(NSInteger, WLShareModelType) {
    WLShareModelType_Feed            = 1,
    WLShareModelType_App             = 2,
    WLShareModelType_Task            = 3,
    WLShareModelType_Profile         = 4,
    WLShareModelType_Topic           = 5,
    WLShareModelType_WebView,
    WLShareModelType_Text
};

@interface WLShareModel : NSObject

+ (instancetype)modelWithID:(NSString *)ID
                       type:(WLShareModelType)type;
+ (instancetype)modelWithID:(NSString *)ID
                       type:(WLShareModelType)type
                      title:(NSString *)title
                       desc:(NSString *)desc;
+ (instancetype)modelWithID:(NSString *)ID
                       type:(WLShareModelType)type
                      title:(NSString *)title
                       desc:(NSString *)desc
                     imgUrl:(NSString *)imgUrl
                    linkUrl:(NSString *)linkUrl;
+ (instancetype)modelWithPost:(WLPostBase *)post;

@property (nonatomic, assign) WLShareModelType type;
@property (nonatomic, copy) NSString *shareID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, strong) WLPostBase *postModel;

@end
