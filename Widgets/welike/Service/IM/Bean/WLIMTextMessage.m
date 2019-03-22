//
//  WLIMTextMessage.m
//  IMTest
//
//  Created by luxing on 2018/5/5.
//  Copyright © 2018年 chiemy. All rights reserved.
//

#import "WLIMTextMessage.h"
#import "BibiProtoApplication.pbobjc.h"
#import "WLIMEventDefines.h"

@implementation WLIMTextMessage

- (id)init
{
    self = [super init];
    if (self)
    {
        self.type = WLIMMessageTypeTxt;
    }
    return self;
}

#pragma mark - WLIMPacking
- (uint16_t)packetType
{
    return WLEventMsgText;
}

- (NSData *)packetBody
{
    TextMessage *textPacket = [[TextMessage alloc] init];
    textPacket.header = [self messageHeader];
    textPacket.text = self.text;
    return [textPacket data];
}

+ (WLIMTextMessage *)parseFromBody:(NSData *)body
{
    WLIMTextMessage *m = nil;
    TextMessage *message = [TextMessage parseFromData:body error:nil];
    if (message != nil)
    {
        m = [[WLIMTextMessage alloc] init];
        [m parseMessageHeader:message.header];
        m.text = message.text;
    }
    return m;
}

@end
