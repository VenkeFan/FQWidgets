//
//  WLPollPost.m
//  welike
//
//  Created by fan qi on 2018/10/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPollPost.h"

#define HOUR_1      (60 * 60 * 1000)
#define DAY_1       (24 * HOUR_1)

@interface WLPollPost ()

@property (nonatomic, copy, readwrite) NSString *pollID;
@property (nonatomic, copy, readwrite) NSString *pollUserID;
@property (nonatomic, assign, readwrite) NSInteger expiredTime;
@property (nonatomic, assign, readwrite) NSInteger expired;
@property (nonatomic, copy, readwrite) NSString *checkOption;
@property (nonatomic, copy, readwrite) NSString *visibilityOption;
@property (nonatomic, strong, readwrite) NSArray<WLVoteModel *> *voteList;
@property (nonatomic, assign, readwrite) NSUInteger totalCount;
@property (nonatomic, assign, readwrite) BOOL hotPoll;
@property (nonatomic, assign, readwrite) BOOL expiredPoll;
@property (nonatomic, assign, readwrite) BOOL polled;
@property (nonatomic, assign, readwrite) BOOL imagePoll;
@property (nonatomic, assign, readwrite) BOOL myPoll;
@property (nonatomic, assign, readwrite) BOOL needReDraw;
@property (nonatomic, copy, readwrite) NSString *remainText;

@end

@implementation WLPollPost

- (instancetype)init {
    if (self = [super init]) {
        self.type = WELIKE_POST_TYPE_POLL;
        self.needReDraw = NO;
    }
    return self;
}

+ (instancetype)modelWithDic:(NSDictionary *)dic {
    WLPollPost *model = [[WLPollPost alloc] init];
    
    model.pollID = [dic stringForKey:@"id"];
    model.pollUserID = [[dic objectForKey:@"user"] stringForKey:@"id"];
    model.expiredTime = [dic integerForKey:@"expiredTime" def:0];
    model.expired = [dic integerForKey:@"expired" def:0];
    model.checkOption = [dic stringForKey:@"checkOption"];
    model.visibilityOption = [dic stringForKey:@"visibilityOption"];
    model.totalCount = [dic integerForKey:@"totalCount" def:0];
    model.hotPoll = [dic boolForKey:@"hotPoll" def:NO];
    model.expiredPoll = [dic boolForKey:@"expiredPoll" def:NO];
    model.polled = NO;
    model.imagePoll = NO;
    model.myPoll = [model.pollUserID isEqualToString:[AppContext getInstance].accountManager.myAccount.uid];
    
    NSMutableArray *voteInfoList = nil;
    if ([dic[@"choices"] isKindOfClass:[NSArray class]]) {
        NSArray<NSDictionary *> *voteJsonArray = dic[@"choices"];
        voteInfoList = [[NSMutableArray alloc] initWithCapacity:voteJsonArray.count];
        
        for (NSDictionary *voteDic in voteJsonArray) {
            WLVoteModel *voteModel = [WLVoteModel modelWithDic:voteDic];
            [voteInfoList addObject:voteModel];
            
            if (voteModel.isSelected) {
                model.polled = YES;
            }
            
            if (voteModel.imgUrlString.length > 0) {
                model.imagePoll = YES;
            }
        }
    }
    model.voteList = voteInfoList;
    
    if (model.isExpiredPoll) {
        model.remainText = [NSString stringWithFormat:[AppContext getStringForKey:@"poll_end_info" fileName:@"feed"],  model.totalCount];
    } else if (model.expiredTime == -1) {
        model.remainText = [NSString stringWithFormat:[AppContext getStringForKey:@"poll_no_limit_info" fileName:@"feed"], model.totalCount];
    } else {
        NSMutableString *mutStr = [NSMutableString string];
        
        NSString *days = [model p_getVoteExpiredDayTime:model.expiredTime];
        if (![days isEqualToString:@"0"]) {
            [mutStr appendString:days];
            [mutStr appendString:[AppContext getStringForKey:@"poll_day_info" fileName:@"feed"]];
        }
        
        NSString *hours = [model p_getVoteExpiredHourTime:model.expiredTime];
        if (![hours isEqualToString:@"0"]) {
            [mutStr appendString:hours];
            [mutStr appendString:[AppContext getStringForKey:@"poll_hour_info" fileName:@"feed"]];
        }
        
        [mutStr appendString:[NSString stringWithFormat:[AppContext getStringForKey:@"poll_reset_info" fileName:@"feed"], model.totalCount]];
        
        model.remainText = mutStr;
    }
    
    return model;
}

- (void)reset:(WLPollPost *)newModel {
    self.expiredTime = newModel.expiredTime;
    self.expired = newModel.expired;
    self.voteList = newModel.voteList;
    self.totalCount = newModel.totalCount;
    self.expiredPoll = newModel.expiredPoll;
    self.polled = newModel.polled;
    self.imagePoll = newModel.imagePoll;
    self.needReDraw = YES;
}

- (NSString *)p_getVoteExpiredDayTime:(NSUInteger)time {
    BOOL isAddDay = [[self p_getRealVoteExpiredHourTime:time] isEqualToString:@"23"];

    if (time > DAY_1) {
        return [NSString stringWithFormat:@"%lu", time / DAY_1 + (isAddDay ? 1 : 0)];
    } else {
        return isAddDay ? @"1" : @"0";
    }
}

- (NSString *)p_getRealVoteExpiredHourTime:(NSUInteger)time {
    if (time > HOUR_1) {
        return [NSString stringWithFormat:@"%lu", time / HOUR_1 % 24];
    } else {
        return @"0";
    }
}

- (NSString *)p_getVoteExpiredHourTime:(NSUInteger)time {
    long hours = time / HOUR_1 % 24;

    if (hours == 23) {
         return @"0";
    } else {
        return [NSString stringWithFormat:@"%ld", hours + 1];
    }
}

@end

@interface WLVoteModel ()

@property (nonatomic, copy, readwrite) NSString *voteID;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *imgUrlString;
@property (nonatomic, assign, readwrite) NSUInteger count;
@property (nonatomic, assign, readwrite) BOOL selected;

@end

@implementation WLVoteModel

+ (instancetype)modelWithDic:(NSDictionary *)dic {
    WLVoteModel *model = [[WLVoteModel alloc] init];
    model.voteID = dic[@"id"];
    model.name = dic[@"choiceName"];
    model.imgUrlString = [dic[@"choiceImageUrl"] convertToHttps];
    model.count = [dic integerForKey:@"choiceCount" def:0];
    model.selected = [dic boolForKey:@"selected" def:NO];
    
    return model;
}

@end
