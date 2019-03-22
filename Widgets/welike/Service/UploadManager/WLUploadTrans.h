//
//  WLUploadTrans.h
//  welike
//
//  Created by 刘斌 on 2018/4/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLUploadTrans;

@protocol WLUploadTransDelegate <NSObject>

- (void)onUploadTrans:(WLUploadTrans *)trans successed:(NSString *)url;
- (void)onUploadTrans:(WLUploadTrans *)trans process:(CGFloat)process;
- (void)onUploadTrans:(WLUploadTrans *)trans failed:(NSInteger)errorCode;

@end

@interface WLUploadTrans : NSObject

@property (nonatomic, readonly) NSString *objectKey;
@property (nonatomic, readonly) NSString *sign;
@property (nonatomic, readonly) BOOL isResume;
@property (nonatomic, weak) id<WLUploadTransDelegate> delegate;

- (id)initWithFileName:(NSString *)fileName objectKey:(NSString *)objectKey sign:(NSString *)sign resume:(BOOL)resume;
- (void)start;
- (void)resume;
- (void)stop;

@end
