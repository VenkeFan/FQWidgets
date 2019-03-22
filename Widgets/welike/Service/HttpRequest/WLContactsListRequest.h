//
//  WLContactsListRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^contactsSuccessed)(NSArray *users,NSString *cursor,BOOL isLast);

@interface WLContactsListRequest : RDBaseRequest

- (id)initContactsListRequestWithUid:(NSString *)uid;
//- (void)listContactsSuccessed:(contactsSuccessed)successed error:(failedBlock)error;

- (void)listContactsSuccessedWithPage:(NSString *)cursor success:(contactsSuccessed)successed error:(failedBlock)error;


@end
