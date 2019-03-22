//
//  WLTrendingUserScrollView.h
//  welike
//
//  Created by gyb on 2018/8/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLHeadView.h"

@interface WLTrendingUserScrollView : UIView<WLHeadViewDelegate>
{
    UIScrollView *scrollView;
}

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, weak) id target;


@end
