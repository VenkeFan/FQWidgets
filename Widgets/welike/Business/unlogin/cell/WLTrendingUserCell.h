//
//  WLTrendingUserCell.h
//  welike
//
//  Created by gyb on 2018/8/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLTopicSearchSectionView;
@class WLTrendingUserScrollView;
@class WLTrendingUserModel;

@protocol WLTrendingUserCellDelegate <NSObject>

- (void)didSelctUser:(NSString *)userID;

@end



@interface WLTrendingUserCell : UITableViewCell
{
    WLTopicSearchSectionView *sectionView;
    WLTrendingUserScrollView *trendingUserScrollView;
}

@property (strong,nonatomic) WLTrendingUserModel *trendingUserModel;

@property (nonatomic, weak) id<WLTrendingUserCellDelegate> delegate;


@end
