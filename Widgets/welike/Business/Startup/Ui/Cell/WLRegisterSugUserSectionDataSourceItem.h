//
//  WLRegisterSugUserSectionDataSourceItem.h
//  welike
//
//  Created by 刘斌 on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLRegisterSugUserSectionDataSourceItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, readonly) CGFloat height;

- (NSInteger)selectedUsersCount;
- (void)selectAll:(BOOL)selected;

@end
