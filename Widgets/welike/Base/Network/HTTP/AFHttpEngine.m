//
//  AFHttpEngine.m
//  AppFramework
//
//  Created by liubin on 13-1-10.
//  Copyright (c) 2013年 renren. All rights reserved.
//

#import "AFHttpEngine.h"
#import "NSString+LuuBase.h"

#define kHttpParamsCapacityNumber 10

@interface AFHttpEngine ()

@property (nonatomic, strong) NSMutableDictionary *headers;
@property (nonatomic, strong) NSData *body;
@property (nonatomic, strong) AFHttpOperation *operation;
@property (nonatomic, strong) NSTimer *outTimer;

+ (NSString *)urlEncode:(NSString *)str encoding:(NSStringEncoding)stringEncoding;
+ (NSString *)urlDecode:(NSString *)str encoding:(NSStringEncoding)stringEncoding;
+ (NSString *)defaultQueryStringFromDictionary:(NSDictionary *)dictionary;

@end

@implementation AFHttpEngine

@synthesize engineType = _engineType;
@synthesize method = _method;
@synthesize resStatusCode = _resStatusCode;
@synthesize url = _url;
@synthesize contentType = _contentType;
@synthesize headers = _headers;
@synthesize params = _params;
@synthesize getDataEncodingHandler = _getDataEncodingHandler;
@synthesize postDataEncodingHandler = _postDataEncodingHandler;
@synthesize putDataEncodingHandler = _putDataEncodingHandler;
@synthesize deleteDataEncodingHandler = _deleteDataEncodingHandler;
@synthesize onFinished = _onFinished;
@synthesize onError = _onError;
@synthesize onUploadProgress = _onUploadProgress;
@synthesize onDownloadProgress = _onDownloadProgress;
@synthesize onDownloadPart = _onDownloadPart;
@synthesize operation = _operation;
@synthesize body = _body;

