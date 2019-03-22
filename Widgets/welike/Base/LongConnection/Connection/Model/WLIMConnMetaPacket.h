//
//  WLIMConnMetaPacket.h
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
// 绑定用户信息用的

#import "WLIMPacking.h"
#import "BibiProtocol.pbobjc.h"
#import "WLIMUserConfig.h"

@interface WLIMConnMetaPacket : NSObject <WLIMPacking>

@property(nonatomic, copy) NSString *uid;//登录用户的
@property(nonatomic, readwrite) ConnMeta_DeviceType deviceType;
@property(nonatomic, readwrite) int32_t version;
@property(nonatomic, copy) NSString *deviceInfo;
@property(nonatomic, copy) NSString *sessionId;
@property(nonatomic, copy) NSString *clientFlag;
@property(nonatomic, readwrite) int32_t authVersion;
@property(nonatomic, readwrite) int32_t luaVersion;
@property(nonatomic, readwrite) int32_t serverPkVersion;
@property(nonatomic, copy) NSData *publicKey;
@property(nonatomic, readwrite) NetType netType;
@property(nonatomic, readwrite) int64_t clientTime;
@property(nonatomic, copy) NSString *la;

+ (instancetype)connMetaWithConfig:(WLIMUserConfig *)config;

@end
