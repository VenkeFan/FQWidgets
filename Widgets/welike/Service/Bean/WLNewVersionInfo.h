//
//  WLNewVersionInfo.h
//  welike
//
//  Created by gyb on 2018/10/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UpdateType) {
    UpdateWithNoPrompt = 0,
    UpdateWithChoice = 1,
    ForceUpdate = 2
};



@interface WLNewVersionInfo : NSObject

@property (nonatomic, copy) NSString *versionId;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *operationSystem;
@property (nonatomic, assign) UpdateType updateType;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *updateTitle;
@property (nonatomic, copy) NSString *updateContent;

+ (WLNewVersionInfo *)parseVersionInfo:(NSDictionary *)info;

@end

