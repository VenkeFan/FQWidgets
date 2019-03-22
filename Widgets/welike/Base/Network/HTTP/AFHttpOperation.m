//
//  AFHttpOperation.m
//  AppFramework
//
//  Created by liubin on 13-1-9.
//  Copyright (c) 2013年 renren. All rights reserved.
//

#import "AFHttpOperation.h"
#import "AFNetworkManager.h"

@interface AFHttpOperation ()

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) AFHttpOperationMethod method;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) NSData *body;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, assign) CGFloat totalBytesExpectedToRead;
#if TARGET_OS_IPHONE
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskId;
#endif

- (NSMutableURLRequest *)submit;
- (void)endBackgroundTask;
- (void)cancelConnection;

@end

@implementation AFHttpOperation

@synthesize flowSize = _flowSize;
@synthesize resStatusCode = _resStatusCode;
@synthesize type = _type;
@synthesize state = _state;
@synthesize getDataEncodingHandler = _getDataEncodingHandler;
@synthesize postDataEncodingHandler = _postDataEncodingHandler;
@synthesize putDataEncodingHandler = _putDataEncodingHandler;
@synthesize deleteDataEncodingHandler = _deleteDataEncodingHandler;
@synthesize delegate = _delegate;

@synthesize url = _url;
@synthesize method = _method;
@synthesize contentType = _contentType;
@synthesize headers = _headers;
@synthesize params = _params;
@synthesize body = _body;
@synthesize connection = _connection;
@synthesize data = _data;
@synthesize isCancelled = _isCancelled;
@synthesize totalBytesExpectedToRead = _totalBytesExpectedToRead;
#if TARGET_OS_IPHONE
@synthesize backgroundTaskId = _backgroundTaskId;
#endif

- (id)initWithURL:(NSString *)url
           params:(NSDictionary *)params
             body:(NSData *)body
          headers:(NSDictionary *)headers
             type:(AFHttpOperationType)type
           method:(AFHttpOperationMethod)method
      contentType:(NSString *)contentType
          timeOut:(CGFloat)timeOut
         delegate:(id<AFHttpOperationDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _resStatusCode = 0;
        _flowSize = 0;
        _totalBytesExpectedToRead = 0;
        _isCancelled = NO;
        _type = type;
        _method = method;

        self.outTime = timeOut;
        self.state = AFHttpOperationStateReady;
        self.url = [url copy];
        self.contentType = [contentType copy];
        self.body = body;
        self.params = [[NSDictionary alloc] initWithDictionary:params copyItems:YES];
        self.headers = [[NSMutableDictionary alloc] initWithDictionary:headers copyItems:YES];
        self.delegate = delegate;
    }

    return self;
}

- (void)dealloc
{
    [self.connection cancel];
    self.connection = nil;
}

- (void)setState:(AFHttpOperationState)state
{
    switch (state)
    {
        case AFHttpOperationStateReady:
        {
            [self willChangeValueForKey:@"isReady"];
            break;
        }
        case AFHttpOperationStateExecuting:
        {
            [self willChangeValueForKey:@"isReady"];
            [self willChangeValueForKey:@"isExecuting"];
            break;
        }
        case AFHttpOperationStateFinish:
        {
            [self willChangeValueForKey:@"isExecuting"];
            [self willChangeValueForKey:@"isFinished"];
            break;
        }
        default:
            break;
    }

    _state = state;

    switch (state)
    {
        case AFHttpOperationStateReady:
        {
            [self didChangeValueForKey:@"isReady"];
            break;
        }
        case AFHttpOperationStateExecuting:
        {
            [self didChangeValueForKey:@"isReady"];
            [self didChangeValueForKey:@"isExecuting"];
            break;
        }
        case AFHttpOperationStateFinish:
        {
            [self didChangeValueForKey:@"isExecuting"];
            [self didChangeValueForKey:@"isFinished"];
            break;
        }
        default:
            break;
    }
}

#pragma mark NSOperation methods
- (void)start
{
#if TARGET_OS_IPHONE
    
    self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
#endif

    if (self.isReady)
    {
        NSMutableURLRequest *request = [self submit];
        if (request)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self
                                                          startImmediately:NO];
                [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
                [self.connection start];
            });

            self.state = AFHttpOperationStateExecuting;
        }
        else
        {
            self.state = AFHttpOperationStateFinish;
            [self endBackgroundTask];
        }
    }
    else if (self.isCancelled)
    {
        self.state = AFHttpOperationStateFinish;
        [self endBackgroundTask];
    }
}

