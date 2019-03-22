//
//  WLPicInfo.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPicInfo.h"

@interface WLPicInfo ()

@property (nonatomic, copy, readwrite) NSString *thumbnailPicUrl;
@property (nonatomic, assign, readwrite) NSInteger thumbnailWidth;
@property (nonatomic, assign, readwrite) NSInteger thumbnailHeight;
@property (nonatomic, assign, readwrite) WLPicInfoBadgeType badgeType;

@end

@implementation WLPicInfo {
    NSInteger _fetchWidth;
    NSInteger _fetchHeight;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)calculatePicThumbnailInfoWithWidth:(CGFloat)width {
    [self thumbnailInfo3:width];
}

#pragma mark - Private

- (void)thumbnailInfo:(CGFloat)width {
    if (self.height == 0 || self.width == 0) {
        self.thumbnailPicUrl = self.picUrl;
        return;
    }
    CGFloat ratio = self.width / (CGFloat)self.height;
    
    if (ratio <= 1.1 && ratio >= 0.90) {
        self.thumbnailWidth = self.thumbnailHeight = width * 2 / 3.0;
        
        _fetchWidth = self.thumbnailWidth;
        _fetchHeight = self.thumbnailHeight;
        
        self.badgeType = WLPicInfoBadgeType_Square;
    } else if (ratio > 1.1) {
        if (ratio > 2.0) {
            self.thumbnailHeight = width * 0.5;
            self.thumbnailWidth = width * 2 / 3.0;
            
            _fetchHeight = self.thumbnailHeight;
            _fetchWidth = self.width / (float)self.height * _fetchHeight;
            
            self.badgeType = WLPicInfoBadgeType_Horizontal_Long;
        } else {
            self.thumbnailHeight = width * 0.5;
            self.thumbnailWidth = ratio * self.thumbnailHeight;
            
            _fetchHeight = self.thumbnailHeight;
            _fetchWidth = self.width / (float)self.height * _fetchHeight;
            
            self.badgeType = WLPicInfoBadgeType_Horizontal;
        }
    } else {
        if (ratio < 3 / 5.0) {
            self.thumbnailHeight = width * 2 / 3.0;
            self.thumbnailWidth = width * 0.5;
            
            _fetchWidth = self.thumbnailWidth;
            _fetchHeight = self.height / (float)self.width * _fetchWidth;
            
            self.badgeType = WLPicInfoBadgeType_Vertical_Long;
        } else {
            self.thumbnailHeight = width * 2 / 3.0;
            self.thumbnailWidth = ratio * self.thumbnailHeight;
            
            _fetchHeight = self.thumbnailHeight;
            _fetchWidth = self.width / (float)self.height * _fetchHeight;
            
            self.badgeType = WLPicInfoBadgeType_Vertical;
        }
    }
    
    [self getThumbnailPicUrl];
}

- (void)thumbnailInfo2:(CGFloat)width {
    if (self.height == 0 || self.width == 0) {
        self.thumbnailPicUrl = self.picUrl;
        return;
    }
    CGFloat ratio = self.height / (CGFloat)self.width;
    CGFloat scale = 3 / 4.0;
    
    if (ratio == 1.0) {
        self.thumbnailWidth = self.thumbnailHeight = width * scale;
        
        _fetchWidth = self.thumbnailWidth;
        _fetchHeight = self.thumbnailHeight;
        
        self.badgeType = WLPicInfoBadgeType_Square;
    } else if (ratio < 1.0) {
        if (ratio < 9 / 16.0) {
            self.thumbnailHeight = width * (9 / 16.0);
            self.thumbnailWidth = width;
            
            _fetchWidth = self.thumbnailWidth;
            _fetchHeight = self.height / (float)self.width * _fetchWidth;
            
            self.badgeType = WLPicInfoBadgeType_Horizontal_Long;
        } else if (ratio > 3 / 4.0) {
            self.thumbnailHeight = width * scale;
            self.thumbnailWidth = self.width / (float)self.height * self.thumbnailHeight;
            
            _fetchHeight = self.thumbnailHeight;
            _fetchWidth = self.thumbnailWidth;
            
            self.badgeType = WLPicInfoBadgeType_Horizontal;
        } else {
            self.thumbnailWidth = width;
            self.thumbnailHeight = ratio * self.thumbnailWidth;
            
            _fetchHeight = self.thumbnailHeight;
            _fetchWidth = self.thumbnailWidth;
            
            self.badgeType = WLPicInfoBadgeType_Horizontal;
        }
    } else {
        if (ratio > 3 / 2.0) {
            self.thumbnailWidth = width * scale;
            self.thumbnailHeight = self.thumbnailWidth * 3 / 2.0;
            
            self.badgeType = WLPicInfoBadgeType_Vertical_Long;
        } else {
            self.thumbnailWidth = width * scale;
            self.thumbnailHeight = ratio * self.thumbnailWidth;
            
            self.badgeType = WLPicInfoBadgeType_Vertical;
        }
        
        _fetchWidth = self.thumbnailWidth;
        _fetchHeight = self.height / (float)self.width * _fetchWidth;
    }
    
    [self getThumbnailPicUrl];
}

