//
//  WLIMConnectionManager.h
//  IMTest
//
//  Created by luxing on 2018/5/2.
//  Copyright © 2018年 chiemy. All rights reserved.
//  封装WLIMConnection

#import "WLIMConnection.h"

@class SyncDataPacket_DataEntry;

@protocol WLIMConnectionManagerDelegate <NSObject>

@optional
- (void)imConnectionManagerReceiveEntries:(NSArray<SyncDataPacket_DataEntry*> *)entries last:(BOOL)last;
- (void)imConnectionManagerReceiveNotifications;
- (void)imConnectionManagerOneSendResult:(NSString *)mid errCode:(NSInteger)errCode;
- (void)imConnectionManagerAllSendResultsError:(NSInteger)errCode;
- (void)imConnectionManagerConnectSuccessed;
- (void)imConnectionManagerTokenInvalid;

@end

@interface WLIMConnectionManager : NSObject

+ (WLIMConnectionManager *)instance;

- (void)registerDelegate:(id<WLIMConnectionManagerDelegate>)delegate;
- (void)unregister:(id<WLIMConnectionManagerDelegate>)delegate;

- (void)start;
- (void)stop;
- (void)sendPacket:(id<WLIMPacking>)packet;

@end
