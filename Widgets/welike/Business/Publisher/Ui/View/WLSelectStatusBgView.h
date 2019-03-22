//
//  WLSelectStatusBgView.h
//  welike
//
//  Created by gyb on 2018/11/15.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLStatusInfo;

@protocol WLSelectStatusBgViewDelegate <NSObject>

//- (void)interestView:(WLPostStatusMenu *)view didRecviceItems:(NSArray *)items;
- (void)changeBg:(NSInteger)indexNum;

//- (void)interestView:(WLPostStatusMenu *)view refreshWhenIntrestErrorReload:(NSArray<WLVerticalItem *> *)items withCurrentIndex:(NSInteger)currentIndex;

@end

@interface WLSelectStatusBgView : UITableView

@property (strong,nonatomic) WLStatusInfo *statusInfo;

@property (nonatomic, weak) id<WLSelectStatusBgViewDelegate> SelectStatusBgDelegate;

-(void)changeCustomImage:(UIImage *)image;



@end
