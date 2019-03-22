//
//  WLCheckUploadFileRequest.m
//  welike
//
//  Created by 刘斌 on 2018/4/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCheckUploadFileRequest.h"
#import "WLServiceGlobal.h"

@interface WLCheckUploadFileRequest ()

@end

@implementation WLCheckUploadFileRequest

- (id)initCheckUploadFileRequest
{
    return [super initWithType:AFHttpOperationTypeNormal hostName:[AppContext getUploadHostName] api:@"file/fileinfo" method:AFHttpOperationMethodGET];
}

- (void)checkUploadedFileSizeWithObjectKey:(NSString *)objectKey successed:(checkUploadFileSuccessed)successed error:(failedBlock)error;
{
    [self.params removeAllObjects];
    [self.params setObject:objectKey forKey:@"key"];
    self.onSuccessed = ^(id result) {
        NSInteger offset = [[result objectForKey:@"size"] integerValue];
        if (successed)
        {
            successed(offset);
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
