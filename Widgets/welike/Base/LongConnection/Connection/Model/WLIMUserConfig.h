//
//  WLIMUserConfig.h
//  IMTest
//
//  Created by luxing on 2018/5/2.
//  Copyright © 2018年 chiemy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLIMUserConfig : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) int32_t version;
@property (nonatomic, copy) NSString *deviceInfo;
@property (nonatomic, copy) NSString *la;
@property (nonatomic, assign) int32_t netType;

+ (instancetype)defaultUserConfig;

@end
