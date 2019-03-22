//
//  WLTrendingUserModel.h
//  welike
//
//  Created by gyb on 2018/8/23.
//  Copyright © 2018年 redefine. All rights reserved.
//


@interface WLTrendingUserModel : NSObject

@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *forwardUrl;
@property (nonatomic, strong) NSMutableArray *users;

+ (WLTrendingUserModel *)parseTrendingUserInfo:(NSDictionary *)info;

@end
