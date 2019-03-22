//
//  WLDiscoverTableView.h
//  welike
//
//  Created by gyb on 2018/8/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBasicTableView.h"

@protocol WLDiscoverTableViewDelegate <NSObject>

- (void)didSelectTrendingUserCell:(NSString *)urlStr;

@end


@interface WLDiscoverTableView : WLBasicTableView<UIGestureRecognizerDelegate>


@property (nonatomic,copy) void(^scrollOffsetYChange)(CGFloat value);
@property (nonatomic,copy) void(^didSelectTrendingUserCell)(NSString* urlStr);
@property (nonatomic,copy) void(^didSelectBanner)(NSString* topicID);
@property (nonatomic,copy) void(^didSelectSearchKey)(NSString* keyStr);
@property (nonatomic,copy) void(^didSelectUser)(NSString* userID);


- (void)display;


-(void)closeView;


-(void)viewAppear;

@end
