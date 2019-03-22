//
//  WLIMSyncFinPacket.h
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
// 发给服务端的确认完成的包

#import "WLIMPacking.h"
#import "WLIMEventDefines.h"
#import "BibiProtoApplication.pbobjc.h"

@interface WLIMSyncFinPacket : NSObject <WLIMPacking>

@property(nonatomic, strong) NSMutableArray<SyncDataPacket_SyncMark*> *syncMarksArray;

@property(nonatomic, readwrite) int64_t sendTime;

+ (instancetype)syncMarks:(NSMutableArray<SyncDataPacket_SyncMark*> *)syncMark sendTime:(int64_t)time;

@end
