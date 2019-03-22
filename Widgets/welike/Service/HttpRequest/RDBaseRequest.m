//
//  RDBaseRequest.m
//  welike
//
//  Created by 刘斌 on 2018/4/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"
#import "RDLocalizationManager.h"
#import "WLAccountManager.h"
#import "WLStartHandler.h"
#import "LuuUtils.h"
#import "NSString+LuuBase.h"
#import "AppContext.h"
#import "WLServiceGlobal.h"

@interface RDBaseRequest ()

@property (nonatomic, copy) NSString *baseUrl;

- (NSData *)queryDataEncodingForBody:(NSDictionary *)param;

@end

@implementation RDBaseRequest

- (id)initWithType:(AFHttpOperationType)type api:(NSString *)api method:(AFHttpOperationMethod)method
{
    return [self initWithType:type hostName:[AppContext getHostName] api:api method:method];
}

- (id)initWithType:(AFHttpOperationType)type hostName:(NSString *)hostName api:(NSString *)api method:(AFHttpOperationMethod)method
{
    self = [super initWithType:type];
    if (self)
    {
        NSMutableString *baseUrl = [[NSMutableString alloc] init];
        [baseUrl appendFormat:@"%@%@?welikeParams=%@", hostName, api, [RDBaseRequest buildBaseParamsBlock]];
        WLAccount *account = [[AppContext getInstance].accountManager myAccount];
        if (account != nil)
        {
            [baseUrl appendFormat:@"&token=%@", account.accessToken];
            [self appendHeader:account.uid forKey:@"idtoken"];
        }
        self.urlExtParams = [NSMutableDictionary dictionary];
        self.baseUrl = [NSString stringWithString:baseUrl];
        self.method = method;
        self.userInfo = [[NSMutableDictionary alloc] init];
        self.contentType = @"application/json;charset=utf-8";
    }
    return self;
}

- (void)cancel
{
    self.onSuccessed = nil;
    self.onFailed = nil;
    [super cancel];
}

- (void)valueBlock
{
    __weak typeof(self) weakSelf = self;
    if (self.method == AFHttpOperationMethodPOST)
    {
        self.postDataEncodingHandler = ^NSData *(NSDictionary *dictionary) {
            return [weakSelf queryDataEncodingForBody:dictionary];
        };
    }
    else if (self.method == AFHttpOperationMethodPUT)
    {
        self.putDataEncodingHandler = ^NSData *(NSDictionary *dictionary) {
            return [weakSelf queryDataEncodingForBody:dictionary];
        };
    }
    else if (self.method == AFHttpOperationMethodDELETE)
    {
        self.deleteDataEncodingHandler = ^NSData *(NSDictionary *dictionary) {
            return [weakSelf queryDataEncodingForBody:dictionary];
        };
    }
    
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
                        if (weakSelf.onSuccessed)
                        {
                            weakSelf.onSuccessed(result);
                        }
                    }
                    else
                    {
                        if (errorCode == ERROR_NETWORK_AUTH_NOT_MATCH)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[AppContext getInstance].startHandler logout];
                            });
                        }
                        else if (weakSelf.onFailed)
                        {
                            weakSelf.onFailed(errorCode);
                        }
                    }
                }
                else
                {
                    if (weakSelf.onFailed)
                    {
                        weakSelf.onFailed(ERROR_NETWORK_RESP_INVALID);
                    }
                }
            }
            else
            {
                if (weakSelf.onFailed)
                {
                    weakSelf.onFailed(ERROR_NETWORK_UNKNOWN);
                }
            }
        }
        else
        {
            if (weakSelf.onSuccessed)
            {
                weakSelf.onSuccessed(nil);
            }
        }
    };
    
    self.onError = ^(NSError *error) {
        
        if (weakSelf.onFailed)
        {
            weakSelf.onFailed(ERROR_NETWORK_INVALID);
        }
    };
}

- (void)sendQuery
{
    if ([self.urlExtParams count] > 0)
    {
        NSMutableString *postStr = [NSMutableString string];
        NSArray *allKeys = [self.urlExtParams allKeys];
        for (id key in allKeys)
        {
            NSString *keyName = [NSString stringWithObject:key];
            NSString *valName = [[NSString stringWithObject:[self.urlExtParams objectForKey:key]] urlEncode:NSUTF8StringEncoding];
            [postStr appendFormat:@"%@=%@&", keyName, valName];
        }
        
        self.url = [NSString stringWithFormat:@"%@&%@", self.baseUrl, [postStr substringWithRange:NSMakeRange(0, [postStr length] - 1)]];
    }
    
    
    else
    {
        self.url = [self.baseUrl copy];
    }
    [self valueBlock];
    [super send];
}

+ (NSString *)buildBaseParamsBlock
{
    NSString *version = [LuuUtils appVersion];
    NSString *language = [[RDLocalizationManager getInstance] getCurrentLanguage];
    NSString *os = @"ios";
    NSString *deviceId = [LuuUtils deviceId];
    NSString *source = [LuuUtils deviceModel];
    
    NSMutableString *commonParam = [[NSMutableString alloc] init];
    [commonParam appendFormat:@"ve=%@", version];
    if ([language length] > 0)
    {
        [commonParam appendFormat:@"&la=%@", language];
    }
    [commonParam appendFormat:@"&os=%@", os];
    if ([deviceId length] > 0)
    {
        [commonParam appendFormat:@"&de=%@", deviceId];
    }
    if ([source length] > 0)
    {
        [commonParam appendFormat:@"&sr=%@", source];
    }
    
    return [commonParam stringEncodeBase64];
}

- (NSData *)queryDataEncodingForBody:(NSDictionary *)param
{
    return [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
}

@end
