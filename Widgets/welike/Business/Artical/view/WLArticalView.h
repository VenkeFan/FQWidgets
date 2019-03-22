//
//  WLArticalView.h
//  welike
//
//  Created by gyb on 2019/1/19.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WLArticalViewDelegate <NSObject>

-(void)updateArticalFrame;

-(void)tapImage:(NSInteger)indexNum;

-(void)tapVideo;

@end



@class WLArticalPostModel;
@class WLArticalHeaderView;
@class WLArticalBottomView;

@interface WLArticalView : UIView
{
    NSMutableArray *allControls;
    CGFloat contentHeight;
    WLArticalHeaderView *articalHeaderView;
    WLArticalBottomView *articalBottomView;
}

@property (nonatomic,weak) id delegate;

@property (strong,nonatomic) WLArticalPostModel *postBase;

@property (strong,nonatomic) NSMutableArray *onlyPicItems;


@end

NS_ASSUME_NONNULL_END
