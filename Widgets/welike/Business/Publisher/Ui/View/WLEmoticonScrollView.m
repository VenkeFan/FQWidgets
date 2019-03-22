//
//  WLEmoticonScrollView.m
//  welike
//
//  Created by gyb on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLEmoticonScrollView.h"
#import "WLEmoticonCell.h"
#import "NSTimer+WLAdd.h"

@implementation WLEmoticonScrollView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [UIView new];
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.clipsToBounds = NO;
    self.canCancelContentTouches = NO;
    self.multipleTouchEnabled = NO;
    _magnifier.image = [AppContext getImageForKey:@"emoticon_keyboard_magnifier"];
    _magnifierContent = [UIImageView new];
    _magnifierContent.size = CGSizeMake(40, 40);
    _magnifierContent.centerX = _magnifier.width / 2;
    [_magnifier addSubview:_magnifierContent];
    _magnifier.hidden = YES;
    [self addSubview:_magnifier];
    return self;
}

- (void)dealloc {
    [self endBackspaceTimer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchMoved = NO;
    WLEmoticonCell *cell = [self cellForTouches:touches];
    _currentMagnifierCell = cell;
    [self showMagnifierForCell:_currentMagnifierCell];
    
    if (cell.imageView.image && !cell.isDelete) {
        [[UIDevice currentDevice] playInputClick];
    }
    
    if (cell.isDelete) {
        [self endBackspaceTimer];
         [self performSelector:@selector(startBackspaceTimer) withObject:nil afterDelay:0.5];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchMoved = YES;
    if (_currentMagnifierCell && _currentMagnifierCell.isDelete) return;
    
    WLEmoticonCell *cell = [self cellForTouches:touches];
    if (cell != _currentMagnifierCell) {
        if (!_currentMagnifierCell.isDelete && !cell.isDelete) {
            _currentMagnifierCell = cell;
        }
        [self showMagnifierForCell:cell];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    WLEmoticonCell *cell = [self cellForTouches:touches];
    if ((!_currentMagnifierCell.isDelete && cell.emoticonStr.length > 0) || (!_touchMoved && cell.isDelete)) {
        if ([self.delegate respondsToSelector:@selector(emoticonScrollViewDidTapCell:)]) {
            [((id<WLEmoticonScrollViewDelegate>) self.delegate) emoticonScrollViewDidTapCell:cell];
        }
    }
    [self hideMagnifier];
    [self endBackspaceTimer];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideMagnifier];
    [self endBackspaceTimer];
}

- (WLEmoticonCell *)cellForTouches:(NSSet<UITouch *> *)touches {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    if (indexPath) {
        WLEmoticonCell *cell = (id)[self cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (void)showMagnifierForCell:(WLEmoticonCell *)cell {
    if (cell.isDelete || !cell.imageView.image) {
        [self hideMagnifier];
        return;
    }
    CGRect rect = [cell convertRect:cell.bounds toView:self];
    _magnifier.centerX = CGRectGetMidX(rect);
    _magnifier.bottom = CGRectGetMaxY(rect) - 9;
    _magnifier.hidden = NO;
    
    _magnifierContent.image = cell.imageView.image;
    _magnifierContent.top = 20;
    
    [_magnifierContent.layer removeAllAnimations];
    NSTimeInterval dur = 0.1;
    [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self->_magnifierContent.top = 3;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self->_magnifierContent.top = 6;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self->_magnifierContent.top = 5;
            } completion:^(BOOL finished) {
            }];
        }];
    }];
}

- (void)hideMagnifier {
    _magnifier.hidden = YES;
}

- (void)startBackspaceTimer {
    [self endBackspaceTimer];
   // @weakify(self);
    _backspaceTimer = [NSTimer timerWithTimeInterval:0.1 block:^(NSTimer *timer) {
     //   @strongify(self);
        if (!self) return;
        WLEmoticonCell *cell = self->_currentMagnifierCell;
        if (cell.isDelete) {
            if ([self.delegate respondsToSelector:@selector(emoticonScrollViewDidTapCell:)]) {
                [[UIDevice currentDevice] playInputClick];
                [((id<WLEmoticonScrollViewDelegate>) self.delegate) emoticonScrollViewDidTapCell:cell];
            }
        }
    } repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_backspaceTimer forMode:NSRunLoopCommonModes];
}

- (void)endBackspaceTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startBackspaceTimer) object:nil];
    [_backspaceTimer invalidate];
    _backspaceTimer = nil;
}


@end
