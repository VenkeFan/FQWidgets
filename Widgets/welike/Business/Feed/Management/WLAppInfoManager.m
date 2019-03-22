//
//  WLAppInfoManager.m
//  welike
//
//  Created by gyb on 2018/10/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLAppInfoManager.h"
#import "WLAppinfoRequest.h"


@interface WLAppInfoManager ()

@property (nonatomic, strong) WLAppinfoRequest *appinfoRequest;


@end


@implementation WLAppInfoManager


-(void)appInfo:(appInfoCompleted)complete
{
    if (self.appinfoRequest != nil)
    {
        [self.appinfoRequest cancel];
        self.appinfoRequest = nil;
    }
    
    self.appinfoRequest = [[WLAppinfoRequest alloc] init];
    
    [self.appinfoRequest requestAppinfoSuccess:^(NSDictionary *itemDic) {
        
        if (complete)
        {
            complete(itemDic,ERROR_SUCCESS);
        }
        
    } error:^(NSInteger errorCode) {
        if (complete)
        {
            complete(nil,errorCode);
        }
    }];
}

@end
