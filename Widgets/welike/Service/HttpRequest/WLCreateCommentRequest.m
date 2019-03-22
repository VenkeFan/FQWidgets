//
//  WLCreateCommentRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCreateCommentRequest.h"
#import "WLRichContent.h"
#import "WLAccountManager.h"

@implementation WLCreateCommentRequest

- (id)initCreateCommentRequestWithUid:(NSString *)uid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/contents", uid] method:AFHttpOperationMethodPOST];
}

- (void)createCommentWithPid:(NSString *)pid commentContent:(WLRichContent *)commentContent postContent:(WLRichContent *)postContent successed:(createCommentSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    NSMutableDictionary *bodyJSON = [NSMutableDictionary dictionary];
    NSMutableDictionary *commentJSON = [NSMutableDictionary dictionary];
    [commentJSON setObject:pid forKey:@"post"];
    if ([commentContent.text length] > 0)
    {
        [commentJSON setObject:commentContent.text forKey:@"content"];
        NSArray *richTextAttachmentsJSON = [commentContent convertRichItemListToJSON];
        if ([richTextAttachmentsJSON count] > 0)
        {
            [commentJSON setObject:richTextAttachmentsJSON forKey:@"attachments"];
        }
    }
    NSMutableDictionary *postJSON = nil;
    if ([postContent.text length] > 0)
    {
        postJSON = [NSMutableDictionary dictionary];
        [postJSON setObject:pid forKey:@"forwardPost"];
        [postJSON setObject:postContent.text forKey:@"content"];
        [postJSON setObject:postContent.summary forKey:@"summary"];
        WLAccountSetting *setting = [[AppContext getInstance].accountManager mySetting];
        if (setting.mobileModel == YES)
        {
            [postJSON setObject:[LuuUtils deviceModel] forKey:@"source"];
        }
        NSArray *richTextAttachmentsJSON = [postContent convertRichItemListToJSON];
        if ([richTextAttachmentsJSON count] > 0)
        {
            [postJSON setObject:richTextAttachmentsJSON forKey:@"attachments"];
        }
    }
    
    [bodyJSON setObject:commentJSON forKey:@"comment"];
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
