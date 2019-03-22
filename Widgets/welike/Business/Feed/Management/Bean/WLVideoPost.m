//
//  WLVideoPost.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLVideoPost.h"

@interface WLVideoPost ()

@property (nonatomic, assign, readwrite) NSInteger thumbnailWidth;
@property (nonatomic, assign, readwrite) NSInteger thumbnailHeight;

@end

@implementation WLVideoPost

- (id)init
{
    self = [super init];
    if (self)
    {
        self.type = WELIKE_POST_TYPE_VIDEO;
    }
    return self;
}

- (void)calculatePicThumbnailInfoWithWidth:(CGFloat)width {
    [self thumbnailInfo3:width];
}

#pragma mark - Private

- (void)thumbnailInfo:(CGFloat)width {
    self.thumbnailWidth = width;
    self.thumbnailHeight = width * 9 / 16.0;
}

- (void)thumbnailInfo2:(CGFloat)width {
    if (self.height == 0 || self.width == 0) {
        self.thumbnailWidth = width;
        self.thumbnailHeight = width * 9 / 16.0;
        return;
    }
    CGFloat ratio = self.height / (CGFloat)self.width;
    CGFloat scale = 3 / 4.0;
    
    if (ratio == 1.0) {
        self.thumbnailWidth = self.thumbnailHeight = width * scale;
    } else if (ratio < 1.0) {
        if (ratio < 9 / 16.0) {
            self.thumbnailHeight = width * (9 / 16.0);
            self.thumbnailWidth = width;
        } else if (ratio > 3 / 4.0) {
            self.thumbnailHeight = width * scale;
            self.thumbnailWidth = self.width / (float)self.height * self.thumbnailHeight;
        } else {
            self.thumbnailWidth = width;
            self.thumbnailHeight = ratio * self.thumbnailWidth;
        }
    } else {
        if (ratio > 3 / 2.0) {
            self.thumbnailWidth = width * scale;
            self.thumbnailHeight = self.thumbnailWidth * 3 / 2.0;
        } else {
            self.thumbnailWidth = width * scale;
            self.thumbnailHeight = ratio * self.thumbnailWidth;
        }
    }
}

- (void)thumbnailInfo3:(CGFloat)width {
    if (self.height == 0 || self.width == 0) {
        self.thumbnailWidth = width;
        self.thumbnailHeight = width * 9 / 16.0;
        return;
    }
    CGFloat ratio = self.height / (CGFloat)self.width;
    
    if (ratio == 1.0) {
        self.thumbnailWidth = self.thumbnailHeight = width;
    } else if (ratio < 1.0) {
        if (ratio < 1 / 2.0) {
            self.thumbnailWidth = width;
            self.thumbnailHeight = width * (1 / 2.0);
        } else {
            self.thumbnailWidth = width;
            self.thumbnailHeight = ratio * self.thumbnailWidth;
        }
    } else {
        if (ratio > 4 / 3.0) {
            self.thumbnailWidth = width;
            self.thumbnailHeight = self.thumbnailWidth * 4 / 3.0;
        } else {
            self.thumbnailWidth = width;
            self.thumbnailHeight = ratio * self.thumbnailWidth;
        }
    }
}

@end
