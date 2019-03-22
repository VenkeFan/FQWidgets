//
//  WLEmoticonInputView.h
//  welike
//
//  Created by gyb on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLEmoticonScrollView.h"


@protocol WLEmoticonInputViewDelegate <NSObject>

@optional
- (void)emoticonInputDidTapText:(NSString *)text;
- (void)emoticonInputDidTapBackspace;

@end


@class WLEmoticonScrollView;

@interface WLEmoticonInputView : UIView<UICollectionViewDelegate, UICollectionViewDataSource, UIInputViewAudioFeedback,WLEmoticonScrollViewDelegate>
{
    UIView *toolbar;
    UIButton *historyBtn;
    UIButton *emojiBtn;
    UILabel *promptLabel;
}

@property (nonatomic, weak) id<WLEmoticonInputViewDelegate> delegate;


@property (nonatomic, strong) NSArray<UIButton *> *toolbarButtons;
@property (nonatomic, strong) WLEmoticonScrollView *emoticonScrollView;
@property (nonatomic, strong) UIView *pageControl;
//@property (nonatomic, strong) NSArray<WBEmoticonGroup *> *emoticonGroups;
@property (nonatomic, strong) NSArray<NSNumber *> *emoticonGroupPageIndexs;
@property (nonatomic, strong) NSArray<NSNumber *> *emoticonGroupPageCounts;
@property (nonatomic, assign) NSInteger emoticonGroupTotalPageCount;
@property (nonatomic, assign) NSInteger currentPageIndex;


+ (instancetype)sharedView;

@end
