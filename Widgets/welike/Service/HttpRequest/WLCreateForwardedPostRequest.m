//
//  WLCreateForwardedPostRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCreateForwardedPostRequest.h"
#import "WLRichContent.h"
#import "WLAccountManager.h"

@implementation WLCreateForwardedPostRequest

- (id)initCreateForwardedPostRequestWithUid:(NSString *)uid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/contents", uid] method:AFHttpOperationMethodPOST];
}

- (void)createForwardedPostWithContent:(WLRichContent *)content pid:(NSString *)pid commentContent:(NSString *)comment successed:(createForwardedPostSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    NSArray *attachmentsJSON = [content convertRichItemListToJSON];
    NSArray *richTextAttachmentsJSON = [content convertRichItemListToJSON];
    
    NSMutableDictionary *bodyJSON = [NSMutableDictionary dictionary];
    NSMutableDictionary *postJSON = [NSMutableDictionary dictionary];
    [postJSON setObject:pid forKey:@"forwardPost"];
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
    
    if ([attachmentsJSON count] > 0)
    {
        [postJSON setObject:attachmentsJSON forKey:@"attachments"];
    }
    
    NSMutableDictionary *commentJSON = nil;
    if ([comment length] > 0)
    {
        commentJSON = [NSMutableDictionary dictionary];
        [commentJSON setObject:pid forKey:@"post"];
        [commentJSON setObject:comment forKey:@"content"];
        if ([richTextAttachmentsJSON count] > 0)
        {
            [commentJSON setObject:richTextAttachmentsJSON forKey:@"attachments"];
        }
    }
    
    [bodyJSON setObject:postJSON forKey:@"post"];
    if (commentJSON != nil)
    {
        [bodyJSON setObject:commentJSON forKey:@"comment"];
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
