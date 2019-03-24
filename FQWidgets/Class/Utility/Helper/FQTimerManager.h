//
//  FQTimerManager.h
//  FQWidgets
//
//  Created by fan qi on 2019/3/24.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FQTimerManager : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL aSelector;

- (instancetype)initWithTarget:(id)target aSelector:(SEL)aSelector;

- (void)start;
- (void)pause;
- (void)shutdown;

@end
