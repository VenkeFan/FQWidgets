//
//  WLSettingDataSourceItem.h
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLSettingDataSourceItem : NSObject

@property (nonatomic, copy) NSString *iconResId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *rightContent;
@property (nonatomic, assign) NSInteger badgeNum;
@property (nonatomic, assign) BOOL enableNavMark;
@property (nonatomic, assign) BOOL isTail;
@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, copy) NSString *settingTag;

@end
