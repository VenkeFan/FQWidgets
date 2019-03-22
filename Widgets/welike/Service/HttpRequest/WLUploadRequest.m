//
//  WLUploadRequest.m
//  welike
//
//  Created by 刘斌 on 2018/4/19.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUploadRequest.h"
#import "RDBaseRequest.h"
#import "WLAccountManager.h"
#import "NSString+LuuBase.h"
#import "NSDictionary+JSON.h"

#define kUploadPartBoundary       @"00c22d5db935407485cc"

@interface WLUploadRequest ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *objectKey;
@property (nonatomic, copy) NSString *baseUrl;

- (NSData *)blockDataWith:(NSString *)fileName partIdx:(NSInteger)partIdx blockSize:(NSInteger)blockSize;

@end

@implementation WLUploadRequest

- (id)initWithFileName:(NSString *)fileName objectKey:(NSString *)objectKey partNum:(NSInteger)partNum total:(NSInteger)total
{
    self = [super initWithType:AFHttpOperationTypeUpload];
    if (self)
    {
        NSMutableString *baseUrl = [[NSMutableString alloc] init];
        [baseUrl appendFormat:@"%@%@?welikeParams=%@", [AppContext getUploadHostName], @"file/upload", [RDBaseRequest buildBaseParamsBlock]];
        self.contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kUploadPartBoundary];
        WLAccount *account = [[AppContext getInstance].accountManager myAccount];
        if (account != nil)
        {
            [baseUrl appendFormat:@"&token=%@", account.accessToken];
            [self appendHeader:account.uid forKey:@"idtoken"];
        }
        self.baseUrl = [NSString stringWithString:baseUrl];
        self.method = AFHttpOperationMethodPOST;
        self.userInfo = [[NSMutableDictionary alloc] init];
        
        NSMutableData *multipartBody = [NSMutableData data];
        
        NSString *numPair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"partNumber\"\r\n\r\n", kUploadPartBoundary];
        [multipartBody appendData:[numPair dataUsingEncoding:NSUTF8StringEncoding]];
        [multipartBody appendData:[[NSString stringWithFormat:@"%d", (int)partNum] dataUsingEncoding:NSUTF8StringEncoding]];
        [multipartBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *totalPair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"total\"\r\n\r\n", kUploadPartBoundary];
        [multipartBody appendData:[totalPair dataUsingEncoding:NSUTF8StringEncoding]];
        [multipartBody appendData:[[NSString stringWithFormat:@"%d", (int)total] dataUsingEncoding:NSUTF8StringEncoding]];
        [multipartBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *filePair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"file\"; filename=\"%@\";\r\nContent-Type: application/octet-stream\r\n\r\n", kUploadPartBoundary, objectKey];
        [multipartBody appendData:[filePair dataUsingEncoding:NSUTF8StringEncoding]];
        [multipartBody appendData:[self blockDataWith:fileName partIdx:(partNum - 1) blockSize:kUploadBlockSize]];
        [multipartBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kUploadPartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self setBody:multipartBody];
        [self appendHeader:[NSString stringWithFormat:@"%lu",(unsigned long)multipartBody.length] forKey:@"Content-Length"];
    }
    return self;
}

- (void)cancel
{
    self.delegate = nil;
    [super cancel];
}

- (void)upload
{
    __weak typeof(self) weakSelf = self;
    
    self.onFinished = ^(NSData *data) {
        NSData *jsonData = [data copy];
        if ([jsonData length] > 0)
        {
            NSError *error = nil;
            id contentObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                               options:NSJSONReadingMutableLeaves
                                                                 error:&error];
            if (error)
            {
                contentObject = nil;
            }
            if (contentObject)
            {
                id errCodeObj = [contentObject objectForKey:@"code"];
                if (errCodeObj != nil)
                {
                    NSInteger errorCode = [errCodeObj integerValue];
                    id result = [contentObject objectForKey:@"result"];
                    if (errorCode == ERROR_NETWORK_SUCCESS)
                    {
                        if (result != nil)
                        {
                            NSString *url = nil;
                            if ([result isKindOfClass:[NSDictionary class]] == YES)
                            {
                                NSDictionary *resDic = (NSDictionary *)result;
                                url = [[resDic stringForKey:@"url"] convertToHttps];
                            }
                            if ([weakSelf.delegate respondsToSelector:@selector(onUploadSuccessed:)])
                            {
                                [weakSelf.delegate onUploadSuccessed:url];
                            }
                        }
                        else
                        {
                            if ([weakSelf.delegate respondsToSelector:@selector(onUploadFailed:)])
                            {
                                [weakSelf.delegate onUploadFailed:ERROR_NETWORK_RESP_INVALID];
                            }
                        }
                    }
                    else
                    {
                        if ([weakSelf.delegate respondsToSelector:@selector(onUploadFailed:)])
                        {
                            [weakSelf.delegate onUploadFailed:errorCode];
                        }
                    }
                }
                else
                {
                    if ([weakSelf.delegate respondsToSelector:@selector(onUploadFailed:)])
                    {
                        [weakSelf.delegate onUploadFailed:ERROR_NETWORK_RESP_INVALID];
                    }
                }
            }
            else
            {
                if ([weakSelf.delegate respondsToSelector:@selector(onUploadFailed:)])
                {
                    [weakSelf.delegate onUploadFailed:ERROR_NETWORK_UNKNOWN];
                }
            }
        }
    };
    
    self.onError = ^(NSError *error) {
        if ([weakSelf.delegate respondsToSelector:@selector(onUploadFailed:)])
        {
            [weakSelf.delegate onUploadFailed:error.code];
        }
    };
    
    self.onUploadProgress = ^(CGFloat process) {
        if ([weakSelf.delegate respondsToSelector:@selector(onUploadProcess:)])
        {
            [weakSelf.delegate onUploadProcess:process];
        }
    };
    
    self.url = [self.baseUrl copy];
    [super send];
}

- (NSData *)blockDataWith:(NSString *)fileName partIdx:(NSInteger)partIdx blockSize:(NSInteger)blockSize
{
    NSInteger begin = partIdx * blockSize;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fileName];
    [fileHandle seekToFileOffset:begin];
    return [fileHandle readDataOfLength:blockSize];
}

@end