- (id)initWithType:(AFHttpOperationType)type
{
    self = [super init];
    if (self)
    {
        _resStatusCode = 0;
        _engineType = type;
        if (type == AFHttpOperationTypeUpload) {
            self.outTime = kAFHttpRequestUploadTimeOut;
        } else {
            self.outTime = kAFHttpRequestTimeOut;
        }
        
        if (type == AFHttpOperationTypeDownload)
        {
            _method = AFHttpOperationMethodGET;
        }
        else
        {
            _method = AFHttpOperationMethodPOST;
        }

        self.params = [[NSMutableDictionary alloc] initWithCapacity:kHttpParamsCapacityNumber];
        self.headers = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [self.operation cancel];
    self.operation = nil;
}

- (void)setOperation:(AFHttpOperation *)operation
{
    AFNetworkManager *networkManager = [AFNetworkManager getInstance];
    @synchronized(_operation)
    {
        if (_operation)
        {
            [networkManager removeHttpEngineObserver:self flowSize:_operation.flowSize];
            [_operation cancel];
            _operation = nil;
        }
        _operation = operation;
        if (_operation)
        {
            [networkManager addHttpEngineObserver:self];
        }
    }
}

#pragma mark AFHttpEngine methods
- (void)appendHeader:(NSString *)value forKey:(NSString *)key
{
    [self.headers setObject:value forKey:key];
}

- (void)setBody:(NSData *)data
{
    _body = [data copy];
}

- (void)send
{
    _resStatusCode = 0;
    AFNetworkManager *networkManager = [AFNetworkManager getInstance];
    if ([networkManager reachabilityStatus] == HLNetWorkStatusNotReachable)
    {
        if ([NSThread isMainThread])
        {
            NSError *err = [[NSError alloc] initWithDomain:@"NSURLErrorDomain"
                                                      code:kCFURLErrorNetworkConnectionLost
                                                  userInfo:nil];
            if (self.onError)
            {
                self.onError(err);
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *err = [[NSError alloc] initWithDomain:@"NSURLErrorDomain"
                                                          code:kCFURLErrorNetworkConnectionLost
                                                      userInfo:nil];
                if (self.onError)
                {
                    self.onError(err);
                }
            });
        }
        return;
    }

    self.operation = [[AFHttpOperation alloc] initWithURL:self.url
                                                   params:self.params
                                                     body:_body
                                                  headers:self.headers
                                                     type:self.engineType
                                                   method:self.method
                                              contentType:self.contentType
                                                  timeOut:self.outTime
                                                 delegate:self];
    if (self.getDataEncodingHandler)
    {
        self.operation.getDataEncodingHandler = [self.getDataEncodingHandler copy];
        self.getDataEncodingHandler = nil;
    }
    else
    {
        self.operation.getDataEncodingHandler = ^NSString *(NSDictionary *dictionary){
            return [AFHttpEngine defaultQueryStringFromDictionary:dictionary];
        };
    }
    if (self.postDataEncodingHandler)
    {
        self.operation.postDataEncodingHandler = [self.postDataEncodingHandler copy];
        self.postDataEncodingHandler = nil;
    }
    else
    {
        self.operation.postDataEncodingHandler = ^NSData *(NSDictionary *dictionary){
            return [[AFHttpEngine defaultQueryStringFromDictionary:dictionary] dataUsingEncoding:NSUTF8StringEncoding];
        };
    }
    if (self.putDataEncodingHandler)
    {
        self.operation.putDataEncodingHandler = [self.putDataEncodingHandler copy];
        self.putDataEncodingHandler = nil;
    }
    else
    {
        self.operation.putDataEncodingHandler = ^NSData *(NSDictionary *dictionary){
            return [[AFHttpEngine defaultQueryStringFromDictionary:dictionary] dataUsingEncoding:NSUTF8StringEncoding];
        };
    }
    if (self.deleteDataEncodingHandler)
    {
        self.operation.deleteDataEncodingHandler = [self.deleteDataEncodingHandler copy];
        self.deleteDataEncodingHandler = nil;
    }
    else
    {
        self.operation.deleteDataEncodingHandler = ^NSData *(NSDictionary *dictionary){
            return [[AFHttpEngine defaultQueryStringFromDictionary:dictionary] dataUsingEncoding:NSUTF8StringEncoding];
        };
    }
    [networkManager addHttpOperation:self.operation];
    
    if (self.outTimer != nil)
    {
        [self.outTimer invalidate];
    }
    self.outTimer = [NSTimer scheduledTimerWithTimeInterval:self.outTime target:self selector:@selector(timeOut:) userInfo:nil repeats:NO];
}

- (void)cancel
{
    if (self.outTimer != nil)
    {
        [self.outTimer invalidate];
    }
    _resStatusCode = 0;
    self.getDataEncodingHandler = nil;
    self.postDataEncodingHandler = nil;
    self.putDataEncodingHandler = nil;
    self.deleteDataEncodingHandler = nil;
    self.onFinished = nil;
    self.onError = nil;
    self.onUploadProgress = nil;
    self.onDownloadProgress = nil;
    self.onDownloadPart = nil;
    
    [self.operation cancelRequest];
//    self.operation = nil;
}

- (void)timeOut:(id)sender
{
    NSError *err = [[NSError alloc] initWithDomain:@"NSURLErrorDomain"
                                              code:kCFURLErrorTimedOut
                                          userInfo:nil];
    if (self.onError)
    {
        self.onError(err);
    }
    [self.operation cancel];
    self.operation = nil;
}

#pragma mark AFHttpOperationDelegate methods
- (void)AFHttpOperation:(id)operation didFinished:(NSData *)data
{
    if (self.operation == operation)
    {
        if (self.outTimer != nil)
        {
            [self.outTimer invalidate];
        }
        _resStatusCode = self.operation.resStatusCode;
        if (self.onFinished)
        {
            self.onFinished(data);
        }
        self.operation = nil;
    }
}

