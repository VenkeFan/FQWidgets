//
//  WLComment.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLRichContent.h"

@interface WLComment : NSObject

@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *pid;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *head;
@property (nonatomic, assign) BOOL following;
@property (nonatomic, assign) BOOL follower;
@property (nonatomic, assign) long long time;
@property (nonatomic, assign) long long likeCount;
@property (nonatomic, assign) BOOL like;
@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, assign) NSInteger vip;
@property (nonatomic, assign) NSInteger childrenCount;
@property (nonatomic, strong) WLRichContent *content;
@property (nonatomic, strong) NSArray *children;

+ (WLComment *)parseFromNetworkJSON:(NSDictionary *)json;

@end
