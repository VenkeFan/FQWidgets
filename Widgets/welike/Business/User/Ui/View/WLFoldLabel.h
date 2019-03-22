//
//  WLFoldLabel.h
//  welike
//
//  Created by fan qi on 2019/2/25.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLFoldLabel;

@protocol WLFoldLabelDelegate <NSObject>

- (void)foldLabelDidTapped:(WLFoldLabel *)label;
- (void)foldLabel:(WLFoldLabel *)label oldHeight:(CGFloat)oldHeight newHeight:(CGFloat)newHeight;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WLFoldLabel : UIView

@property (nonatomic, assign) NSInteger minNumberOfLines;
@property (nonatomic, strong) NSAttributedString *attributedText;

@property (nonatomic, weak) id<WLFoldLabelDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
