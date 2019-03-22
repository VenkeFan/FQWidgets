//
//  WLCreatePostRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCreatePostRequest.h"
#import "WLRichContent.h"
#import "WLAccountManager.h"
#import "RDLocation.h"
#import "WLDraft.h"

@implementation WLRequestPostAttachment

- (id)init
{
    self = [super init];
    if (self)
    {
        self.width = 0;
        self.height = 0;
    }
    return self;
}

@end

@implementation WLRequestPostPollAttachment

- (id)init
{
    self = [super init];
    if (self)
    {
        _requestPostAttachment = [[WLRequestPostAttachment alloc] init];
    }
    return self;
}

@end

@implementation WLCreatePostRequest

- (id)initCreatePostRequestWithUid:(NSString *)uid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/contents", uid] method:AFHttpOperationMethodPOST];
}

- (void)createPostWithContent:(WLRichContent *)content location:(RDLocation *)location attachments:(NSArray *)attachments successed:(createPostSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    NSMutableArray *attachmentsJSON = [NSMutableArray arrayWithArray:[content convertRichItemListToJSON]];
    
    NSMutableDictionary *bodyJSON = [NSMutableDictionary dictionary];
    NSMutableDictionary *postJSON = [NSMutableDictionary dictionary];
    if ([content.text length] > 0)
    {
        [postJSON setObject:content.text forKey:@"content"];
    }
    if ([content.summary length] > 0)
    {
        [postJSON setObject:content.summary forKey:@"summary"];
    }
    WLAccountSetting *setting = [[AppContext getInstance].accountManager mySetting];
    if (setting.mobileModel == YES)
    {
        [postJSON setObject:[LuuUtils deviceModel] forKey:@"source"];
    }
    
    if ([attachments count] > 0)
    {
        NSMutableDictionary *additions = [NSMutableDictionary dictionary];
        
        for (NSInteger i = 0; i < [attachments count]; i++)
        {
            if ([attachments[i] isKindOfClass:[WLRequestPostAttachment class]])
            {
                WLRequestPostAttachment *a = [attachments objectAtIndex:i];
                if ([a.targetAttId length] > 0)
                {
                    [additions setObject:a forKey:a.targetAttId];
                }
                
                if ([a.type isEqualToString:ADDITION_THUMB_TYPE] == YES && a.url.length > 0)
                {
                    if (attachmentsJSON.count > 0)
                    {
                          [attachmentsJSON[0] setObject:a.url forKey:@"icon"];
                    }
                }
                
                if (a.targetAttId == nil || [a.targetAttId length] == 0)
                {
                    NSMutableDictionary *item = [NSMutableDictionary dictionary];
                    [item setObject:a.type forKey:@"type"];
                    [item setObject:a.url forKey:@"source"];
                    if ([a.type isEqualToString:ATTACHMENT_PIC_TYPE] == YES)
                    {
                        [item setObject:[NSNumber numberWithInteger:a.width] forKey:@"image-width"];
                        [item setObject:[NSNumber numberWithInteger:a.height] forKey:@"image-height"];
                    }
                    else if ([a.type isEqualToString:ATTACHMENT_VIDEO_TYPE] == YES)
                    {
                        [item setObject:[NSNumber numberWithInteger:a.width] forKey:@"video-width"];
                        [item setObject:[NSNumber numberWithInteger:a.height] forKey:@"video-height"];
                    }
//                    WLRequestPostAttachment *add = [additions objectForKey:a.attId];
//                    if (add != nil && [add.type isEqualToString:ADDITION_THUMB_TYPE] == YES)
//                    {
//                        [item setObject:add.url forKey:@"icon"];
//                    }
                    [attachmentsJSON addObject:item];
                }
            }
            
            
            if ([attachments[i] isKindOfClass:[WLRequestPostPollAttachment class]])
            {
                WLRequestPostPollAttachment *a = [attachments objectAtIndex:i];
                if ([a.requestPostAttachment.targetAttId length] > 0)
                {
                    [additions setObject:a forKey:a.requestPostAttachment.targetAttId];
                }
                
                if (a.requestPostAttachment.targetAttId == nil || [a.requestPostAttachment.targetAttId length] == 0)
                {
                    NSMutableDictionary *item = [NSMutableDictionary dictionary];
                    [item setObject:a.requestPostAttachment.type forKey:@"type"];
                    [item setObject:a.requestPostAttachment.url forKey:@"source"];
                    [item setObject:[NSNumber numberWithInteger:a.requestPostAttachment.width] forKey:@"image-width"];
                    [item setObject:[NSNumber numberWithInteger:a.requestPostAttachment.height] forKey:@"image-height"];
                    [attachmentsJSON addObject:item];
                }
            }
        }
    }
    
    //poll 类型
    if ([attachments[0] isKindOfClass:[WLRequestPostPollAttachment class]] || [attachments[0] isKindOfClass:[WLPollAttachmentDraft class]])
    {
        NSMutableDictionary *pollAdditions = [self createPollAttachmentsJsonWithNoImage:attachments];
        [attachmentsJSON addObject:pollAdditions];
    }
    
    if ([attachmentsJSON count] > 0)
    {
        [postJSON setObject:attachmentsJSON forKey:@"attachments"];
    }
    
    if (location != nil)
    {
        NSMutableDictionary *locJSON = [NSMutableDictionary dictionary];
        [locJSON setObject:location.placeId forKey:@"placeId"];
        [locJSON setObject:location.place forKey:@"placeName"];
        [locJSON setObject:[NSNumber numberWithDouble:location.latitude] forKey:@"lat"];
        [locJSON setObject:[NSNumber numberWithDouble:location.longitude] forKey:@"lon"];
        [postJSON setObject:locJSON forKey:@"location"];
    }
    
    [bodyJSON setObject:postJSON forKey:@"post"];
    NSData *body = [NSJSONSerialization dataWithJSONObject:bodyJSON options:NSJSONWritingPrettyPrinted error:nil];
    if ([body length] > 0)
    {
        [self setBody:body];
    }
    
    self.onSuccessed = ^(id result) {
        if (successed)
        {
            successed([result objectForKey:@"post"]);
        }
    };
    self.onFailed = error;
    [self sendQuery];
}


