//
//  WLIMPicMessage.m
//  IMTest
//
//  Created by luxing on 2018/5/5.
//  Copyright © 2018年 chiemy. All rights reserved.
//

#import "WLIMPicMessage.h"
#import "BibiProtoApplication.pbobjc.h"
#import "WLIMEventDefines.h"

@implementation WLIMPicMessage

- (id)init
{
    self = [super init];
    if (self)
    {
        self.type = WLIMMessageTypePic;
    }
    return self;
}

#pragma mark - WLIMPacking
- (uint16_t)packetType
{
    return WLEventMsgPic;
}

- (NSData *)packetBody
{
    PicMessage *picPacket = [[PicMessage alloc] init];
    picPacket.header = [self messageHeader];
    picPacket.coverUri = self.picUri;
    picPacket.picUri = self.picUri;
    return [picPacket data];
}

+ (WLIMPicMessage *)parseFromBody:(NSData *)body
{
    WLIMPicMessage *m = nil;
    PicMessage *message = [PicMessage parseFromData:body error:nil];
    if (message != nil)
    {
        m = [[WLIMPicMessage alloc] init];
        [m parseMessageHeader:message.header];
        m.picUri = [message.picUri convertToHttps];
    }
    return m;
}

@end
