//
//  WLLinkPost.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPostBase.h"

@interface WLLinkPost : WLPostBase

@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, copy) NSString *linkTitle;
@property (nonatomic, copy) NSString *linkText;
@property (nonatomic, copy) NSString *linkThumbUrl;

@end
