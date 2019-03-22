//
//  WLRisingFeedsRequest.h
//  welike
//
//  Created by fan qi on 2018/12/20.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@interface WLRisingFeedsRequest : RDBaseRequest

- (void)tryRisingFeedsWithCursor:(NSString *)cursor
                       interests:(NSArray *)interests
                       successed:(void(^)(NSArray *feeds, NSString *cursor))successed
                           error:(failedBlock)error;

@end
