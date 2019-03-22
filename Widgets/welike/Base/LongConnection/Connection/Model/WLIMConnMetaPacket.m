//
//  WLIMConnMetaPacket.m
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMConnMetaPacket.h"
#import "WLIMEventDefines.h"

@implementation WLIMConnMetaPacket

+ (instancetype)connMetaWithConfig:(WLIMUserConfig *)config
{
    WLIMConnMetaPacket *packet = [[self alloc] init];
    packet.uid = config.uid;
    packet.sessionId = config.token;
    packet.deviceType = ConnMeta_DeviceType_Ios;
    packet.version = config.version;
    packet.deviceInfo = config.deviceInfo;
    packet.la = config.la;
    packet.netType = config.netType;
    packet.clientTime = [[NSDate date] timeIntervalSince1970];
    return packet;
}

#pragma mark - WLIMPacking

- (uint16_t)packetType
{
    return WLEventConn;
}

- (NSData *)packetBody
{
    ConnMeta *conn = [[ConnMeta alloc] init];
    conn.uid = self.uid;
    conn.sessionId = self.sessionId;
    conn.deviceType = self.deviceType;
    conn.version = self.version;
    conn.deviceInfo = self.deviceInfo;
    conn.la = self.la;
    conn.netType = self.netType;
    conn.clientTime = self.clientTime;
    return [conn data];
}

@end
