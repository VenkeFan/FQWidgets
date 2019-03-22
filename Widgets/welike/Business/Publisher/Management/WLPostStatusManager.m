//
//  WLPostStatusManager.m
//  welike
//
//  Created by gyb on 2018/11/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLPostStatusManager.h"
#import "WLStatusListRequest.h"

@interface WLPostStatusManager ()

@property (nonatomic, strong) WLStatusListRequest *statusListRequest;

@end

@implementation WLPostStatusManager

-(void)listAllStatus:(listAllStatusCompleted)callback
{
    if (self.statusListRequest != nil)
    {
        [self.statusListRequest cancel];
        self.statusListRequest = nil;
    }
    
    __weak typeof(self) weakSelf = self;
    
    self.statusListRequest = [[WLStatusListRequest alloc] init];
    
    [self.statusListRequest requestStatusListSuccess:^(NSMutableArray * _Nonnull items) {
        
        if (callback)
        {
            callback(items, ERROR_SUCCESS);
        }
        
    } error:^(NSInteger errorCode) {
        
        weakSelf.statusListRequest = nil;

        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
            {
                callback(nil, errorCode);
            }
        });

        
    }];
}



@end