-(NSMutableDictionary *)createPollAttachmentsJsonWithNoImage:(NSArray *)attachments
{
    NSMutableDictionary *attachmentsJSON = [NSMutableDictionary dictionary];
    NSMutableArray *pollsJSON = [[NSMutableArray alloc] initWithCapacity:0];
    
    long long time = 0;
    
    for (NSInteger i = 0; i < [attachments count]; i++)
    {
        if ([attachments[i] isKindOfClass:[WLPollAttachmentDraft class]])
        {
            WLPollAttachmentDraft *a = [attachments objectAtIndex:i];
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            [item setObject:a.choiceName forKey:@"choiceName"];
            [pollsJSON addObject:item];
            time = a.time;
        }
        if ([attachments[i] isKindOfClass:[WLRequestPostPollAttachment class]])
        {
            WLRequestPostPollAttachment *a = [attachments objectAtIndex:i];
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            [item setObject:a.choiceName forKey:@"choiceName"];
            [item setObject:a.requestPostAttachment.url forKey:@"choiceImageUrl"];
            [pollsJSON addObject:item];
            time = a.time;
        }
    }
    
    NSMutableDictionary *choicesDic = [NSMutableDictionary dictionary];
    [choicesDic setObject:pollsJSON forKey:@"choices"];
    [choicesDic setObject:[NSNumber numberWithLongLong:time*1000] forKey:@"expiredTime"];
    
    [attachmentsJSON setObject:choicesDic forKey:@"poll"];
    [attachmentsJSON setObject:@"POLL" forKey:@"source"];
    [attachmentsJSON setObject:@"POLL" forKey:@"type"];
    
    return attachmentsJSON;
}

@end
