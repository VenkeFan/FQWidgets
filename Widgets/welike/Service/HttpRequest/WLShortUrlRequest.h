//
//  WLShortUrlRequest.h
//  welike
//
//  Created by fan qi on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^shortUrlSuccessed)(NSString *urlString);

@interface WLShortUrlRequest : RDBaseRequest

- (void)fetchShortUrlWithUrlString:(NSString *)urlString successed:(shortUrlSuccessed)successed error:(failedBlock)error;

@end
