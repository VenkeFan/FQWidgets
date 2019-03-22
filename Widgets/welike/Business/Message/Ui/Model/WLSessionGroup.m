//
//  WLSessionGroup.m
//  welike
//
//  Created by luxing on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSessionGroup.h"
#import "WLIMCommon.h"

@interface WLSessionGroup ()

@property (nonatomic, assign) BOOL greet;
@property (nonatomic, strong) NSMutableDictionary *sessionDic;

@end

@implementation WLSessionGroup

- (id)initWithGreet:(BOOL)greet
{
    self = [super init];
    if (self)
    {
        self.greet = greet;
        self.sessionDic = [NSMutableDictionary dictionaryWithCapacity:30];
    }
    return self;
}

- (void)resetSessions:(NSArray<WLIMSession *> *)sessions
{
    [self.sessionDic removeAllObjects];
    [self appendSessions:sessions];
}

- (void)appendSessions:(NSArray<WLIMSession *> *)sessions
{
    for (NSInteger i = 0; i < sessions.count; i++)
    {
        WLIMSession *session = sessions[i];
        if (session.greet == self.greet)
        {
            [self.sessionDic setObject:session forKey:session.sessionId];
        }
        else
        {
            if (session.greet == YES)
            {
                WLIMSession *stranger = [self.sessionDic objectForKey:STRANGER_SESSION_SID];
                if (stranger == nil)
                {
                    stranger = [[WLIMSession alloc] init];
                    stranger.sessionId = STRANGER_SESSION_SID;
                    stranger.sessionType = WLIMSessionTypeStranger;
                }
                if (stranger.time < session.time)
                {
                    stranger.time = session.time;
                }
                stranger.unreadCount = 1;
                [self.sessionDic setObject:stranger forKey:STRANGER_SESSION_SID];
            }
            else
            {
                [self.sessionDic removeObjectForKey:session.sessionId];
            }
        }
    }
}

- (void)removeSession:(WLIMSession *)session
{
    [self.sessionDic removeObjectForKey:session.sessionId];
}

- (NSArray<WLIMSession *> *)allSessions
{
    return [self sortSessions:[self.sessionDic allValues]];
}

- (NSArray<WLIMSession *> *)sortSessions:(NSArray<WLIMSession *> *)sessions
{
    return [sessions sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
    {
        WLIMSession *session1 = obj1;
        WLIMSession *session2 = obj2;
        if (session1.time > session2.time)
        {
            return NSOrderedAscending;
        }
        else if (session1.time < session2.time)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
}

@end
