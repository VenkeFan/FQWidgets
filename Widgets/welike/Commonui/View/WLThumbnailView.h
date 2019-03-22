//
//  WLThumbnailView.h
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WLPicInfo, WLPostBase;

@interface WLThumbnailView : UIView

- (void)setImages:(NSArray<WLPicInfo *> *)images
     imgViewWidth:(CGFloat)imgViewWidth
    imgViewHeight:(CGFloat)imgViewHeight
          spacing:(CGFloat)spacing;

@property (nonatomic, strong) WLPostBase *feedModel;
@property (nonatomic, copy) NSString *userName;

@end
