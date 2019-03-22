//
//  WLPollRequest.h
//  welike
//
//  Created by fan qi on 2018/10/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLPollPost, WLVoteModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^pollSuccessed)(WLPollPost *pollModel);

@interface WLPollRequest : RDBaseRequest

- (instancetype)initWithUserID:(NSString *)userID;
- (void)postVoteWithPollModel:(WLPollPost *)pollModel
                  choiceArray:(NSArray<WLVoteModel *> *)choiceArray
                     isRepost:(BOOL)isRepost
                    successed:(pollSuccessed)successed
                        error:(failedBlock)error;

@end

NS_ASSUME_NONNULL_END
