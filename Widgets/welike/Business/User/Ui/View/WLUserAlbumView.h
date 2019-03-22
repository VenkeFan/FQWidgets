//
//  WLUserAlbumView.h
//  welike
//
//  Created by fan qi on 2018/12/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLScrollViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WLUserAlbumView : UIView <WLScrollContentViewProtocol>

@property (nonatomic, copy) NSString *userID;

@end

NS_ASSUME_NONNULL_END
