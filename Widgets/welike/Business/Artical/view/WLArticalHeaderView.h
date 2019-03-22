//
//  WLArticalHeaderView.h
//  welike
//
//  Created by gyb on 2019/1/19.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WLArticalPostModel;
@class WLArticalShareView;
@interface WLArticalHeaderView : UIView
{
    UILabel *tltleLabel;
    UILabel *secondaryTitleLabel;
    
    
    UIImageView *dotLine;
    
    UILabel *shareLabel;
    
    WLArticalShareView *shareView;
}

@property (strong,nonatomic) WLArticalPostModel *postBase;


@end

NS_ASSUME_NONNULL_END
