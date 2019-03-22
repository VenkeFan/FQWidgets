//
//  WLSugResult.h
//  welike
//
//  Created by 刘斌 on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WELIKE_SUG_RESULT_TYPE)
{
    WELIKE_SUG_RESULT_TYPE_HIS = 0,
    WELIKE_SUG_RESULT_TYPE_SUG
};

typedef NS_ENUM(NSInteger, WELIKE_SUG_RESULT_CATEGORY)
{
    WELIKE_SUG_RESULT_CATEGORY_KEYWORD = 0,
    WELIKE_SUG_RESULT_CATEGORY_USER
};

@interface WLSugResult : NSObject

@property (nonatomic, assign) WELIKE_SUG_RESULT_TYPE type;
@property (nonatomic, assign) WELIKE_SUG_RESULT_CATEGORY category;
@property (nonatomic, strong) id object;

@end
