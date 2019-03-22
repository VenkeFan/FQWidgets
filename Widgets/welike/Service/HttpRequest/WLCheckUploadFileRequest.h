//
//  WLCheckUploadFileRequest.h
//  welike
//
//  Created by 刘斌 on 2018/4/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^checkUploadFileSuccessed)(NSInteger size);

@interface WLCheckUploadFileRequest : RDBaseRequest

- (id)initCheckUploadFileRequest;
- (void)checkUploadedFileSizeWithObjectKey:(NSString *)objectKey successed:(checkUploadFileSuccessed)successed error:(failedBlock)error;

@end
