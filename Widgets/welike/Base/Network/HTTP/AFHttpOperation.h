//
//  AFHttpOperation.h
//  AppFramework
//
//  Created by liubin on 13-1-9.
//  Copyright (c) 2013年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHttpMacros.h"

typedef NSString *(^getDataEncodingBlock) (NSDictionary *dictionary);
typedef NSData *(^postDataEncodingBlock) (NSDictionary *dictionary);
typedef NSData *(^putDataEncodingBlock) (NSDictionary *dictionary);
typedef NSData *(^deleteDataEncodingBlock) (NSDictionary *dictionary);

@class AFHttpOperation;

@protocol AFHttpOperationDelegate <NSObject>

- (void)AFHttpOperation:(id)operation didFinished:(NSData *)data;
- (void)AFHttpOperation:(id)operation didError:(NSError *)error;
- (void)AFHttpOperation:(id)operation uploadProgress:(CGFloat)progress;
- (void)AFHttpOperation:(id)operation downloadProgress:(CGFloat)progress;
- (void)AFHttpOperation:(id)operation downloadPart:(NSData *)data;

@end

typedef enum
{
    AFHttpOperationMethodGET = 0,
    AFHttpOperationMethodPOST,
    AFHttpOperationMethodPUT,
    AFHttpOperationMethodDELETE
} AFHttpOperationMethod;

@interface AFHttpOperation : NSOperation
{
    size_t _flowSize;
    NSInteger _resStatusCode;
    AFHttpOperationType _type;
    AFHttpOperationState _state;
    getDataEncodingBlock _getDataEncodingHandler;
    postDataEncodingBlock _postDataEncodingHandler;
    putDataEncodingBlock _putDataEncodingHandler;
    deleteDataEncodingBlock _deleteDataEncodingHandler;
    __unsafe_unretained id<AFHttpOperationDelegate> _delegate;
}

@property (nonatomic, readonly) size_t flowSize;
@property (nonatomic, readonly) NSInteger resStatusCode;
@property (nonatomic, readonly) AFHttpOperationType type;
@property (nonatomic, assign) AFHttpOperationState state;
@property (nonatomic, assign) CGFloat outTime;
@property (nonatomic, strong) getDataEncodingBlock getDataEncodingHandler;
@property (nonatomic, strong) postDataEncodingBlock postDataEncodingHandler;
@property (nonatomic, strong) putDataEncodingBlock putDataEncodingHandler;
@property (nonatomic, strong) deleteDataEncodingBlock deleteDataEncodingHandler;
@property (nonatomic, assign) id<AFHttpOperationDelegate> delegate;

- (id)initWithURL:(NSString *)url
           params:(NSDictionary *)params
             body:(NSData *)body
          headers:(NSDictionary *)headers
             type:(AFHttpOperationType)type
           method:(AFHttpOperationMethod)method
      contentType:(NSString *)contentType
          timeOut:(CGFloat)timeOut
         delegate:(id<AFHttpOperationDelegate>)delegate;


-(void)cancelRequest;

@end
