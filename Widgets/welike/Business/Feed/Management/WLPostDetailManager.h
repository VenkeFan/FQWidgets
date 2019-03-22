//
//  WLPostDetailManager.h
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLPostBase.h"

@class WLFeedLayout;

typedef void(^postDetailSuccessed) (WLFeedLayout *postLayout);
typedef void(^postDetailError) (NSInteger errCode);

@interface WLPostDetailManager : NSObject

- (void)reqPostDetailWithPid:(NSString *)pid successed:(postDetailSuccessed)successed error:(postDetailError)error;

@end
