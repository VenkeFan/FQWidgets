//
//  WLRegisterSugUserDataSourceItem.h
//  welike
//
//  Created by 刘斌 on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLRegisterSugUserDataSourceItem : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *head;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *intro;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, readonly) CGFloat height;

@end
