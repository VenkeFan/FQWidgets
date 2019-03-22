//
//  WLGuideTopVIew.h
//  welike
//
//  Created by gyb on 2018/8/6.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIPageView.h"


@class KIPageView;
@interface WLGuideTopVIew : UIView<KIPageViewDelegate>
{
    KIPageView *pageView;
    
      UIPageControl *pageControl;
}


@property (nonatomic,strong) NSArray *titleArray;
@property (nonatomic,strong) NSArray *desArray;
@property (nonatomic,strong) NSArray *animationFileArray;



- (instancetype)initWithFrame:(CGRect)frame withTitleArray:(NSArray *)titleArray;

@end
