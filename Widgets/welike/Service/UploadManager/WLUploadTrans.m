//
//  WLUploadTrans.m
//  welike
//
//  Created by 刘斌 on 2018/4/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUploadTrans.h"
#import "WLUploadRequest.h"
#import "WLCheckUploadFileRequest.h"
#import <AliyunOSSiOS/OSSService.h>
#import "WLUploadManager.h"

@interface WLUploadTrans () <WLUploadRequestDelegate>

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *objectKey;
@property (nonatomic, copy) NSString *sign;
@property (nonatomic, assign) BOOL isResume;
@property (nonatomic, assign) NSInteger currentNum;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger fileSize;
@property (nonatomic, assign) NSInteger lastBlockSize;
@property (nonatomic, strong) WLUploadRequest *uploadRequest;
@property (nonatomic, strong) WLCheckUploadFileRequest *checkUploadFileRequest;

@property (nonatomic, assign) BOOL isUseExceptionOss;//有两种上传方式,若阿里云oss使用异常则使用中转后上传的方式

//阿里云上传
@property (nonatomic, strong) OSSPutObjectRequest *normalUploadRequest;
//@property (nonatomic, strong) OSSClient *defaultClient;


- (void)startUpload;

@end

@implementation WLUploadTrans

- (id)initWithFileName:(NSString *)fileName objectKey:(NSString *)objectKey sign:(NSString *)sign resume:(BOOL)resume
{
    self = [super init];
    if (self)
    {
        self.objectKey = objectKey;
        self.fileName = fileName;
        self.sign = sign;
        self.currentNum = 1;
        self.fileSize = (NSInteger)[[[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil] fileSize];
        self.isResume = resume;
        if (self.fileSize < kUploadBlockSize)
        {
            self.total = 1;
        }
        else
        {
            NSInteger c1 = self.fileSize / kUploadBlockSize;
            NSInteger c2 = self.fileSize % kUploadBlockSize;
            _lastBlockSize = c2;
            if (c2 != 0)
            {
                c1 += 1;
            }
            self.total = c1;
        }
    }
    return self;
}

#pragma mark WLUploadTrans public methods
- (void)start
{
    [self startUpload];
}

- (void)resume
{
    __weak typeof(self) weakSelf = self;
    self.checkUploadFileRequest = [[WLCheckUploadFileRequest alloc] initCheckUploadFileRequest];
    [self.checkUploadFileRequest checkUploadedFileSizeWithObjectKey:self.objectKey successed:^(NSInteger size) {
        weakSelf.checkUploadFileRequest = nil;
        if (size <= kUploadBlockSize)
        {
            weakSelf.currentNum = 1;
        }
        else
        {
            weakSelf.currentNum = size / kUploadBlockSize + 1;
        }
        [weakSelf startUpload];
    } error:^(NSInteger errorCode) {
        weakSelf.checkUploadFileRequest = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onUploadTrans:failed:)])
        {
            [weakSelf.delegate onUploadTrans:weakSelf failed:errorCode];
        }
    }];
}

- (void)stop
{
    self.delegate = nil;
    if (self.checkUploadFileRequest != nil)
    {
        [self.checkUploadFileRequest cancel];
        self.checkUploadFileRequest = nil;
    }
    if (self.uploadRequest != nil)
    {
        [self.uploadRequest cancel];
        self.uploadRequest = nil;
    }
}

#pragma mark UploadTrans private methods
- (void)startUpload
{
    if (_isUseExceptionOss)
    {
        //中转后其他上传
        [self originalUpload];
    }
    else
    {
        //阿里云上传
        [self aliOssUpload];
    }
}

-(void)originalUpload
{
    self.uploadRequest = [[WLUploadRequest alloc] initWithFileName:self.fileName objectKey:self.objectKey partNum:self.currentNum total:self.total];
    self.uploadRequest.delegate = self;
    [self.uploadRequest upload];
}

