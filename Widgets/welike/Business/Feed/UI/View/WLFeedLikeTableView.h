//
//  WLFeedLikeTableView.h
//  welike
//
//  Created by fan qi on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLScrollViewCell.h"

@class WLFeedLikeTableView;

@protocol WLFeedLikeTableViewDelegate <NSObject>

- (void)feedLikeTableView:(WLFeedLikeTableView *)view didSelectedWithUserID:(NSString *)userID;

@end

@interface WLFeedLikeTableView : WLScrollContentView

@property (nonatomic, copy) NSString *pid;
@property (nonatomic, weak) id<WLFeedLikeTableViewDelegate> delegate;

@end
