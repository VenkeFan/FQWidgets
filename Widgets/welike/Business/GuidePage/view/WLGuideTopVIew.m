//
//  WLGuideTopVIew.m
//  welike
//
//  Created by gyb on 2018/8/6.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLGuideTopVIew.h"
#import "LOTAnimationView.h"


@implementation WLGuideTopVIew

- (instancetype)initWithFrame:(CGRect)frame withTitleArray:(NSArray *)titleArray {
    if (self = [super initWithFrame:frame]) {
        
        pageView = [[KIPageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width *titleArray.count, frame.size.height)];
        [pageView setBackgroundColor:[UIColor whiteColor]];
        [pageView setDelegate:self];
        [pageView setCellMargin:10];
        [pageView flipOverWithTime:3];
        [self addSubview:pageView];
        
        _titleArray = [NSArray arrayWithArray:titleArray];
        
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];//Make((kScreenWidth - 80)/2.0, guideTopVIew.height - 20, 80, 10)];
        pageControl.backgroundColor = [UIColor clearColor];
        pageControl.numberOfPages = 5;
        pageControl.currentPage = 0;
        pageControl.pageIndicatorTintColor = kUIColorFromRGBA(0xFF9300, 0.2);
        pageControl.currentPageIndicatorTintColor = kMainColor;
        pageControl.hidesForSinglePage = YES;
        pageControl.enabled = NO;
        [self addSubview:pageControl];
        CGSize pageControlSize = [pageControl sizeForNumberOfPages:5];
        pageControl.frame = CGRectMake((kScreenWidth - pageControlSize.width)/2.0, self.height - 20, pageControlSize.width, 10);
        
    }
    return self;
}


#pragma mark - KIPageViewDelegate
- (NSInteger)numberOfCellsInPageView:(KIPageView *)pageView {
    return _titleArray.count;
}

- (KIPageViewCell *)pageView:(KIPageView *)pageView cellAtIndex:(NSInteger)index {
    static NSString *PAGE_VIEW_CELL_IDENTIFIER = @"PageViewCell";
    
    KIPageViewCell *pageViewCell = [pageView dequeueReusableCellWithIdentifier:PAGE_VIEW_CELL_IDENTIFIER];
    UILabel *titleLabel = (UILabel *)[pageViewCell viewWithTag:1001];
    UILabel *descriptionLabel = (UILabel *)[pageViewCell viewWithTag:1002];
    LOTAnimationView *animationView = (LOTAnimationView *)[pageViewCell viewWithTag:1004];
    UIImageView *imageView = [pageViewCell viewWithTag:1003];
    
    if (pageViewCell == nil) {
        pageViewCell = [[KIPageViewCell alloc] initWithIdentifier:PAGE_VIEW_CELL_IDENTIFIER];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 256)/2.0,  (kScreenWidth == 320)?20:64, 256, 80)];
        [titleLabel setTextColor:kNameFontColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = kBoldFont(32);
        titleLabel.numberOfLines = 2;
        [titleLabel setTag:1001];
//        titleLabel.backgroundColor = [UIColor greenColor];
        [pageViewCell addSubview:titleLabel];
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 295)/2.0, titleLabel.bottom + 8, 295, 40)];
        [descriptionLabel setTextColor:[UIColor blackColor]];
        descriptionLabel.font = kRegularFont(16);
        descriptionLabel.textColor = kSettingRightContentFontColor;
        [descriptionLabel setTag:1002];
        descriptionLabel.numberOfLines = 2;
//        descriptionLabel.backgroundColor = [UIColor redColor];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        [pageViewCell addSubview:descriptionLabel];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = 1003;
        [pageViewCell addSubview:imageView];
        
        animationView = [[LOTAnimationView alloc] initWithFrame:CGRectZero];
        animationView.contentMode = UIViewContentModeScaleAspectFill;
//        [animationView setBackgroundColor:[UIColor blueColor]];
        [animationView setTag:1004];
        [pageViewCell addSubview:animationView];
    }
 //   [pageViewCell setBackgroundColor:[UIColor redColor]];
    
    if (index < _titleArray.count)
    {
          [titleLabel setText:_titleArray[index]];
    }
    else
    {
        titleLabel.text = nil;
    }
    
    if (index < _desArray.count)
    {
        [descriptionLabel setText:_desArray[index]];
    }
    else
    {
        descriptionLabel.text = nil;
    }
    
    if (index == 0)
    {
        animationView.frame = CGRectZero;
        
        imageView.frame = CGRectMake((kScreenWidth - 190)/2.0, descriptionLabel.bottom + 45, 190, 130);
        imageView.image = [AppContext getImageForKey:@"guide_version"];
    }
    
    if (index == 1)
    {
          imageView.frame = CGRectZero;
        animationView.frame = CGRectMake((kScreenWidth - 239)/2.0, titleLabel.bottom + 37, 239, 170);
        [animationView setAnimationNamed:@"guild_1"];
        
        [animationView play];
    }
    
    if (index == 2)
    {
           imageView.frame = CGRectZero;
            animationView.frame = CGRectMake((kScreenWidth - 270)/2.0, titleLabel.bottom + 37, 270, 250);
           [animationView setAnimationNamed:@"guild_2"];
           [animationView play];
    }
    
    if (index == 3)
    {
        imageView.frame = CGRectZero;
        animationView.frame = CGRectMake((kScreenWidth - 243)/2.0, titleLabel.bottom + 37, 243, 178);
        [animationView setAnimationNamed:@"guild_3"];
        [animationView play];
    }
    
    if (index == 4)
    {
           imageView.frame = CGRectZero;
        animationView.frame = CGRectMake((kScreenWidth - 260)/2.0, titleLabel.bottom + 37, 260, 180);
        [animationView setAnimationNamed:@"guild_4"];
          [animationView play];
    }
    
    return pageViewCell;
}

- (void)pageView:(KIPageView *)pageView didDisplayPage:(NSInteger)pageIndex {
   // NSLog(@"didDisplayPage %ld", pageIndex);
    
        pageControl.currentPage = pageIndex;
}

- (void)pageView:(KIPageView *)pageView didEndDisplayingPage:(NSInteger)pageIndex {
   // NSLog(@"didEndDisplayingPage %ld", pageIndex);
}

- (void)pageView:(KIPageView *)pageView didSelectedCellAtIndex:(NSInteger)index {
   // NSLog(@"选中了第 %ld 项", index);
}

- (void)pageView:(KIPageView *)pageView didDeselectedCellAtIndex:(NSInteger)index {
   // NSLog(@"取消选中 %ld", index);
}






@end
