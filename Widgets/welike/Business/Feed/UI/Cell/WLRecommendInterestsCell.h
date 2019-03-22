//
//  WLRecommendInterestsCell.h
//  welike
//
//  Created by fan qi on 2018/7/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLRecommendInterestsCell;

@protocol WLRecommendInterestsCellDelegate <NSObject>

- (void)interestsCell:(WLRecommendInterestsCell *)cell didSelectedItems:(NSArray *)selectedItems;
- (void)interestsCellDidClosed:(WLRecommendInterestsCell *)cell;

@end

@interface WLRecommendInterestsCell : UITableViewCell

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, weak) id<WLRecommendInterestsCellDelegate> delegate;

+ (CGFloat)height;

@end
