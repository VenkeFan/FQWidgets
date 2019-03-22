//
//  WLPostStatusManager.h
//  welike
//
//  Created by gyb on 2018/11/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^listAllStatusCompleted) (NSArray *status, NSInteger errCode);

@interface WLPostStatusManager : NSObject

-(void)listAllStatus:(listAllStatusCompleted)callback;

@end
