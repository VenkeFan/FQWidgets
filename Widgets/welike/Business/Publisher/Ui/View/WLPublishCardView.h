//
//  WLPublishCardView.h
//  welike
//
//  Created by gyb on 2018/5/18.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYLabel;
@class WLPostBase;
@interface WLPublishCardView : UIView
{
    UIImageView *thumbImageView;
    
    UILabel *nameLabel;
    
    TYLabel *contentLabel;
    
      UIImageView *playFlag;
}


@property (strong,nonatomic) WLPostBase *postBase;

@end
