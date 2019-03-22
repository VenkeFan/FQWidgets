//
//  WLCreateForwardedPostRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLRichContent;

typedef void(^createForwardedPostSuccessed)(NSDictionary *dic);

@interface WLCreateForwardedPostRequest : RDBaseRequest

- (id)initCreateForwardedPostRequestWithUid:(NSString *)uid;
- (void)createForwardedPostWithContent:(WLRichContent *)content pid:(NSString *)pid commentContent:(NSString *)comment successed:(createForwardedPostSuccessed)successed error:(failedBlock)error;

@end
