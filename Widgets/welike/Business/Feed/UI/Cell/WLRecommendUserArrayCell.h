//
//  WLRecommendUserArrayCell.h
//  welike
//
//  Created by fan qi on 2018/12/3.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLUser, WLRecommendUserArrayCell;

#define kWLRecommendUserArrayCellHeight         266.0

@protocol WLRecommendUserArrayCellDelegate <NSObject>

- (void)recommendUserArrayCell:(WLRecommendUserArrayCell *)tbCell didClickedClose:(WLUser *)userModel;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WLRecommendUserArrayCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray<WLUser *> *cellDataArray;
@property (nonatomic, weak) id<WLRecommendUserArrayCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
