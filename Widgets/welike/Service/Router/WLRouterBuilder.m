//
//  WLRouterBuilder.m
//  welike
//
//  Created by 刘斌 on 2018/5/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRouterBuilder.h"

@interface WLRouterBuilder ()

@property (nonatomic, assign) WELIKE_ROUTER_TYPE type;
@property (nonatomic, copy) NSString *group;
@property (nonatomic, copy) NSString *mainTab;
@property (nonatomic, copy) NSString *pageName;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, copy) NSString *web;

@end

@implementation WLRouterBuilder

+ (WLRouterBuilder *)createByUri:(NSString *)uri
{
    if (uri == nil || [uri length] == 0)
    {
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:uri];
    if ([url.scheme isEqualToString:@"welike"] == NO)
    {
        WLRouterBuilder *bu = nil;
        if ([url.scheme isEqualToString:@"https"] == YES)
        {
            bu = [[WLRouterBuilder alloc] init];
            bu.type = WELIKE_ROUTER_TYPE_WEB;
            bu.web = uri;
        }
        else if ([url.scheme isEqualToString:@"http"] == YES)
        {
            bu = [[WLRouterBuilder alloc] init];
            bu.type = WELIKE_ROUTER_TYPE_WEB;
            bu.web = [uri convertToHttps];
        }
        return bu;
    }
    
    if ([url.host isEqualToString:@"com.redefine.welike"] == NO) return nil;
    
    if ([url.pathComponents count] != 3) return nil;
    
    NSArray *queryComponents = [url.query componentsSeparatedByString:@"&"];
    
    WLRouterBuilder *builder = [[WLRouterBuilder alloc] init];
    builder.type = WELIKE_ROUTER_TYPE_NAV;
    builder.group = [url.pathComponents objectAtIndex:1];
    builder.mainTab = [url.pathComponents objectAtIndex:2];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:[queryComponents count]];
    for (NSString *keyValuePair in queryComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] urlDecode:NSUTF8StringEncoding];
        NSString *value = [[pairComponents lastObject] urlDecode:NSUTF8StringEncoding];
        if ([key isEqualToString:@"page_name"] == YES)
        {
            builder.pageName = value;
        }
        else
        {
            if ([key length] > 0 && [value length] > 0)
            {
                [params setObject:value forKey:key];
            }
        }
    }
    if ([params count] > 0)
    {
        builder.params = [[NSDictionary alloc] initWithDictionary:params];
    }
    return builder;
}

@end
