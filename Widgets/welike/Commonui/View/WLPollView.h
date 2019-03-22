//
//  WLPollView.h
//  welike
//
//  Created by fan qi on 2018/10/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLPollPost, WLPollView;

NS_ASSUME_NONNULL_BEGIN

@protocol WLPollViewDelegate <NSObject>

- (void)pollView:(WLPollView *)pollView didPolled:(WLPollPost *)polledModel;

@end

@interface WLPollView : UIView

- (void)setPollModel:(WLPollPost *)pollModel
           viewWidth:(CGFloat)viewWidth
          viewHeight:(CGFloat)viewHeight
      imgCellSpacing:(CGFloat)imgCellSpacing
        noImgSpacing:(CGFloat)noImgSpacing;

@property (nonatomic, weak) id<WLPollViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
