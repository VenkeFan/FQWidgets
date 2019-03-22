//
//  WLSessionGroup.h
//  welike
//
//  Created by luxing on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMSession.h"

@interface WLSessionGroup : NSObject

- (id)initWithGreet:(BOOL)greet;

- (void)resetSessions:(NSArray<WLIMSession *> *)sessions;
- (void)appendSessions:(NSArray<WLIMSession *> *)sessions;
- (void)removeSession:(WLIMSession *)session;
- (NSArray<WLIMSession *> *)allSessions;

@end
