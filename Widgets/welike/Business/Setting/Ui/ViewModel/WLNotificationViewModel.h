//
//  WLNotificationViewModel.h
//  welike
//
//  Created by luxing on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLPushSetting.h"

@interface WLNotificationViewModel : NSObject

- (NSInteger)sectionCount;

- (NSInteger)rowCoutInSection:(NSUInteger)section;

- (id)itemDataAtRow:(NSUInteger)row inSection:(NSUInteger)section;

- (NSString *)sectionTitle:(NSUInteger)section;

- (void)setSwitchVal:(BOOL)val forKey:(NSString*)key;

- (void)setTail:(BOOL)tail forKey:(NSString*)key;

- (void)refresh:(WLPushSetting *)setting;

@end
