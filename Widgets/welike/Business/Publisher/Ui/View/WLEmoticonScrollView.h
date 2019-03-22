//
//  WLEmoticonScrollView.h
//  welike
//
//  Created by gyb on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLEmoticonCell;


@protocol WLEmoticonScrollViewDelegate <UICollectionViewDelegate>

- (void)emoticonScrollViewDidTapCell:(WLEmoticonCell *)cell;

@end

@interface WLEmoticonScrollView : UICollectionView
{
    NSTimeInterval *_touchBeganTime;
    BOOL _touchMoved;
    UIImageView *_magnifier;
    UIImageView *_magnifierContent;
    __weak WLEmoticonCell *_currentMagnifierCell;
    NSTimer *_backspaceTimer;
}



@end
