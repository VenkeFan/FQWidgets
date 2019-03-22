//
//  WLUploadManager.h
//  welike
//
//  Created by 刘斌 on 2018/4/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UPLOAD_TYPE_IMG           @"img"
#define UPLOAD_TYPE_VIDEO         @"video"
@class OSSClient;
@protocol WLUploadManagerDelegate <NSObject>

@optional
- (void)onUploadingKey:(NSString *)objectKey completed:(NSString *)url;
- (void)onUploadingKey:(NSString *)objectKey failed:(NSInteger)errCode;
- (void)onUploadingKey:(NSString *)objectKey process:(CGFloat)process;

@end

@interface WLUploadManager : NSObject

@property (nonatomic, strong) OSSClient *defaultClient;

- (void)registerDelegate:(id<WLUploadManagerDelegate>)delegate;
- (void)unregister:(id<WLUploadManagerDelegate>)delegate;

- (void)prepare;
- (NSString *)uploadWithFileName:(NSString *)objFileName objectType:(NSString *)objectType;
- (NSString *)uploadWithObjectKey:(NSString *)objectKey objFileName:(NSString *)objFileName objectType:(NSString *)objectType;
- (void)removeWithObjectKey:(NSString *)objectKey objFileName:(NSString *)objFileName;

@end
