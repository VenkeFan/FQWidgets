//
//  WLAlbumDetailViewController.h
//  welike
//
//  Created by fan qi on 2018/12/17.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"

@class WLAlbumPicModel;

NS_ASSUME_NONNULL_BEGIN

@interface WLAlbumDetailViewController : WLNavBarBaseViewController

@property (nonatomic, strong, readonly) WLAlbumPicModel *itemModel;
- (instancetype)initWithPicModel:(WLAlbumPicModel *)itemModel
                       itemArray:(NSArray<NSArray<WLAlbumPicModel *> *> *)itemArray;

@end

NS_ASSUME_NONNULL_END
