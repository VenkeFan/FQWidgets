//
//  WLTrackRequest.h
//  welike
//
//  Created by 刘斌 on 2018/6/6.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^trackSuccessed)(void);

@interface WLTrackRequest : RDBaseRequest

- (id)initTrackRequest;
- (void)sendTracks:(NSArray *)tracks successed:(trackSuccessed)successed error:(failedBlock)error;

@end
