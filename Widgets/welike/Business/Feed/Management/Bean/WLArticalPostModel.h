//
//  WLArticalPostModel.h
//  welike
//
//  Created by gyb on 2019/1/19.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLPostBase.h"

NS_ASSUME_NONNULL_BEGIN

@class WLUser;
@interface WLArticalPostModel : WLPostBase

@property (copy,nonatomic) NSString *content;
@property (copy,nonatomic) NSString *title;
@property (strong,nonatomic) NSMutableArray *attachments;
@property (copy,nonatomic) NSString *cover;
@property (assign,nonatomic) NSInteger created;
@property (assign,nonatomic) BOOL isDeleted;
@property (copy,nonatomic) NSString *articalId;
@property (strong,nonatomic) WLUser *userInfo;

+ (instancetype)modelWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
