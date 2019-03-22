//
//  WLTrendingUserScrollView.m
//  welike
//
//  Created by gyb on 2018/8/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrendingUserScrollView.h"
#import "WLHeadView.h"
#import "WLUser.h"


@implementation WLTrendingUserScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.scrollView];
    }
    return self;
}


-(void)setDataArray:(NSMutableArray *)dataArray
{
    _dataArray = dataArray;
    
    for (int i = 0; i < dataArray.count; i++)
    {
        WLUser *user = (WLUser *)dataArray[i];
        
        WLHeadView *imgView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        imgView.frame = CGRectMake(8 + i*16 + i*57, 0, 57, 57);
        imgView.userInteractionEnabled = YES;
        imgView.user = user;
        imgView.delegate = _target;
        [self.scrollView addSubview:imgView];
    }
    scrollView.contentSize = CGSizeMake(57*dataArray.count + 8 + 16*dataArray.count, scrollView.height);
}




-(UIScrollView *)scrollView
{
    if (!scrollView)
    {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
    }
    
    return scrollView;
}







@end
