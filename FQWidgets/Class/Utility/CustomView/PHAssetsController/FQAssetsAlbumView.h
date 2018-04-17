//
//  FQAssetsAlbumView.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/16.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#define ContentViewHeight           kSizeScale(220)
#define TableViewHeight             kSizeScale(190)
#define DefaultRowHeight            kSizeScale(50)

@class FQAssetsAlbumView;

@protocol FQAssetsAlbumViewDelegate <NSObject>

- (void)assetsAlbumView:(FQAssetsAlbumView *)albumView didSelectedWithItemModel:(PHAssetCollection *)itemModel;
- (void)assetsAlbumViewDidDismiss:(FQAssetsAlbumView *)albumView;

@end

@interface FQAssetsAlbumView : UIView

- (instancetype)initWithDataArray:(NSArray *)dataArray;
- (void)displayWithAnimation:(void(^)(void))animation;
- (void)dismissWithAnimation:(void(^)(void))animation;

@property (nonatomic, weak) id<FQAssetsAlbumViewDelegate> delegate;
@property (nonatomic, assign, readonly, getter=isDisplayed) BOOL displayed;

@end
