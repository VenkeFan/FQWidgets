//
//  WLStatusInfo.h
//  welike
//
//  Created by gyb on 2018/11/15.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLStatusInfo : NSObject

@property (copy, nonatomic) NSString *topic;
@property (copy, nonatomic) NSString *text;
@property (strong, nonatomic) NSMutableArray *picUrlList;
@property (strong, nonatomic) NSMutableArray *contentList;
@property (copy, nonatomic) NSString *idStr;
@property (nonatomic, assign) BOOL isSelected;

+ (WLStatusInfo *)parseFromNetworkJSON:(NSDictionary *)json;

@end

