//
//  WLIMSyncFinPacket.m
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMSyncFinPacket.h"

@implementation WLIMSyncFinPacket

+ (instancetype)syncMarks:(NSMutableArray<SyncDataPacket_SyncMark*> *)syncMark sendTime:(int64_t)time
{
    WLIMSyncFinPacket *packet = [[self alloc] init];
    packet.syncMarksArray = syncMark;
    packet.sendTime = time;
    return packet;
}

#pragma mark - WLIMPacking

- (uint16_t)packetType
{
    return WLEventFin;
}

- (NSData *)packetBody
{
    SyncDataFin *finPacket = [[SyncDataFin alloc] init];
    finPacket.syncMarksArray = self.syncMarksArray;
    finPacket.sendTime = self.sendTime;
    return [finPacket data];
}

@end