- (void)thumbnailInfo3:(CGFloat)width {
    if (self.height == 0 || self.width == 0) {
        self.thumbnailPicUrl = self.picUrl;
        return;
    }
    CGFloat ratio = self.height / (CGFloat)self.width;
    
    if (ratio == 1.0) {
        self.thumbnailWidth = self.thumbnailHeight = width;
        
        _fetchWidth = self.thumbnailWidth;
        _fetchHeight = self.thumbnailHeight;
        
        self.badgeType = WLPicInfoBadgeType_Square;
    } else if (ratio < 1.0) {
        if (ratio < 1 / 2.0) {
            self.thumbnailWidth = width;
            self.thumbnailHeight = width * (1 / 2.0);
            
            _fetchWidth = self.thumbnailWidth;
            _fetchHeight = self.height / (float)self.width * _fetchWidth;
            
            self.badgeType = WLPicInfoBadgeType_Horizontal_Long;
        } else {
            self.thumbnailWidth = width;
            self.thumbnailHeight = ratio * self.thumbnailWidth;
            
            _fetchHeight = self.thumbnailHeight;
            _fetchWidth = self.thumbnailWidth;
            
            self.badgeType = WLPicInfoBadgeType_Horizontal;
        }
    } else {
        if (ratio > 4 / 3.0) {
            self.thumbnailWidth = width;
            self.thumbnailHeight = self.thumbnailWidth * (4 / 3.0);
            
            self.badgeType = WLPicInfoBadgeType_Vertical_Long;
        } else {
            self.thumbnailWidth = width;
            self.thumbnailHeight = ratio * self.thumbnailWidth;
            
            self.badgeType = WLPicInfoBadgeType_Vertical;
        }
        
        _fetchWidth = self.thumbnailWidth;
        _fetchHeight = self.height / (float)self.width * _fetchWidth;
    }
    
    [self getThumbnailPicUrl];
}

- (void)getThumbnailPicUrl {
    NSString *fixStrategy = kThumbnailStrategyFixed;
    switch (self.badgeType) {
        case WLPicInfoBadgeType_Vertical:
        case WLPicInfoBadgeType_Vertical_Long:
            fixStrategy = kThumbnailStrategyLFit;
            break;
        case WLPicInfoBadgeType_Horizontal:
        case WLPicInfoBadgeType_Horizontal_Long:
            fixStrategy = kThumbnailStrategyMFit;
            break;
        default:
            break;
    }
    
    CGFloat width = _fetchWidth * [UIScreen mainScreen].scale;
    CGFloat height = _fetchHeight * [UIScreen mainScreen].scale;

    _fetchWidth = width > self.width ? _fetchWidth : width;
    _fetchHeight = height > self.height ? _fetchHeight : height;
    
    self.thumbnailPicUrl = [LuuUtils getThumbnailPicUrl:self.picUrl
                                               strategy:fixStrategy
                                                  width:(long)_fetchWidth
                                                 height:(long)_fetchHeight];
}

@end
