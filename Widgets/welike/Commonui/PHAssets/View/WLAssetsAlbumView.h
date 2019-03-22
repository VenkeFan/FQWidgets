//
//  WLAssetsAlbumView.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/16.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class WLAssetsAlbumView;

@protocol WLAssetsAlbumViewDelegate <NSObject>

- (void)assetsAlbumView:(WLAssetsAlbumView *)albumView didSelectedWithItemModel:(PHAssetCollection *)itemModel;
- (void)assetsAlbumViewDidDismiss:(WLAssetsAlbumView *)albumView;

@end

@interface WLAssetsAlbumView : UIView

- (void)displayWithAnimation:(void(^)(void))animation;
- (void)dismissWithAnimation:(void(^)(void))animation;

@property (nonatomic, weak) id<WLAssetsAlbumViewDelegate> delegate;
@property (nonatomic, copy) NSArray<PHAssetCollection *> *dataArray;
@property (nonatomic, assign, readonly, getter=isDisplayed) BOOL displayed;

@end
