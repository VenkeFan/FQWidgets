//
//  WLIMHeartbeatPacket.h
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
// 心跳包数据对象

#import "WLIMPacking.h"
#import "BibiProtocol.pbobjc.h"
#import "WLIMUserConfig.h"

@interface WLIMHeartbeatPacket : NSObject <WLIMPacking>

@property(nonatomic, readwrite) int64_t timestamp;
@property(nonatomic, readwrite) int32_t version;

+ (instancetype)heartbeatWithConfig:(WLIMUserConfig *)config;

@end
