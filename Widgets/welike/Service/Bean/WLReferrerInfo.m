//
//  WLReferrerInfo.m
//  welike
//
//  Created by 刘斌 on 2018/5/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLReferrerInfo.h"
#import "NSDictionary+JSON.h"

@implementation WLReferrerInfo

- (id)init
{
    self = [super init];
    if (self)
    {
        self.vip = 0;
    }
    return self;
}

+ (WLReferrerInfo *)parseReferrerInfo:(NSDictionary *)info
{
    if (info != nil)
    {
        WLReferrerInfo *referrerInfo = [[WLReferrerInfo alloc] init];
        referrerInfo.nickName = [info stringForKey:@"nickName"];
        referrerInfo.head = [info stringForKey:@"avatarUrl"];
        referrerInfo.toast = [info stringForKey:@"referrerMsg"];
        referrerInfo.vip = [info integerForKey:@"vip" def:0];
        return referrerInfo;
    }
    return nil;
}

@end
