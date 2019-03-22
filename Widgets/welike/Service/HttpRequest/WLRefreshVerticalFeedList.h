//
//  WLRefreshVerticalFeedList.h
//  welike
//
//  Created by gyb on 2018/7/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^RefreshVerticalSuccessed)(void);

@interface WLRefreshVerticalFeedList : RDBaseRequest

- (instancetype)init;

- (void)RefreshVerticalFeedList:(RefreshVerticalSuccessed)successed error:(failedBlock)error;

@end
