//
//  WLMagicEffectView.h
//  welike
//
//  Created by fan qi on 2018/11/27.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLMagicEffectView, WLMagicBasicModel;

typedef NS_ENUM(NSInteger, WLMagicEffectViewType) {
    WLMagicEffectViewType_Filter,
    WLMagicEffectViewType_Paster
};

@protocol WLMagicEffectViewDelegate <NSObject>

- (void)magicEffectView:(WLMagicEffectView *)effectView selectedModel:(WLMagicBasicModel *)selectedModel;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WLMagicEffectView : UIView

@property (nonatomic, strong) UICollectionViewFlowLayout *collectionLayout;
@property (nonatomic, assign) WLMagicEffectViewType effectType;
@property (nonatomic, weak) id<WLMagicEffectViewDelegate> delegate;

- (void)display;

- (WLMagicBasicModel *)previousFilter;
- (WLMagicBasicModel *)nextFilter;

@end

NS_ASSUME_NONNULL_END
