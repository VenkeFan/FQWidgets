//
//  WLVideoPost.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPostBase.h"

@interface WLVideoPost : WLPostBase

@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *videoSite;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger width;

@property (nonatomic, assign, readonly) NSInteger thumbnailWidth;
@property (nonatomic, assign, readonly) NSInteger thumbnailHeight;

- (void)calculatePicThumbnailInfoWithWidth:(CGFloat)width;

@end
