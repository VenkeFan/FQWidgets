//
//  WLMeRequestManager.h
//  welike
//
//  Created by gyb on 2019/3/8.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLUser.h"


typedef void(^listInfluencerCompleted) (NSString *forwardUrl, NSInteger errCode);

typedef void(^listSessionCompleted) (WLUser *user, NSInteger errCode);


@interface WLMeRequestManager : NSObject

-(void)listInfluencer:(listInfluencerCompleted)complete;

-(void)listCustomerService:(listSessionCompleted)complete;


@end


