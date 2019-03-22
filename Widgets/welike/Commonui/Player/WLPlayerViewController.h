//
//  WLPlayerViewController.h
//  welike
//
//  Created by fan qi on 2018/6/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseViewController.h"

extern NSString * const kWLPlayerVideoSite;

@class AVAsset;

@interface WLPlayerViewController : RDBaseViewController

- (instancetype)initWithURLString:(NSString *)urlString videoSite:(NSString *)videoSite;
- (instancetype)initWithURLString:(NSString *)urlString;
- (instancetype)initWithAsset:(AVAsset *)asset;

@end
