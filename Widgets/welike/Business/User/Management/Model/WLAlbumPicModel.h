//
//  WLAlbumPicModel.h
//  welike
//
//  Created by fan qi on 2018/12/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLPicInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface WLAlbumPicModel : WLPicInfo

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *originalImageUrl;
@property (nonatomic, copy) NSString *waterMarkUrl;
@property (nonatomic, assign) long long created;
@property (nonatomic, strong) NSDictionary *content;
@property (nonatomic, copy) NSString *createdMonth;
@property (nonatomic, copy) NSString *postID;
@property (nonatomic, copy) NSString *postContent;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, strong) UIImage *thumbImg;

+ (instancetype)parseWithNetworkJson:(NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
