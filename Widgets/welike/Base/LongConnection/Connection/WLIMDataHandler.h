//
//  WLIMDataHandler.h
//  welike
//
//  Created by 刘斌 on 2018/5/19.
//  Copyright © 2018年 redefine. All rights reserved.
//  数据解包

#import <Foundation/Foundation.h>

@class SyncDataPacket_DataEntry;

@protocol WLIMDataHandlerDelegate <NSObject>

- (void)dataHandlerNewNotifications;
- (void)dataHandlerCompleted:(NSArray<SyncDataPacket_DataEntry*> *)entries lv:(long long)lv needSync:(BOOL)needSync last:(BOOL)last;
- (void)dataHandlerSendResult:(NSString *)mid errCode:(NSInteger)errCode;

@end

@interface WLIMDataHandler : NSObject

@property (nonatomic, weak) id<WLIMDataHandlerDelegate> delegate;

- (void)handleReceivedData:(NSArray *)dataList;

@end
