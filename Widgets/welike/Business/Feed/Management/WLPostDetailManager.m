//
//  WLPostDetailManager.m
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPostDetailManager.h"
#import "WLPostDetailRequest.h"
#import "WLFeedLayout.h"

@implementation WLPostDetailManager

- (void)reqPostDetailWithPid:(NSString *)pid successed:(postDetailSuccessed)successed error:(postDetailError)error
{
    WLPostDetailRequest *request = [[WLPostDetailRequest alloc] initPostDetailRequestWithPid:pid];
    [request detailForSuccessed:^(WLPostBase *post) {
        if (successed)
        {
            WLFeedLayout *layout = [WLFeedLayout layoutWithFeedModel:post layoutType:WLFeedLayoutType_FeedDetail];
            
            successed(layout);
        }
    } error:^(NSInteger errorCode) {
        if (error)
        {
            error(errorCode);
        }
    }];
}

@end
