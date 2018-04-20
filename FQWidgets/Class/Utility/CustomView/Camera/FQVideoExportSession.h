//
//  FQVideoExportSession.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/18.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface FQVideoExportSession : NSObject

@property (nonatomic, strong, readonly) AVAsset *asset;

- (void)compressWithAsset:(AVAsset *)asset;

@end
