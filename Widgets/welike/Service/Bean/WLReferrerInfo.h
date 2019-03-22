//
//  WLReferrerInfo.h
//  welike
//
//  Created by 刘斌 on 2018/5/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLReferrerInfo : NSObject

@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *head;
@property (nonatomic, copy) NSString *toast;
@property (nonatomic, assign) NSInteger vip;

+ (WLReferrerInfo *)parseReferrerInfo:(NSDictionary *)info;

@end
