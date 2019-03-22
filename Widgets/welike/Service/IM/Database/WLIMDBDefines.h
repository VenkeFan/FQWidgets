//
//  WLIMDBDefines.h
//  welike
//
//  Created by luxing on 2018/5/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#define WLPrivateMessageTableName @"s_message"
#define WLSessionTableName @"session"
#define WLGroupMessageTableNamePrefix @"g_message_"

typedef NS_ENUM(NSInteger, WLIMMessageStatus)
{
    WLIMMessageStatusSending = 1,
    WLIMMessageStatusSent = 2,
    WLIMMessageStatusSendFailed = 3,
    WLIMMessageStatusReceived = 4
};

typedef NS_ENUM(NSInteger, WLIMMessageType)
{
    WLIMMessageTypeUnknown = 0,
    WLIMMessageTypeTxt = 1,
    WLIMMessageTypePic = 2,
    WLIMMessageTypeAudio = 3,
    WLIMMessageTypeVideo = 4,
    WLIMMessageTypeSystem = 5
};

typedef NS_ENUM(NSInteger, WLIMSessionType)
{
    WLIMSessionTypeUnknown = 0,
    WLIMSessionTypeP2P = 1,
    WLIMSessionTypeGroup = 2,
    WLIMSessionTypeStranger = 3
};

#define IM_MESSAGE_COL_MID                     @"mid"
#define IM_MESSAGE_COL_SID                     @"sid"
#define IM_MESSAGE_COL_SESSION_NAME            @"session_name"
#define IM_MESSAGE_COL_SESSION_HEAD            @"session_head"
#define IM_MESSAGE_COL_SENDER_UID              @"sender_uid"
#define IM_MESSAGE_COL_SENDER_NAME             @"sender_name"
#define IM_MESSAGE_COL_SENDER_HEAD             @"sender_head"
#define IM_MESSAGE_COL_SESSION_TYPE            @"session_type"
#define IM_MESSAGE_COL_STATUS                  @"status"
#define IM_MESSAGE_COL_TIME                    @"time"
#define IM_MESSAGE_COL_TYPE                    @"type"
#define IM_MESSAGE_COL_TEXT                    @"text"
#define IM_MESSAGE_COL_PIC                     @"pic"
#define IM_MESSAGE_COL_AUDIO                   @"audio"
#define IM_MESSAGE_COL_THUMB                   @"thumb"
#define IM_MESSAGE_COL_VIDEO                   @"video"
#define IM_MESSAGE_COL_FILE_NAME               @"file_name"
#define IM_MESSAGE_COL_EXTRA                   @"extra"

#define IM_SESSION_COL_SID                     @"sid"
#define IM_SESSION_COL_SESSION_NAME            @"session_name"
#define IM_SESSION_COL_SESSION_HEAD            @"session_head"
#define IM_SESSION_COL_MSG_TYPE                @"msg_type"
#define IM_SESSION_COL_ENABLE_CHAT             @"enable_chat"
#define IM_SESSION_COL_VISABLE_CHAT            @"visable_chat"
#define IM_SESSION_COL_GREET                   @"greet"
#define IM_SESSION_COL_TYPE                    @"type"
#define IM_SESSION_COL_TIME                    @"time"
#define IM_SESSION_COL_UNREAD_COUNT            @"unread_count"
#define IM_SESSION_COL_CONTENT                 @"content"
#define IM_SESSION_COL_EXTRA                   @"extra"
