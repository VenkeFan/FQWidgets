//
//  WLRouterBuilder.h
//  welike
//
//  Created by 刘斌 on 2018/5/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WELIKE_ROUTER_TYPE)
{
    WELIKE_ROUTER_TYPE_NAV = 1,
    WELIKE_ROUTER_TYPE_WEB
};

@interface WLRouterBuilder : NSObject

@property (nonatomic, readonly) WELIKE_ROUTER_TYPE type;
@property (nonatomic, readonly) NSString *group;
@property (nonatomic, readonly) NSString *mainTab;
@property (nonatomic, readonly) NSString *pageName;
@property (nonatomic, readonly) NSDictionary *params;
@property (nonatomic, readonly) NSString *web;

+ (WLRouterBuilder *)createByUri:(NSString *)uri;

@end
