//
//  RDBaseRequest.h
//  welike
//
//  Created by 刘斌 on 2018/4/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "AFHttpEngine.h"

typedef void(^successedBlock) (id result);
typedef void(^failedBlock) (NSInteger errorCode);

@interface RDBaseRequest : AFHttpEngine

@property (nonatomic, strong) NSMutableDictionary *urlExtParams;
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, strong) successedBlock onSuccessed;
@property (nonatomic, strong) failedBlock onFailed;

- (id)initWithType:(AFHttpOperationType)type api:(NSString *)api method:(AFHttpOperationMethod)method;
- (id)initWithType:(AFHttpOperationType)type hostName:(NSString *)hostName api:(NSString *)api method:(AFHttpOperationMethod)method;
- (void)sendQuery;
+ (NSString *)buildBaseParamsBlock;

@end
