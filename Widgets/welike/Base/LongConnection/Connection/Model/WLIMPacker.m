//
//  WLIMPacker.m
//  TCPSocketClient-Demo
//
//  Created by luxing on 2018/4/27.
//  Copyright © 2018年 Steven. All rights reserved.
//

#import "WLIMPacker.h"

static const uint32_t WLPacketHeaderLength = 8+8+2+1+4;
static const uint8_t WLPacketVersion = 1;

@implementation NSData (NSDataBaseValueEncoding)

- (uint64_t)uint64Value
{
    uint64_t len;
    [self getBytes:&len length:sizeof(len)];
    return CFSwapInt64BigToHost(len);//大小端不一样，需要转化
}

- (uint32_t)uint32Value
{
    uint32_t len;
    [self getBytes:&len length:sizeof(len)];
    return CFSwapInt32BigToHost(len);
}

- (uint16_t)uint16Value
{
    uint16_t len;
    [self getBytes:&len length:sizeof(len)];
    return CFSwapInt16BigToHost(len);
}

- (uint8_t)uint8Value
{
    uint8_t len;
    [self getBytes:&len length:sizeof(len)];
    return len;
}

@end

@implementation WLIMPackerHeader

@end

@implementation WLIMPacker

#pragma mark - packet
+ (uint64_t)seqId
{
    static uint64_t seqId = 0;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        seqId = (uint64_t)[[NSDate date] timeIntervalSince1970];
    });
    @synchronized (self)
    {
        return ++seqId;
    }
}

+ (WLIMPackerHeader *)packetHeaderWithSeqId:(uint64_t)seqId type:(uint16_t)type
{
    uint64_t sId = 0;
    if (seqId > 0)
    {
        sId = seqId;
    }
    else
    {
        sId = [self seqId];
    }
    WLIMPackerHeader *header = [[WLIMPackerHeader alloc] init];
    header.seqId = sId;
    header.ackId = -1;
    header.type = type;
    header.version = WLPacketVersion;
    header.dataLen = 0;
    return header;
}

+ (NSData *)packetWithHeader:(WLIMPackerHeader *)header body:(NSData *)body
{
    if (header != nil && body != nil)
    {
        header.dataLen = (uint32_t)body.length;
        uint32_t packetLen = CFSwapInt32BigToHost(WLPacketHeaderLength+header.dataLen);
        uint64_t seqId = CFSwapInt64BigToHost(header.seqId);
        int64_t ackId = CFSwapInt64BigToHost(header.ackId);
        uint16_t type = CFSwapInt16BigToHost(header.type);
        uint8_t version = header.version;
        uint32_t dataLen = CFSwapInt32BigToHost(header.dataLen);
        NSMutableData *data = [NSMutableData dataWithBytes:&packetLen length:sizeof(packetLen)];
        [data appendBytes:&seqId length:sizeof(seqId)];
        [data appendBytes:&ackId length:sizeof(ackId)];
        [data appendBytes:&type length:sizeof(type)];
        [data appendBytes:&version length:sizeof(version)];
        [data appendBytes:&dataLen length:sizeof(dataLen)];
        [data appendData:body];
        return data;
    }
    return nil;
}

+ (NSData *)packet:(id<WLIMPacking>)packet
{
    WLIMPackerHeader *header = [self packetHeaderWithSeqId:0 type:packet.packetType];
    NSData *body = [packet packetBody];
    return [self packetWithHeader:header body:body];
}

#pragma mark - unpacket
+ (WLIMPackerHeader *)unpackHeader:(NSData *)packet
{
    NSUInteger packetLen = packet.length;
    if (packetLen > WLPacketHeaderLength)
    {
        uint32_t datalen = [[packet subdataWithRange:NSMakeRange(19, 4)] uint32Value];
        if (packetLen >= datalen+WLPacketHeaderLength)
        {
            WLIMPackerHeader *header = [[WLIMPackerHeader alloc] init];
            header.seqId = [packet uint64Value];
            header.ackId = [[packet subdataWithRange:NSMakeRange(8, 8)] uint64Value];
            header.type = [[packet subdataWithRange:NSMakeRange(16,2)] uint16Value];
            header.version = [[packet subdataWithRange:NSMakeRange(18,1)] uint8Value];
            header.dataLen = datalen;
            return header;
        }
    }
    return nil;
}

+ (NSData *)unpackBody:(NSData *)packet withHeader:(WLIMPackerHeader *)header
{
    if (header != nil && packet.length >= header.dataLen+WLPacketHeaderLength)
    {
        return [packet subdataWithRange:NSMakeRange(WLPacketHeaderLength, header.dataLen)];
    }
    return nil;
}

+ (WLIMPacker *)unpack:(NSData *)packet
{
    WLIMPacker *mPacket = [[WLIMPacker alloc] init];
    mPacket.header = [WLIMPacker unpackHeader:packet];
    mPacket.body = [WLIMPacker unpackBody:packet withHeader:mPacket.header];
    if (mPacket.header != nil && mPacket.body != nil)
    {
        return mPacket;
    }
    return nil;
}

+ (NSArray<WLIMPacker *> *)unpackData:(NSData *)data
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:5];
    NSData *leaveData = data;
    WLIMPacker *mPacket = [self unpack:leaveData];
    while (mPacket != nil)
    {
        [list addObject:mPacket];
        NSUInteger loc = mPacket.header.dataLen+WLPacketHeaderLength;
        NSUInteger leaveLen = leaveData.length-loc;
        leaveData = [leaveData subdataWithRange:NSMakeRange(loc, leaveLen)];
        mPacket = [self unpack:leaveData];
    }
    return list;
}

@end
