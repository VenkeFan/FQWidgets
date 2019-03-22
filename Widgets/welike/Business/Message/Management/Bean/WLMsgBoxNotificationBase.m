//
//  WLMsgBoxNotificationBase.m
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMsgBoxNotificationBase.h"
#import "WLMsgBoxMentionNotification.h"
#import "WLMsgBoxForwardPostNotification.h"
#import "WLMsgBoxCommentNotification.h"
#import "WLMsgBoxReplyNotification.h"
#import "WLMsgBoxLikePostNotification.h"
#import "WLMsgBoxLikeCommentNotification.h"
#import "WLMsgBoxLikeReplyNotification.h"
#import "WLUser.h"
#import "NSDictionary+JSON.h"

@interface WLMsgBoxNotificationBase ()

+ (WLPostBase *)parsePostForCommentJSON:(NSDictionary *)json;
+ (WLPostBase *)parsePostForReplyJSON:(NSDictionary *)json;

@end

@implementation WLMsgBoxNotificationBase

+ (WLMsgBoxNotificationBase *)parseFromNetworkJSON:(NSDictionary *)json
{
    WLMsgBoxNotificationBase *notification = nil;
    
    NSString *action = [json stringForKey:@"action"];
    if ([action isEqualToString:MSG_BOX_MENTION_FORWARD_ACTION] == YES)
    {
        WLMsgBoxForwardPostNotification *forwardPostNotification = [[WLMsgBoxForwardPostNotification alloc] init];
        NSDictionary *postJSON = [json objectForKey:@"content"];
        forwardPostNotification.parentPost = [WLPostBase parseFromNetworkJSON:postJSON];
        notification = forwardPostNotification;
    }
    else if ([action isEqualToString:MSG_BOX_MENTION_POST_ACTION] == YES)
    {
        WLMsgBoxMentionNotification *mentionNotification = [[WLMsgBoxMentionNotification alloc] init];
        mentionNotification.parentType = WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE_POST;
        NSDictionary *postJSON = [json objectForKey:@"content"];
        mentionNotification.parentPost = [WLPostBase parseFromNetworkJSON:postJSON];
        notification = mentionNotification;
    }
    else if ([action isEqualToString:MSG_BOX_MENTION_COMMENT_ACTION] == YES)
    {
        WLMsgBoxMentionNotification *mentionNotification = [[WLMsgBoxMentionNotification alloc] init];
        mentionNotification.parentType = WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE_COMMENT;
        NSDictionary *commentJSON = [json objectForKey:@"content"];
        mentionNotification.parentPost = [WLMsgBoxNotificationBase parsePostForCommentJSON:commentJSON];
        mentionNotification.comment = [WLComment parseFromNetworkJSON:commentJSON];
        notification = mentionNotification;
    }
    else if ([action isEqualToString:MSG_BOX_MENTION_REPLY_ACTION] == YES)
    {
        WLMsgBoxMentionNotification *mentionNotification = [[WLMsgBoxMentionNotification alloc] init];
        mentionNotification.parentType = WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE_REPLY;
        NSDictionary *replyJSON = [json objectForKey:@"content"];
        mentionNotification.parentPost = [WLMsgBoxNotificationBase parsePostForReplyJSON:replyJSON];
        mentionNotification.reply = [WLComment parseFromNetworkJSON:replyJSON];
        notification = mentionNotification;
    }
    else if ([action isEqualToString:MSG_BOX_COMMENT_COMMENT_ACTION] == YES)
    {
        WLMsgBoxCommentNotification *commentNotification = [[WLMsgBoxCommentNotification alloc] init];
        NSDictionary *commentJSON = [json objectForKey:@"content"];
        commentNotification.parentPost = [WLMsgBoxNotificationBase parsePostForCommentJSON:commentJSON];
        commentNotification.comment = [WLComment parseFromNetworkJSON:commentJSON];
        notification = commentNotification;
    }
    else if ([action isEqualToString:MSG_BOX_COMMENT_REPLY_ACTION] == YES)
    {
        WLMsgBoxReplyNotification *replyNotification = [[WLMsgBoxReplyNotification alloc] init];
        NSDictionary *replyJSON = [json objectForKey:@"content"];
        replyNotification.parentPost = [WLMsgBoxNotificationBase parsePostForReplyJSON:replyJSON];
        replyNotification.reply = [WLComment parseFromNetworkJSON:replyJSON];
        notification = replyNotification;
    }
    else if ([action isEqualToString:MSG_BOX_LIKE_POST_ACTION] == YES)
    {
        WLMsgBoxLikePostNotification *likePostNotification = [[WLMsgBoxLikePostNotification alloc] init];
        NSDictionary *postJSON = [json objectForKey:@"content"];
        likePostNotification.parentPost = [WLPostBase parseFromNetworkJSON:postJSON];
        likePostNotification.superLikeExp = [json longLongForKey:@"exp" def:0];
        notification = likePostNotification;
    }
    else if ([action isEqualToString:MSG_BOX_LIKE_COMMENT_ACTION] == YES)
    {
        WLMsgBoxLikeCommentNotification *likeCommentNotification = [[WLMsgBoxLikeCommentNotification alloc] init];
        NSDictionary *commentJSON = [json objectForKey:@"content"];
        likeCommentNotification.parentPost = [WLMsgBoxNotificationBase parsePostForCommentJSON:commentJSON];
        likeCommentNotification.comment = [WLComment parseFromNetworkJSON:commentJSON];
        notification = likeCommentNotification;
    }
    else if ([action isEqualToString:MSG_BOX_LIKE_REPLY_ACTION] == YES)
    {
        WLMsgBoxLikeReplyNotification *likeReplyNotification = [[WLMsgBoxLikeReplyNotification alloc] init];
        NSDictionary *replyJSON = [json objectForKey:@"content"];
        likeReplyNotification.parentPost = [WLMsgBoxNotificationBase parsePostForReplyJSON:replyJSON];
        likeReplyNotification.reply = [WLComment parseFromNetworkJSON:replyJSON];
        notification = likeReplyNotification;
    }
    
    if (notification != nil)
    {
        notification.nid = [json stringForKey:@"id"];
        notification.time = [json longLongForKey:@"created" def:0];
        WLUser *source = [WLUser parseFromNetworkJSON:[json objectForKey:@"source"]];
        notification.sourceUid = source.uid;
        notification.sourceNickName = source.nickName;
        notification.sourceHead = source.headUrl;
        notification.vip = source.vip;
    }
    
    return notification;
}

+ (WLPostBase *)parsePostForCommentJSON:(NSDictionary *)json
{
    NSDictionary *postJSON = [json objectForKey:@"post"];
    return [WLPostBase parseFromNetworkJSON:postJSON];
}

+ (WLPostBase *)parsePostForReplyJSON:(NSDictionary *)json
{
    NSDictionary *commentJSON = [json objectForKey:@"comment"];
    NSDictionary *postJSON = [commentJSON objectForKey:@"post"];
    return [WLPostBase parseFromNetworkJSON:postJSON];
}

@end
