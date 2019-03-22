//
//  WLBadgesWearView.h
//  welike
//
//  Created by fan qi on 2019/2/22.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLBadgesWearView, WLBadgeModel;

@protocol WLBadgesWearViewDelegate <NSObject>

- (void)badgesWearView:(WLBadgesWearView *)wearView editing:(BOOL)editing;
- (void)badgesWearView:(WLBadgesWearView *)wearView
          selectedView:(UIView *)selectedView
         selectedModel:(WLBadgeModel *)selectedModel
                 index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WLBadgesWearView : UIView

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, weak) id<WLBadgesWearViewDelegate> delegate;
@property (nonatomic, assign) BOOL editing;

- (void)changeOldBadge:(WLBadgeModel *)oldBadge
              newBadge:(WLBadgeModel *)newbadge
                 index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