-(void)aliOssUpload
{
     __weak typeof(self) weakSelf = self;
    
    //开始上传
    _normalUploadRequest = [OSSPutObjectRequest new];
    _normalUploadRequest.bucketName = [AppContext getAliBucket];
    _normalUploadRequest.objectKey = self.objectKey;
    _normalUploadRequest.uploadingFileURL = [NSURL fileURLWithPath:self.fileName];
    _normalUploadRequest.isAuthenticationRequired = YES;
    _normalUploadRequest.contentType = @"application/octet-stream";
    _normalUploadRequest.objectMeta = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"public-read",@"x-oss-object-acl",
                                        @"true",@"mts",nil];
    
    _normalUploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {

        float progress = 1.f * totalByteSent / totalBytesExpectedToSend;
        NSLog(@"上传进度======%f",progress);
        [weakSelf uploadProgress:progress];
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSTask * task = [[AppContext getInstance].uploadManager.defaultClient putObject:weakSelf.normalUploadRequest];
        [task continueWithBlock:^id(OSSTask *task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (task.error) {
                    //failure(task.error);
                    
                    if ([task.error.domain isEqualToString:OSSServerErrorDomain])
                    {
                        //阿里云服务器u异常,切换其他服务器
                        weakSelf.isUseExceptionOss = YES;
                        NSLog(@"=====ali upload error exception");
                    }
                    else
                    {
                         weakSelf.isUseExceptionOss = NO;
                         NSLog(@"=====aali upload error");
                    }
                    
                    if ([self.delegate respondsToSelector:@selector(onUploadTrans:failed:)])
                    {
                        [self.delegate onUploadTrans:self failed:task.error.code];
                    }
                    
                } else {
                    //  NSLog(@"成功%@",[self->_normalUploadRequest.callbackParam description]);
                    //success(nil);
                    
                    NSString *picUrlStr = [NSString stringWithFormat:@"%@%@", [AppContext getAliUploadHostName], self.objectKey];
                    // 即"http://" + bucketName + "." + this.endpoint + "/" + objectName;
                    NSLog(@"===上传成功%@",picUrlStr);
                    
                    [self uploadSuccesse:picUrlStr];
                }
            });
            
            return nil;
        }];
    });
}

//上传进度更新
-(void)uploadProgress:(CGFloat)process
{
    CGFloat rate = 0;
    if (self.fileSize < kUploadBlockSize)
    {
        rate = process;
    }
    else
    {
        if (self.currentNum < self.total)
        {
            NSInteger partSize = (NSInteger)((CGFloat)kUploadBlockSize * (process / 100.f));
            NSInteger size = (self.currentNum - 1) * kUploadBlockSize + partSize;
            rate = ((CGFloat)size / (CGFloat)self.fileSize) * 100.f;
        }
        else
        {
            NSInteger partSize = (NSInteger)((CGFloat)_lastBlockSize * (process / 100.f));
            NSInteger size = (self.currentNum - 1) * kUploadBlockSize + partSize;
            rate = ((CGFloat)size / (CGFloat)self.fileSize) * 100.f;
        }
    }
    if ([self.delegate respondsToSelector:@selector(onUploadTrans:process:)])
    {
        [self.delegate onUploadTrans:self process:rate];
    }
}

-(void)uploadSuccesse:(NSString *)url
{
    self.currentNum++;
    if (self.currentNum > self.total)
    {
        if ([self.delegate respondsToSelector:@selector(onUploadTrans:successed:)])
        {
            [self.delegate onUploadTrans:self successed:url];
        }
    }
    else
    {
        [self startUpload];
    }
}

#pragma mark WLUploadRequestDelegate methods
- (void)onUploadSuccessed:(NSString *)url
{
    self.uploadRequest = nil;
    [self uploadSuccesse:url];
}

- (void)onUploadProcess:(CGFloat)process
{
    NSLog(@"==%f",process);
    [self uploadProgress:process];
}

- (void)onUploadFailed:(NSInteger)errorCode
{
    self.uploadRequest = nil;
    if ([self.delegate respondsToSelector:@selector(onUploadTrans:failed:)])
    {
        [self.delegate onUploadTrans:self failed:errorCode];
    }
}

@end
