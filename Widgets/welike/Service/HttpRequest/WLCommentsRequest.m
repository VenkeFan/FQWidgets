//
//  WLCommentsRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCommentsRequest.h"
#import "WLComment.h"
#import "NSDictionary+JSON.h"
#import "WLAccountManager.h"

@implementation WLCommentsRequest

- (id)initCommentsRequestWithPid:(NSString *)pid
{
    if ([[[AppContext getInstance] accountManager] isLogin])
    {
          return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/post/%@/comments", pid] method:AFHttpOperationMethodGET];
    }
    else
    {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/post/h5/%@/comments", pid] method:AFHttpOperationMethodGET];
    }
}

- (void)listCommentsWithSort:(WELIKE_COMMENTS_SORT)sort cursor:(NSString *)cursor successed:(listCommentsSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    [self.params setObject:[NSNumber numberWithInteger:COMMENTS_NUM_ONE_PAGE] forKey:@"count"];
    if (sort == WELIKE_COMMENTS_SORT_HOT)
    {
        [self.params setObject:@"hot" forKey:@"order"];
    }
    else
    {
        [self.params setObject:@"created" forKey:@"order"];
    }
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
