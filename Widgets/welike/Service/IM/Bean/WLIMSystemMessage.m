//
//  WLIMSystemMessage.m
//  welike
//
//  Created by 刘斌 on 2018/5/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMSystemMessage.h"
#import "BibiProtoApplication.pbobjc.h"
#import "WLIMEventDefines.h"

@implementation WLIMSystemMessage

- (id)init
{
    self = [super init];
    if (self)
    {
        self.type = WLIMMessageTypeSystem;
    }
    return self;
}

#pragma mark - WLIMPacking
- (uint16_t)packetType
{
    return WLEventMsgNotice;
}

- (NSData *)packetBody
{
    return nil;
}

+ (WLIMSystemMessage *)parseFromBody:(NSData *)body
{
    WLIMSystemMessage *m = nil;
    NoticeMessage *message = [NoticeMessage parseFromData:body error:nil];
    if (message != nil && [message.actionsArray count] > 0)
    {
        m = [[WLIMSystemMessage alloc] init];
        [m parseMessageHeader:message.header];
        m.text = [message.actionsArray objectAtIndex:0].text;
    }
    return m;
}

@end
