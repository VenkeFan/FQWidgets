//
//  WLShortUrlRequest.m
//  welike
//
//  Created by fan qi on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLShortUrlRequest.h"

@implementation WLShortUrlRequest

- (instancetype)init {
    return [super initWithType:AFHttpOperationTypeNormal api:@"short/share/link" method:AFHttpOperationMethodGET];
}

- (void)fetchShortUrlWithUrlString:(NSString *)urlString successed:(shortUrlSuccessed)successed error:(failedBlock)error {
    [self.params removeAllObjects];
    
    [self.params setObject:urlString forKey:@"param"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
//            NSString *code = result[@"code"];
            NSString *shareLink = result[@"link"];
            if (shareLink.length > 0) {
                if (successed) {
                    successed(shareLink);
                }
            } else {
                if (error) {
                    error(ERROR_NETWORK_RESP_INVALID);
                }
            }
            
        } else {
            if (error) {
                error(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