/**
 * Because NSOperation can't be reused in NSOperationQueue, this operation is invalid after cancel.
 */
- (void)cancel
{
    if (self.isFinished) return;
    if (self.isCancelled == YES) return;
    
    @synchronized(self)
    {
        // Add @synchronized for thread safe when cancel method is called in multi-threads.
        // Do not release url, params and data to avoid bad pointer risk.
        _state = AFHttpOperationStateFinish;
        [super cancel];
        self.delegate = nil;
      
        if (self.isExecuting == YES)
        {
            [self performSelector:@selector(cancelConnection) withObject:nil afterDelay:0.1f];
        }
       
         self.isCancelled = YES;
    }
}

-(void)cancelRequest
{
    [_connection cancel];
    self.state = AFHttpOperationStateFinish;
}

- (BOOL)isReady
{
    if (self.state == AFHttpOperationStateReady) return YES;
    return NO;
}

- (BOOL)isExecuting
{
    if (self.state == AFHttpOperationStateExecuting) return YES;
    return NO;
}

- (BOOL)isFinished
{
    if (self.state == AFHttpOperationStateFinish) return YES;
    return NO;
}

- (BOOL)isConcurrent
{
    return YES;
}

#pragma mark NSURLConnection methods
- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    // Record upload progress
    if ([self.delegate respondsToSelector:@selector(AFHttpOperation:uploadProgress:)])
    {
        CGFloat written = (CGFloat)totalBytesWritten;
        CGFloat total = (CGFloat)totalBytesExpectedToWrite;
        if (total > 0)
        {
            CGFloat progress = (written / total) * 100;
            [self.delegate AFHttpOperation:self uploadProgress:progress];
        }
    }

    _flowSize += bytesWritten;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.data = nil;
    if (response)
    {
        _resStatusCode = [((NSHTTPURLResponse *)response) statusCode];
        long long size = [response expectedContentLength] < 0 ? 0 : [response expectedContentLength];
        self.totalBytesExpectedToRead = size;
        self.data = [[NSMutableData alloc] initWithCapacity:(NSUInteger)size];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (data)
    {
        if (!self.data)
        {
            
            self.data = [NSMutableData data];
        }

        [self.data appendData:data];

        // Record download progress
        if ([self.delegate respondsToSelector:@selector(AFHttpOperation:downloadProgress:)])
        {
            CGFloat read = (CGFloat)[self.data length];
            CGFloat total = (CGFloat)self.totalBytesExpectedToRead;
            if (total > 0)
            {
                CGFloat progress = (read / total) * 100;
                [self.delegate AFHttpOperation:self downloadProgress:progress];
            }
        }

        // part download
        if ([self.delegate respondsToSelector:@selector(AFHttpOperation:downloadPart:)])
        {
            [self.delegate AFHttpOperation:self downloadPart:data];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    NSLog(@"取消后finish");
    if (self.isCancelled) return;
    
    self.state = AFHttpOperationStateFinish;
    _flowSize += [self.data length];
    if ([self.delegate respondsToSelector:@selector(AFHttpOperation:didFinished:)])
    {
        [self.delegate AFHttpOperation:self didFinished:self.data];
    }
    self.data = nil;
    [self endBackgroundTask];
  
    [AFNetworkManager logNumOfRequst];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    NSLog(@"取消后error");
    self.state = AFHttpOperationStateFinish;
    if (self.isCancelled) return;
    _flowSize += [self.data length];
    self.data = nil;
    if ([self.delegate respondsToSelector:@selector(AFHttpOperation:didError:)])
    {
        [self.delegate AFHttpOperation:self didError:error];
    }
    [self endBackgroundTask];
}

#pragma mark NSOperation private methods
- (NSMutableURLRequest *)submit
{
    NSMutableURLRequest *request = nil;

    if (self.method == AFHttpOperationMethodGET)
    {
        NSString *urlStr = nil;
        NSString *paramsString = self.getDataEncodingHandler(self.params);
        if (paramsString)
        {
            NSURL *tmpUrl = [NSURL URLWithString:self.url];
            if ([[tmpUrl query] length] > 0)
            {
                urlStr = [NSString stringWithFormat:@"%@&%@", self.url, paramsString];
            }
            else
            {
                urlStr = [NSString stringWithFormat:@"%@?%@", self.url, paramsString];
            }
        }
        else
        {
            urlStr = [NSString stringWithFormat:@"%@", self.url];
        }

        NSURL *url = [NSURL URLWithString:urlStr];
        request = [NSMutableURLRequest requestWithURL:url
                                          cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                      timeoutInterval:self.outTime];
    }
    else
    {
        NSURL *url = [NSURL URLWithString:self.url];
        request = [NSMutableURLRequest requestWithURL:url
                                          cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                      timeoutInterval:self.outTime];
    }

    switch (self.method)
    {
        case AFHttpOperationMethodGET:
        {
            [request setHTTPMethod:@"GET"];
            break;
        }
        case AFHttpOperationMethodPOST:
        {
            [request setHTTPMethod:@"POST"];
            if ([self.body length] > 0)
            {
                [request setHTTPBody:self.body];
                [request setValue:[NSString stringWithFormat:@"%d", (int)[self.body length]] forHTTPHeaderField:@"Content-Length"];
            }
            else
            {
                NSData *postData = self.postDataEncodingHandler(self.params);
                if (postData)
                {
                    [request setHTTPBody:postData];
                    [request setValue:[NSString stringWithFormat:@"%d", (int)[postData length]] forHTTPHeaderField:@"Content-Length"];
                }
            }
            break;
        }
        case AFHttpOperationMethodPUT:
        {
            [request setHTTPMethod:@"PUT"];
            if ([self.body length] > 0)
            {
                [request setHTTPBody:self.body];
                [request setValue:[NSString stringWithFormat:@"%d", (int)[self.body length]] forHTTPHeaderField:@"Content-Length"];
            }
            else
            {
                NSData *putData = self.putDataEncodingHandler(self.params);
                if (putData)
                {
                    [request setHTTPBody:putData];
                    [request setValue:[NSString stringWithFormat:@"%d", (int)[putData length]] forHTTPHeaderField:@"Content-Length"];
                }
            }
            break;
        }
        case AFHttpOperationMethodDELETE:
        {
            [request setHTTPMethod:@"DELETE"];
            if ([self.body length] > 0)
            {
                [request setHTTPBody:self.body];
                [request setValue:[NSString stringWithFormat:@"%d", (int)[self.body length]] forHTTPHeaderField:@"Content-Length"];
            }
            else
            {
                NSData *deleteData = self.deleteDataEncodingHandler(self.params);
                if (deleteData)
                {
                    [request setHTTPBody:deleteData];
                    [request setValue:[NSString stringWithFormat:@"%d", (int)[deleteData length]] forHTTPHeaderField:@"Content-Length"];
                }
            }
            break;
        }
        default:
        {
            [request setHTTPMethod:@"GET"];
            break;
        }
    }
    if ([self.contentType length] > 0)
    {
        [request setValue:self.contentType forHTTPHeaderField:@"Content-Type"];
    }
    
    id keys = [self.headers allKeys];
    NSInteger count = [keys count];
    for (NSInteger i = 0; i < count; i++)
    {
        NSString *key = [keys objectAtIndex:i];
        NSString *value = [self.headers objectForKey:key];
        [request setValue:value forHTTPHeaderField:key];
    }
    
    return request;
}

- (void)endBackgroundTask
{
    if ([NSThread isMainThread])
    {
        if (self.backgroundTaskId != UIBackgroundTaskInvalid)
        {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
            self.backgroundTaskId = UIBackgroundTaskInvalid;
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.backgroundTaskId != UIBackgroundTaskInvalid)
            {
                [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
                self.backgroundTaskId = UIBackgroundTaskInvalid;
            }
        });
    }
}

- (void)cancelConnection
{
    [self.connection cancel];
    self.connection = nil;
    
    @synchronized(self)
    {
        if (self.state != AFHttpOperationStateFinish)
        {
            self.state = AFHttpOperationStateFinish;
        }
    }
    
    [self endBackgroundTask];
}

@end
