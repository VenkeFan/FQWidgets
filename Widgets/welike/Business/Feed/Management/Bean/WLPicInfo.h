//
//  WLPicInfo.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WLPicInfoBadgeType) {
    WLPicInfoBadgeType_Square = 0,
    WLPicInfoBadgeType_Horizontal,
    WLPicInfoBadgeType_Horizontal_Long,
    WLPicInfoBadgeType_Vertical,
    WLPicInfoBadgeType_Vertical_Long,
    WLPicInfoBadgeType_GIF,
};

@interface WLPicInfo : NSObject

@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, copy) NSString *originalPicUrl;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger width;

@property (nonatomic, copy, readonly) NSString *thumbnailPicUrl;
@property (nonatomic, assign, readonly) NSInteger thumbnailWidth;
@property (nonatomic, assign, readonly) NSInteger thumbnailHeight;
@property (nonatomic, assign, readonly) WLPicInfoBadgeType badgeType;

- (void)calculatePicThumbnailInfoWithWidth:(CGFloat)width;

@end
