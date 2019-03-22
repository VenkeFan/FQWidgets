//
//  WLShareModel.m
//  welike
//
//  Created by fan qi on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLShareModel.h"

@implementation WLShareModel

+ (instancetype)modelWithID:(NSString *)ID
                       type:(WLShareModelType)type {
    return [self modelWithID:ID
                        type:type
                       title:nil
                        desc:nil];
}

+ (instancetype)modelWithID:(NSString *)ID
                       type:(WLShareModelType)type
                      title:(NSString *)title
                       desc:(NSString *)desc {
    return [self modelWithID:ID
                        type:type
                       title:title
                        desc:desc
                      imgUrl:nil
                     linkUrl:nil];
}

+ (instancetype)modelWithID:(NSString *)ID
                       type:(WLShareModelType)type
                      title:(NSString *)title
                       desc:(NSString *)desc
                     imgUrl:(NSString *)imgUrl
                    linkUrl:(NSString *)linkUrl {
    WLShareModel *model = [[WLShareModel alloc] init];
    model.shareID = ID;
    model.type = type;
    model.title = title;
    model.desc = desc;
    model.imgUrl = imgUrl;
    model.linkUrl = linkUrl;
    
    return model;
}

+ (instancetype)modelWithPost:(WLPostBase *)post {
    WLShareModel *shareModel = [self modelWithID:post.pid
                                            type:WLShareModelType_Feed
                                           title:post.nickName
                                            desc:post.richContent.text];
    shareModel.postModel = post;
    
    return shareModel;
}

@end
