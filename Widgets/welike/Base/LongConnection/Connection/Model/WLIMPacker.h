//
//  WLIMPacker.h
//  TCPSocketClient-Demo
//
//  Created by luxing on 2018/4/27.
//  Copyright © 2018年 Steven. All rights reserved.
// 解析porbuff数据的

#import "WLIMServerNode.h"
#import "WLIMUserConfig.h"
#import "WLIMHeartbeatPacket.h"
#import "WLIMConnMetaPacket.h"

@interface WLIMPackerHeader : NSObject

@property (nonatomic, assign) uint64_t seqId;
@property (nonatomic, assign) int64_t ackId;
@property (nonatomic, assign) uint16_t type;
@property (nonatomic, assign) uint8_t version;
@property (nonatomic, assign) uint32_t dataLen;

@end

@interface WLIMPacker : NSObject

@property (nonatomic, strong) WLIMPackerHeader *header;
@property (nonatomic, strong) NSData *body;

+ (NSData *)packet:(id<WLIMPacking>)packet;
+ (NSArray<WLIMPacker *> *)unpackData:(NSData *)data;

@end

@interface NSData (NSDataBaseValueEncoding)

- (uint32_t)uint32Value;

@end
