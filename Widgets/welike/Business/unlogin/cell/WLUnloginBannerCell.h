//
//  WLUnloginBannerCell.h
//  welike
//
//  Created by gyb on 2018/8/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWCarousel.h"

@protocol WLUnloginBannerCellDelegate <NSObject>

- (void)didSelctbanner:(NSString *)topicID;

@end


@interface WLUnloginBannerCell : UITableViewCell<CWCarouselDatasource, CWCarouselDelegate>

@property (strong,nonatomic) NSArray *banners;
@property (weak,nonatomic) id<WLUnloginBannerCellDelegate> delegate;

@property (nonatomic, strong) CWCarousel *carousel;

@end
