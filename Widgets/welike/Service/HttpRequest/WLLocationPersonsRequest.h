//
//  WLLocationPersonsRequest.h
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"


typedef void(^requestSuccessed)(NSArray *users, BOOL last, NSInteger pageNum);

@interface WLLocationPersonsRequest : RDBaseRequest

@property (copy,nonatomic)  NSString *placeId;


- (id)initLocationPersons:(NSString *)placeId;

- (void)locationPersons:(NSInteger)pageNum successed:(requestSuccessed)successed error:(failedBlock)error;

@end
