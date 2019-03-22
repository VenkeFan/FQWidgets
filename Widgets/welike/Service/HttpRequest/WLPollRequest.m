//
//  WLPollRequest.m
//  welike
//
//  Created by fan qi on 2018/10/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPollRequest.h"
#import "WLPollPost.h"

@implementation WLPollRequest

- (instancetype)initWithUserID:(NSString *)userID {
    return [super initWithType:AFHttpOperationTypeNormal
                           api:[NSString stringWithFormat:@"feed/user/%@/vote", [AppContext getInstance].accountManager.myAccount.uid]
                        method:AFHttpOperationMethodPOST];
}

- (void)postVoteWithPollModel:(WLPollPost *)pollModel
                  choiceArray:(NSArray<WLVoteModel *> *)choiceArray
                     isRepost:(BOOL)isRepost
                    successed:(pollSuccessed)successed
                        error:(failedBlock)error {
    [self.params removeAllObjects];
    
    NSMutableDictionary *bodyJSON = [NSMutableDictionary dictionary];
    
    {
        NSMutableDictionary *pollJson = [NSMutableDictionary dictionary];
        [pollJson setObject:pollModel.pollID forKey:@"id"];
        
        NSMutableArray *choiceIDs = [NSMutableArray arrayWithCapacity:choiceArray.count];
        [choiceArray enumerateObjectsUsingBlock:^(WLVoteModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [choiceIDs addObject:obj.voteID];
        }];
        [pollJson setObject:choiceIDs forKey:@"choices"];
        
        [bodyJSON setObject:pollJson forKey:@"poll"];
    }
    
    if (isRepost)
    {
        WLAccountSetting *setting = [[AppContext getInstance].accountManager mySetting];
        
        NSMutableDictionary *commentJSON = [NSMutableDictionary dictionary];
        [commentJSON setObject:pollModel.pid forKey:@"post"];
        NSString *content = [NSString stringWithFormat:[AppContext getStringForKey:@"poll_comment_default_content" fileName:@"feed"], choiceArray.firstObject.name];
        [commentJSON setObject:content forKey:@"content"];
        if (setting.mobileModel)
        {
            [commentJSON setObject:[LuuUtils deviceModel] forKey:@"source"];
        }
        [bodyJSON setObject:commentJSON forKey:@"comment"];
        
        NSMutableDictionary *postJSON = [NSMutableDictionary dictionary];
        [postJSON setObject:pollModel.pid forKey:@"forwardPost"];
        [postJSON setObject:content forKey:@"content"];
        [postJSON setObject:content forKey:@"summary"];
        if (setting.mobileModel)
        {
            [postJSON setObject:[LuuUtils deviceModel] forKey:@"source"];
        }
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
                WLPollPost *pollModel = [WLPollPost modelWithDic:result];
                if (successed)
                {
                    successed(pollModel);
                }
            }
            else
            {
                if (error)
                {
                    error(ERROR_NETWORK_RESP_INVALID);
                }
            }
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
