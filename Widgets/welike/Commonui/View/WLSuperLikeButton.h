//
//  WLSuperLikeButton.h
//  welike
//
//  Created by luxing on 2018/6/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLSingleContentManager.h"

@class WLSuperLikeButton;

@protocol WLSuperLikeButtonDelegate<NSObject>

- (void)superLikeButton:(WLSuperLikeButton *)button expCount:(long long)count;

@end  

@interface WLSuperLikeButton : UIButton

@property (nonatomic, weak) id<WLSuperLikeButtonDelegate> delegate;
@property (nonatomic, assign) NSUInteger expCount;
@property (nonatomic, assign) BOOL isDetail;

- (void)changeLikeImageWithExp:(NSUInteger)count;

@end
