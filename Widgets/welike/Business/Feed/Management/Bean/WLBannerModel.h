//
//  WLBannerModel.h
//  welike
//
//  Created by fan qi on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLBannerModel : NSObject

@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *lang;

+ (WLBannerModel *)parseFromNetworkJSON:(NSDictionary *)json;

@end
