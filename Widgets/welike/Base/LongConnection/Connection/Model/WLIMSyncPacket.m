//
//  WLIMSyncPacket.m
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMSyncPacket.h"

@implementation WLIMSyncPacket

+ (instancetype)seqId:(uint64_t)seqId fromUid:(NSString *)uid classified:(GPBEnumArray *)classified
{
    WLIMSyncPacket *packet = [[self alloc] init];
    packet.seqId = seqId;
    packet.fromUid = uid;
    packet.classifiedArray = classified;
    return packet;
}

#pragma mark - WLIMPacking

- (uint16_t)packetType
{
    return WLEventSync;
}

- (NSData *)packetBody
{
    SyncPacket *syncPacket = [[SyncPacket alloc] init];
    syncPacket.seqId = self.seqId;
    syncPacket.fromUid = self.fromUid;
    syncPacket.classifiedArray = self.classifiedArray;
    if (syncPacket.classifiedArray == nil) {
        GPBEnumArray *array = [GPBEnumArray array];
        [array addValue:MessageClassified_P2P];
        syncPacket.classifiedArray = array;
    }
    return [syncPacket data];
}

@end
