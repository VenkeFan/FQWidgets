//
//  WLSuperLikeRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/18.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@interface WLSuperLikeRequest : RDBaseRequest

- (id)initSuperLikeRequestWithUid:(NSString *)uid pid:(NSString *)pid exp:(long long)exp;
- (void)like;

@end
