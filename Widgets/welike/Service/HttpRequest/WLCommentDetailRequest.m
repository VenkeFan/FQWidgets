//
//  WLCommentDetailRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCommentDetailRequest.h"
#import "WLComment.h"
#import "NSDictionary+JSON.h"

@implementation WLCommentDetailRequest

- (id)initCommentDetailRequestWithCid:(NSString *)cid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/comment/%@/replies", cid] method:AFHttpOperationMethodGET];
}

- (void)listRepliesWithCursor:(NSString *)cursor successed:(listRepliesSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    [self.params setObject:[NSNumber numberWithInteger:COMMENTS_NUM_ONE_PAGE] forKey:@"count"];
    if ([cursor length] > 0)
    {
        [self.params setObject:cursor forKey:@"cursor"];
    }
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSMutableArray *comments = nil;
            NSDictionary *resDic = (NSDictionary *)result;
            id commentsObj = [resDic objectForKey:@"list"];
            if ([commentsObj isKindOfClass:[NSArray class]] == YES)
            {
                NSArray *commentsJSON = (NSArray *)commentsObj;
                comments = [NSMutableArray arrayWithCapacity:[commentsJSON count]];
                for (NSInteger i = 0; i < [commentsJSON count]; i++)
                {
                    WLComment *comment = [WLComment parseFromNetworkJSON:[commentsJSON objectAtIndex:i]];
                    [comments addObject:comment];
                }
            }
            NSString *cursor = [resDic stringForKey:@"cursor"];
            if (successed)
            {
                successed(comments, cursor);
            }
        }
        else
        {
            if (error)
            {
                error(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
