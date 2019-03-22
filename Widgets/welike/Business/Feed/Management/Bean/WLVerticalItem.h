//
//  WLVerticalItem.h
//  welike
//
//  Created by gyb on 2018/7/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLVerticalItem : NSObject

@property (nonatomic, copy) NSString *verticalId;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, assign) NSInteger labelOrder;
@property (nonatomic, assign) BOOL isSelected;

+ (WLVerticalItem *)parseFromNetworkJSON:(NSDictionary *)json;

@end
