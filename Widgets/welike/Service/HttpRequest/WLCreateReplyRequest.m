//
//  WLCreateReplyRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCreateReplyRequest.h"
#import "WLRichContent.h"
#import "WLAccountManager.h"

@implementation WLCreateReplyRequest

- (id)initCreateReplyRequestWithUid:(NSString *)uid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/contents", uid] method:AFHttpOperationMethodPOST];
}

- (void)createReplyWithComment:(WLRichContent *)comment cid:(NSString *)cid forwardPostContent:(WLRichContent *)post forwardPid:(NSString *)forwardPid successed:(createReplySuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    NSArray *richTextAttachmentsJSON = [comment convertRichItemListToJSON];
    
    NSMutableDictionary *bodyJSON = [NSMutableDictionary dictionary];
    NSMutableDictionary *replyJSON = [NSMutableDictionary dictionary];
    [replyJSON setObject:cid forKey:@"comment"];
    if ([comment.text length] > 0)
    {
        [replyJSON setObject:comment.text forKey:@"content"];
        if ([richTextAttachmentsJSON count] > 0)
        {
            [replyJSON setObject:richTextAttachmentsJSON forKey:@"attachments"];
        }
    }
    
    NSMutableDictionary *postJSON = nil;
    if ([post.text length] > 0)
    {
        postJSON = [NSMutableDictionary dictionary];
        [postJSON setObject:forwardPid forKey:@"forwardPost"];
        [postJSON setObject:post.text forKey:@"content"];
        [postJSON setObject:post.summary forKey:@"summary"];
        WLAccountSetting *setting = [[AppContext getInstance].accountManager mySetting];
        if (setting.mobileModel == YES)
        {
            [postJSON setObject:[LuuUtils deviceModel] forKey:@"source"];
        }
        NSArray *richTextAttachmentsPostJSON = [post convertRichItemListToJSON];
        if ([richTextAttachmentsPostJSON count] > 0)
        {
            [postJSON setObject:richTextAttachmentsPostJSON forKey:@"attachments"];
        }
    }
    
    [bodyJSON setObject:replyJSON forKey:@"reply"];
    if (postJSON != nil)
    {
        [bodyJSON setObject:postJSON forKey:@"post"];
    }

    NSData *body = [NSJSONSerialization dataWithJSONObject:bodyJSON options:NSJSONWritingPrettyPrinted error:nil];
    if ([body length] > 0)
    {
        [self setBody:body];
    }
    
    self.onSuccessed = ^(id result) {
        if (successed)
        {
            if ([result isKindOfClass:[NSDictionary class]])
            {
                successed(result);
            }
            else
            {
                successed(nil);
            }
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
