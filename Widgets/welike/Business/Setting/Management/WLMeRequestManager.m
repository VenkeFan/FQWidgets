//
//  WLMeRequestManager.m
//  welike
//
//  Created by gyb on 2019/3/8.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLMeRequestManager.h"
#import "WLInfulencerRequest.h"
#import "WLServiceRequest.h"
#import "WLIMSession.h"

@interface WLMeRequestManager ()

@property (nonatomic, strong) WLInfulencerRequest *infulencerRequest;

@property (nonatomic, strong) WLServiceRequest *serviceRequest;

@end


@implementation WLMeRequestManager

-(void)listInfluencer:(listInfluencerCompleted)complete
{
    if (self.infulencerRequest != nil)
    {
        [self.infulencerRequest cancel];
        self.infulencerRequest = nil;
    }
    
    //    __weak typeof(self) weakSelf = self;
    
    self.infulencerRequest = [[WLInfulencerRequest alloc] init];
    
    [self.infulencerRequest getInfluencer:^(NSString * _Nonnull str) {
       
      //  NSLog(@"%@",str);
        if (complete)
        {
            complete(str,ERROR_SUCCESS);
        }
        
        
    } failed:^(NSInteger errorCode) {
        
        if (complete)
        {
            complete(@"",errorCode);
        }
    }];
}

-(void)listCustomerService:(listSessionCompleted)complete
{
    if (self.serviceRequest != nil)
    {
        [self.serviceRequest cancel];
        self.serviceRequest = nil;
    }
    
    //    __weak typeof(self) weakSelf = self;
    
    self.serviceRequest = [[WLServiceRequest alloc] init];
    
    [self.serviceRequest getServiceUser:^(WLUser *user) {
        
        //  NSLog(@"%@",str);
        if (complete)
        {
            complete(user,ERROR_SUCCESS);
        }
        
        
    } failed:^(NSInteger errorCode) {
        
        if (complete)
        {
            complete(nil,errorCode);
        }
    }];
}



@end
