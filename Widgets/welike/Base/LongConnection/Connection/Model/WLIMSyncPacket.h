//
//  WLIMSyncPacket.h
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
// 拉历史数据时候,传给服务器的包

#import "WLIMPacking.h"
#import "WLIMEventDefines.h"
#import "BibiProtoApplication.pbobjc.h"

@interface WLIMSyncPacket : NSObject <WLIMPacking>

@property(nonatomic, copy) NSString *fromUid;

@property(nonatomic, readwrite) int64_t seqId;//时间戳,目前固定值1

@property(nonatomic, strong) GPBEnumArray *classifiedArray;

+ (instancetype)seqId:(uint64_t)seqId fromUid:(NSString *)uid classified:(GPBEnumArray *)classified;

@end
