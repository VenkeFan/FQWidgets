//
//  WLComboxView.h
//  welike
//
//  Created by fan qi on 2019/2/27.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLComboxView;

@protocol WLComboxViewDelegate <NSObject>

- (void)comboxView:(WLComboxView *)combox indexChanged:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WLComboxView : UIView

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign, readonly) BOOL displayList;
@property (nonatomic, weak) id<WLComboxViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
