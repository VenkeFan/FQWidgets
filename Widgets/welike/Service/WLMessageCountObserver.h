//
//  WLMessageCountObserver.h
//  welike
//
//  Created by 刘斌 on 2018/5/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WLMessageCountObserverDelegate <NSObject>

- (void)messagesCountChanged:(BOOL)has;

@end

@interface WLMessageCountObserver : NSObject

- (void)registerDelegate:(id<WLMessageCountObserverDelegate>)delegate;
- (void)unregister:(id<WLMessageCountObserverDelegate>)delegate;

- (void)refresh;
- (void)loadFromLocal;

@end
