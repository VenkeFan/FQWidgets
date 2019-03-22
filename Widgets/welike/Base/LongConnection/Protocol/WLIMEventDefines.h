//
//  WLIMEventDefines.h
//  TCPSocketClient-Demo
//
//  Created by luxing on 2018/4/28.
//  Copyright © 2018年 Steven. All rights reserved.

//协议包结构
/*    总报文长度(不包含该字段4B)   序号ID    确认包Id       包类型        协议版本号       数据包长度     数据
*    -----------------------------------------------------------------------------------------------
*    |total_length(4byte)|seqId(8byte)|ackId(8byte) |type (2byte)| version(1byte)|length(4byte)|data|
*    -----------------------------------------------------------------------------------------------
*/

#define IMLogTag @"[IM]"

//协议包类型

typedef NS_ENUM(uint16_t, WLEventType)
{
    WLEventConn = 0x0000,      //连接协议包
    WLEventConnAck = 0x0001,   //连接确认包
    WLEventHeartBeat = 0x0002, //连接心跳包
    WLEventSync = 0x0003,      //用户sync
    WLEventSyncAck = 0x0004,   //用户sync_ack
    WLEventFin= 0x0005,        //用户sync_fin
    WLEventFinAck = 0x0006,    //用户sync_fin_ack
    WLEventMsgAck = 0x0007,    //用户发送消息ack
    WLEventNewMsgNotify= 0x0008, //用户有新消息的提醒
    WLEventKickUser = 0x0009,    //connector发出来踢人的消息
    WLEventMsgRead = 0x000A,     //用户已读消息
    WLEventMsgReadAck = 0x000B,  //用户已读消息反馈
    WLEventMsgLogout = 0x000C,  //用户退出登录
    
    WLEventMsgText = 0x0100,    //用户消息协议
    WLEventMsgAudio = 0x0101,
    WLEventMsgVideo = 0x0102,
    WLEventMsgPic = 0x0103,
    WLEventMsgEmotion = 0x0104,
    WLEventMsgNotice = 0x0105,
    WLEventMsgNews = 0x0106,
    WLEventMsgRecall = 0x0107,
    
    WLEventMsgStatusRead = 0x0200, //消息状态协议
    
    WLEventMeetingReq = 0x0300,    //发起视频请求
    WLEventMeetingReqAck = 0x0301, //如果用户不在线 直接发送ack
    WLEventOnlineReq = 0x0302,    // 发起视频请求
    WLEventOnlineReqAck = 0x0303, // 如果用户不在线 直接发送ack
    WLEventBroadcastReq = 0x0304, // 发起直播请求
    WLEventBroadcaseReqAck = 0x0305, // 如果用户不在线 直接发送ack
};
