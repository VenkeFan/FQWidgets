//
//  WLPollPost.h
//  welike
//
//  Created by fan qi on 2018/10/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPostBase.h"

#define kVoteImageCellDefaultHeight             160.0
#define kVoteImageCellDefaultWidth              178.0
#define kVoteNoImageCellHeight                  32.0
#define kPollInfoHeight                         30.0

@class WLVoteModel;

NS_ASSUME_NONNULL_BEGIN

@interface WLPollPost : WLPostBase

@property (nonatomic, copy, readonly) NSString *pollID;
@property (nonatomic, copy, readonly) NSString *pollUserID;
@property (nonatomic, assign, readonly) NSInteger expiredTime;
@property (nonatomic, assign, readonly) NSInteger expired;
@property (nonatomic, copy, readonly) NSString *checkOption;
@property (nonatomic, copy, readonly) NSString *visibilityOption;
@property (nonatomic, strong, readonly) NSArray<WLVoteModel *> *voteList;
@property (nonatomic, assign, readonly) NSUInteger totalCount;
@property (nonatomic, assign, getter=isHotPoll, readonly) BOOL hotPoll;
@property (nonatomic, assign, getter=isExpiredPoll, readonly) BOOL expiredPoll;
@property (nonatomic, assign, getter=hasPolled, readonly) BOOL polled;
@property (nonatomic, assign, getter=isImagePoll, readonly) BOOL imagePoll;
@property (nonatomic, assign, getter=isMyPoll, readonly) BOOL myPoll;
@property (nonatomic, assign, getter=isNeedReDraw, readonly) BOOL needReDraw;
@property (nonatomic, copy, readonly) NSString *remainText;

+ (instancetype)modelWithDic:(NSDictionary *)dic;

- (void)reset:(WLPollPost *)newModel;

@end

@interface WLVoteModel : NSObject

@property (nonatomic, copy, readonly) NSString *voteID;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *imgUrlString;
@property (nonatomic, assign, readonly) NSUInteger count;
@property (nonatomic, assign, getter=isSelected, readonly) BOOL selected;

+ (instancetype)modelWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
