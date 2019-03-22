//
//  WLLanguageCard.h
//  welike
//
//  Created by 刘斌 on 2018/4/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLLanguageCard;

@protocol WLLanguageCardDelegate <NSObject>

- (void)languageCardClicked:(WLLanguageCard *)card;

@end

@interface WLLanguageCard : UIControl

@property (nonatomic, copy) NSString *languageType;
@property (nonatomic, weak) id<WLLanguageCardDelegate> delegate;

- (id)initWithFrame:(CGRect)frame icon:(UIImage *)icon language:(NSString *)language;

- (void)setSelected:(BOOL)selected;

@end
