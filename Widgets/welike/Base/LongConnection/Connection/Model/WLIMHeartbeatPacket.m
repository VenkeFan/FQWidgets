//
//  WLIMHeartbeatPacket.m
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMHeartbeatPacket.h"
#import "WLIMEventDefines.h"

@implementation WLIMHeartbeatPacket

+ (instancetype)heartbeatWithConfig:(WLIMUserConfig *)config
{
    WLIMHeartbeatPacket *packet = [[self alloc] init];
    packet.version = config.version;
    packet.timestamp = [[NSDate date] timeIntervalSince1970];
    return packet;
}

#pragma mark - WLIMPacking
- (uint16_t)packetType
{
    return WLEventHeartBeat;
}

- (NSData *)packetBody
{
    Heartbeat *heartbeat = [[Heartbeat alloc] init];
    heartbeat.timestamp = self.timestamp;
    heartbeat.version = self.version;
    return [heartbeat data];
}

- (BOOL)unPacket:(NSData *)body
{
    return NO;
}

@end
