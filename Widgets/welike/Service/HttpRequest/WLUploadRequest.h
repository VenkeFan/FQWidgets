//
//  WLUploadRequest.h
//  welike
//
//  Created by 刘斌 on 2018/4/19.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "AFHttpEngine.h"

//#define kUploadBlockSize          1024 * 1024 * 5
#define kUploadBlockSize            5242880

@protocol WLUploadRequestDelegate <NSObject>

- (void)onUploadSuccessed:(NSString *)url;
- (void)onUploadProcess:(CGFloat)process;
- (void)onUploadFailed:(NSInteger)errorCode;

@end

@interface WLUploadRequest : AFHttpEngine

@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, weak) id<WLUploadRequestDelegate> delegate;

- (id)initWithFileName:(NSString *)fileName objectKey:(NSString *)objectKey partNum:(NSInteger)partNum total:(NSInteger)total;
- (void)cancel;
- (void)upload;

@end
