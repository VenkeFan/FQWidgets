//
//  WLLocationTopView.h
//  welike
//
//  Created by gyb on 2018/5/31.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kWLTopicInfoContentHeight           120

@class WLLocationDetail;

@protocol WLLocationTopViewDelegate <NSObject>

- (void)didClickedUsers;

@end


@interface WLLocationTopView : UIView
{
    UIImageView *bgImgView;
    CALayer *shadeLayer;
//    CATextLayer *titleLayer;
    UILabel *placeLabel;
    CATextLayer *useountLayer;
    UIView *usersView;
    
    UIImageView *locationFlagView;
}

@property (nonatomic, strong) WLLocationDetail *locationDetail;
@property (nonatomic, copy) NSArray *userArray;
@property (nonatomic, weak) id<WLLocationTopViewDelegate> delegate;

@end
