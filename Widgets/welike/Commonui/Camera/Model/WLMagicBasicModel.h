//
//  WLMagicBasicModel.h
//  welike
//
//  Created by fan qi on 2018/11/27.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WLMagicBasicModelType) {
    WLMagicBasicModelType_Unknown,
    WLMagicBasicModelType_Filter,
    WLMagicBasicModelType_Paster
};

@interface WLMagicBasicModel : NSObject

@property (nonatomic, assign) WLMagicBasicModelType type;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, copy) NSString *resourceUrl;
@property (nonatomic, assign, getter=isOnline) BOOL online;

@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, assign, getter=isDownloaded, readonly) BOOL downloaded;
@property (nonatomic, assign, getter=isDownloading) BOOL downloading;
@property (nonatomic, assign) CGFloat downloadProgress;
@property (nonatomic, assign, getter=isSelected) BOOL selected;

+ (instancetype)defaultModel;
+ (instancetype)parseWithNetworkJson:(NSDictionary *)json;

@end