- (void)AFHttpOperation:(id)operation didError:(NSError *)error
{
    if (self.operation == operation)
    {
        if (self.outTimer != nil)
        {
            [self.outTimer invalidate];
        }
        _resStatusCode = self.operation.resStatusCode;
        if (self.onError)
        {
            self.onError(error);
        }
        self.operation = nil;
    }
}

- (void)AFHttpOperation:(id)operation uploadProgress:(CGFloat)progress
{
    if (self.operation == operation)
    {
        if (self.onUploadProgress)
        {
            self.onUploadProgress(progress);
        }
    }
}

- (void)AFHttpOperation:(id)operation downloadProgress:(CGFloat)progress
{
    if (self.operation == operation)
    {
        if (self.onDownloadProgress)
        {
            self.onDownloadProgress(progress);
        }
    }
}

- (void)AFHttpOperation:(id)operation downloadPart:(NSData *)data
{
    if (self.operation == operation)
    {
        if (self.onDownloadPart)
        {
            self.onDownloadPart(data);
        }
    }
}

#pragma mark AFHttpEngine static methods
+ (NSString *)urlEncode:(NSString *)str encoding:(NSStringEncoding)stringEncoding
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";", @"/", @"?", @":",
                            @"@", @"&", @"=", @"+", @"$", @",", @"!",
                            @"'", @"(", @")", @"*", @"-", @"~", @"_", nil];
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B", @"%2F", @"%3F", @"%3A",
                             @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C", @"%21",
                             @"%27", @"%28", @"%29", @"%2A", @"%2D", @"%7E", @"%5F", nil];
    
    int len = (int)[escapeChars count];
    NSString *tempStr = [str stringByAddingPercentEscapesUsingEncoding:stringEncoding];
    
    if (tempStr == nil) return nil;
    
    NSMutableString *temp = [tempStr mutableCopy];
    
    for (int i = 0; i < len; i++)
    {
        [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
                              withString:[replaceChars objectAtIndex:i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, [temp length])];
    }
    
    return [NSString stringWithString:temp];
}

+ (NSString *)urlDecode:(NSString *)str encoding:(NSStringEncoding)stringEncoding
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";", @"/", @"?", @":",
                            @"@", @"&", @"=", @"+", @"$", @",", @"!",
                            @"'", @"(", @")", @"*", @"-", @"~", @"_", nil];
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B", @"%2F", @"%3F", @"%3A",
                             @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C", @"%21",
                             @"%27", @"%28", @"%29", @"%2A", @"%2D", @"%7E", @"%5F", nil];
    
    int len = (int)[escapeChars count];
    NSMutableString *temp = [str mutableCopy];
    
    if (temp == nil) return nil;
    
    for (int i = 0; i < len; i++)
    {
        [temp replaceOccurrencesOfString:[replaceChars objectAtIndex:i]
                              withString:[escapeChars objectAtIndex:i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, [temp length])];
    }
    
    return [[NSString stringWithString:temp] stringByReplacingPercentEscapesUsingEncoding:stringEncoding];
}

+ (NSString *)defaultQueryStringFromDictionary:(NSDictionary *)dictionary
{
    if ([dictionary count] <= 0) return @"";
    
    NSMutableString *postStr = [NSMutableString string];
    NSArray *allKeys = [dictionary allKeys];
    for (id key in allKeys)
    {
        NSString *keyName = [NSString stringWithFormat:@"%@", key];
        NSString *valName = [NSString stringWithFormat:@"%@", [dictionary objectForKey:key]];
        [postStr appendFormat:@"%@=%@&", keyName, [self urlEncode:valName encoding:NSUTF8StringEncoding]];
    }
    
    return [NSString stringWithString:[postStr substringWithRange:NSMakeRange(0, [postStr length] - 1)]];
}

@end
