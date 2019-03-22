//
//  WLIMConnection.h
//  IMTest
//
//  Created by luxing on 2018/5/2.
//  Copyright © 2018年 chiemy. All rights reserved.
//  连接用

#import <Foundation/Foundation.h>
#import "WLIMPacker.h"

typedef NS_ENUM(uint16_t, WLIMConnectionStatus)
{
    WLIMConnectionClosed = 0,
    WLIMConnectionConnecting,
    WLIMConnectionAuthing,
    WLIMConnectionIdle
};

@class WLIMConnection;

@protocol WLIMConnectionDelegate <NSObject>

- (void)didConnected:(WLIMConnection *)connect;
- (void)connect:(WLIMConnection *)connect didReceiveData:(NSData *)data;
- (void)connectTokenInvalid:(WLIMConnection *)connect;
- (void)connect:(WLIMConnection *)connect errCode:(NSInteger)errCode;

@end

@interface WLIMConnection : NSObject

@property (nonatomic, readonly) WLIMConnectionStatus status;
@property (nonatomic, weak) id<WLIMConnectionDelegate> delegate;

- (void)connect;
- (void)authFeedback:(NSInteger)errCode;
- (void)disconnect;
- (void)writePacket:(id<WLIMPacking>)packet;

@end
