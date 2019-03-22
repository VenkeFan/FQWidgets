//
//  WLIMDataHandler.m
//  welike
//
//  Created by 刘斌 on 2018/5/19.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMDataHandler.h"
#import "WLIMPacker.h"
#import "BibiProtoApplication.pbobjc.h"
#import "WLIMEventDefines.h"

@implementation WLIMDataHandler

- (void)handleReceivedData:(NSArray *)dataList
{
    if ([dataList count] == 0) return;
    
    BOOL last = YES;
    BOOL needSync = NO;
    BOOL hasNotifications = NO;
    long long lv = -1;
    NSMutableArray<SyncDataPacket_DataEntry*> *entries = [NSMutableArray array];
    for (WLIMPacker *packer in dataList)
    {
        if (packer.header.type == WLEventNewMsgNotify)//服务端有新消息时候,通知客户端,客户端再去拉
        {
            NewMessageNotify *newMessageNotify = [NewMessageNotify parseFromData:packer.body error:nil];
            if (newMessageNotify != nil && [newMessageNotify.classifiedArray count] > 0)
            {
                for (NSInteger i = 0; i < [newMessageNotify.classifiedArray count]; i++)
                {
                    MessageClassified cc = [newMessageNotify.classifiedArray valueAtIndex:i];
                    if (cc == MessageClassified_P2P)
                    {
                        needSync = YES;
                    }
                    else if (cc == MessageClassified_All)
                    {
                        needSync = YES;
                    }
                    else if (cc == MessageClassified_News)
                    {
                        hasNotifications = YES;
                    }
                }
            }
        }
        else if (packer.header.type == WLEventSyncAck)//启动时和有新消息时候,去主动向服务端同步,服务端返回的数据
        {
            SyncDataPacket *syncPacket = [SyncDataPacket parseFromData:packer.body error:nil];
            if (syncPacket != nil && [syncPacket.syncMarksArray count] > 0)
            {
                for (NSInteger i = 0; i < [syncPacket.syncMarksArray count]; i++)
                {
                    SyncDataPacket_SyncMark *syncMark = [syncPacket.syncMarksArray objectAtIndex:i];
                    long long l = syncMark.lastVersion;
                    if (lv < l)
                    {
                        lv = l;
                    }
                }
            }
            if (syncPacket != nil && [syncPacket.dataArray count] > 0)
            {
                [entries addObjectsFromArray:syncPacket.dataArray];
            }
            
            if (syncPacket != nil)
            {
                if (syncPacket.hasMore == YES)
                {
                    last = NO;
                    needSync = YES;
                }
            }
        }
        else if (packer.header.type == WLEventMsgAck)//发给其他用户消息后的响应数据
        {
            MessageArrivalAck *msgArrAck = [MessageArrivalAck parseFromData:packer.body error:nil];
            if (msgArrAck != nil && msgArrAck.header != nil)
            {
                NSString *mid = msgArrAck.header.messageId;
                if ([mid length] > 0)
                {
                    if (msgArrAck.code == 11200)
                    {
                        if ([self.delegate respondsToSelector:@selector(dataHandlerSendResult:errCode:)])
                        {
                            [self.delegate dataHandlerSendResult:mid errCode:ERROR_SUCCESS];
                        }
                    }
                    else
                    {
                        if ([self.delegate respondsToSelector:@selector(dataHandlerSendResult:errCode:)])
                        {
                            [self.delegate dataHandlerSendResult:mid errCode:ERROR_IM_SEND_MSG_REFUSE];
                        }
                    }
                }
            }
        }
    }
    
    if (hasNotifications == YES)
    {
        if ([self.delegate respondsToSelector:@selector(dataHandlerNewNotifications)])
        {
            [self.delegate dataHandlerNewNotifications];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(dataHandlerCompleted:lv:needSync:last:)])
    {
        [self.delegate dataHandlerCompleted:entries lv:lv needSync:needSync last:last];
    }
}

@end
