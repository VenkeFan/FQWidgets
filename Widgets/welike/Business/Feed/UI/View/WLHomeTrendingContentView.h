//
//  WLHomeTrendingContentView.h
//  welike
//
//  Created by fan qi on 2018/12/19.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLInterestFeedTableView;

NS_ASSUME_NONNULL_BEGIN

@interface WLHomeTrendingContentView : UIView

@property (nonatomic, strong, readonly) NSMutableArray<WLInterestFeedTableView *> *subFeedViews;
@property (nonatomic, assign, readonly) NSInteger currentIndex;

@end

NS_ASSUME_NONNULL_END
