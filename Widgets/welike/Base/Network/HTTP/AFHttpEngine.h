//
//  AFHttpEngine.h
//  AppFramework
//
//  Created by liubin on 13-1-10.
//  Copyright (c) 2013年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHttpOperation.h"
#import "AFNetworkManager.h"

typedef void(^onFinishedBlock) (NSData *data);
typedef void(^onErrorBlock) (NSError *error);
typedef void(^onUploadProgressBlock) (CGFloat progress);
typedef void(^onDownloadProgressBlock) (CGFloat progress);
typedef void(^onDownloadPartBlock) (NSData *part);

@interface AFHttpEngine : NSObject<AFHttpOperationDelegate>
{
    AFHttpOperationType _engineType;
    AFHttpOperationMethod _method;
    NSInteger _resStatusCode;
    NSString *_url;
    NSString *_contentType;
    NSMutableDictionary *_params;

    // Callback blocks
    getDataEncodingBlock _getDataEncodingHandler;
    postDataEncodingBlock _postDataEncodingHandler;
    putDataEncodingBlock _putDataEncodingHandler;
    deleteDataEncodingBlock _deleteDataEncodingHandler;
    onFinishedBlock _onFinished;
    onErrorBlock _onError;
    onUploadProgressBlock _onUploadProgress;
    onDownloadProgressBlock _onDownloadProgress;
    onDownloadPartBlock _onDownloadPart;
}

@property (nonatomic, readonly) AFHttpOperationType engineType;
@property (nonatomic, readonly) NSInteger resStatusCode;
@property (nonatomic, assign) AFHttpOperationMethod method;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, strong) getDataEncodingBlock getDataEncodingHandler;
@property (nonatomic, strong) postDataEncodingBlock postDataEncodingHandler;
@property (nonatomic, strong) putDataEncodingBlock putDataEncodingHandler;
@property (nonatomic, strong) deleteDataEncodingBlock deleteDataEncodingHandler;
@property (nonatomic, strong) onFinishedBlock onFinished;
@property (nonatomic, strong) onErrorBlock onError;
@property (nonatomic, strong) onUploadProgressBlock onUploadProgress;
@property (nonatomic, strong) onDownloadProgressBlock onDownloadProgress;
@property (nonatomic, strong) onDownloadPartBlock onDownloadPart;
@property (nonatomic, assign) CGFloat outTime;

- (id)initWithType:(AFHttpOperationType)type;

// methods
- (void)appendHeader:(NSString *)value forKey:(NSString *)key;
- (void)setBody:(NSData *)data;
- (void)send;
- (void)cancel;

@end
