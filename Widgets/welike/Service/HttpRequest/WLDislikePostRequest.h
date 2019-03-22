//
//  WLDislikePostRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/18.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@interface WLDislikePostRequest : RDBaseRequest

- (id)initDislikeRequestWithUid:(NSString *)uid pid:(NSString *)pid;
- (void)dislike;

@end
