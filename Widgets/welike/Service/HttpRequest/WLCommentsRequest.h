//
//  WLCommentsRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef NS_ENUM(NSInteger, WELIKE_COMMENTS_SORT)
{
    WELIKE_COMMENTS_SORT_CREATED = 1,
    WELIKE_COMMENTS_SORT_HOT
};

typedef void(^listCommentsSuccessed)(NSArray *comments, NSString *cursor);

@interface WLCommentsRequest : RDBaseRequest

- (id)initCommentsRequestWithPid:(NSString *)pid;
- (void)listCommentsWithSort:(WELIKE_COMMENTS_SORT)sort cursor:(NSString *)cursor successed:(listCommentsSuccessed)successed error:(failedBlock)error;

@end
