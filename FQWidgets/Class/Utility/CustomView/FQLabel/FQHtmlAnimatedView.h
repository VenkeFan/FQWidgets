//
//  FQHtmlAnimatedView.h
//  FQWidgets
//
//  Created by fan qi on 2019/3/11.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLAnimatedImage;

@interface FQHtmlAnimatedView : UIView

@property (nonatomic, strong) FLAnimatedImage *animatedImage;

@end

@interface FQHtmlAnimatedViewManager : NSObject

@property (nonatomic, strong) FQHtmlAnimatedView *animatedView;
@property (nonatomic, strong) FLAnimatedImage *animatedImage;
@property (nonatomic, assign) CGRect frame;

@end
