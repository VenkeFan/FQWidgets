//
//  WLProfileViewModel.h
//  welike
//
//  Created by fan qi on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLAccountManager.h"

@class WLSettingDataSourceItem;
@interface WLProfileViewModel : NSObject
{
    WLSettingDataSourceItem *draftItem;
}

@property (nonatomic, strong) WLAccount *account;
@property (nonatomic, copy, readonly) NSArray<NSArray *> *dataArray;
@property (nonatomic, assign) NSInteger draftNum;


@end
