//
//  WLAppinfoRequest.h
//  welike
//
//  Created by gyb on 2018/10/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^AppInfoRequestSuccessed)(NSDictionary *itemDic);

@interface WLAppinfoRequest : RDBaseRequest

- (instancetype)init;

- (void)requestAppinfoSuccess:(AppInfoRequestSuccessed)successed error:(failedBlock)error;



@end


