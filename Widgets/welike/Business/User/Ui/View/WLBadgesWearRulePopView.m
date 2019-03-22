//
//  WLBadgesWearRulePopView.m
//  welike
//
//  Created by fan qi on 2019/2/23.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLBadgesWearRulePopView.h"

@interface WLBadgesWearRulePopView ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation WLBadgesWearRulePopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)]) {
        self.backgroundColor = kUIColorFromRGBA(0x000000, 0.4);
        self.alpha = 0.0;
        
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) - 40 * 2, 380);
        _contentView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5);
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = kCornerRadius;
        [self addSubview:_contentView];
        
        CGFloat x = 24, y = 24;
        CGFloat width = CGRectGetWidth(_contentView.frame) - x * 2;
        CGFloat bottom = 16;
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.frame = CGRectMake(x, y, width, 0);
        titleLab.text = @"Badge wearing instructions";
        titleLab.textColor = kNameFontColor;
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = kBoldFont(18.0);
        titleLab.numberOfLines = 0;
        [titleLab sizeToFit];
        titleLab.center = CGPointMake(CGRectGetWidth(_contentView.frame) * 0.5, y + CGRectGetHeight(titleLab.frame) * 0.5);
        [_contentView addSubview:titleLab];
        y += (CGRectGetHeight(titleLab.frame) + bottom);
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, width, 40);
        btn.center = CGPointMake(CGRectGetWidth(_contentView.frame) * 0.5, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(btn.frame) * 0.5 - bottom);
        btn.backgroundColor = kMainColor;
        btn.layer.cornerRadius = kCornerRadius;
        [btn setTitle:[AppContext getStringForKey:@"badges_pop_confirm" fileName:@"user"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = kBoldFont(kNameFontSize);
        [btn addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:btn];
        
        NSString *text = [AppContext getStringForKey:@"badges_wear_rule" fileName:@"user"];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
        [attrStr setAttributes:@{NSForegroundColorAttributeName: kBodyFontColor,
                                 NSFontAttributeName: kRegularFont(kBodyFontSize)}
                         range:NSMakeRange(0, text.length)];
        
        NSRegularExpression *regular = [NSRegularExpression
                                        regularExpressionWithPattern:@".*?(\\[).*?(\\]).*?"
                                        options:NSRegularExpressionCaseInsensitive
                                        error:nil];
        NSArray<NSTextCheckingResult *> *resultArray = [regular matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        for (NSInteger i = resultArray.count - 1; i >= 0 ; i--) {
            NSString *subStr = [text substringWithRange:resultArray[i].range];
            subStr = [subStr stringByReplacingOccurrencesOfString:@"[" withString:@""];
            subStr = [subStr stringByReplacingOccurrencesOfString:@"]" withString:@""];
            
            [attrStr replaceCharactersInRange:resultArray[i].range
                         withAttributedString:[[NSAttributedString alloc] initWithString:subStr ?: @"" attributes:@{NSForegroundColorAttributeName: kNameFontColor,
                                                                                                             NSFontAttributeName: kBoldFont(kNameFontSize)}]];
        }
        
        UITextView *txtView = [[UITextView alloc] init];
        txtView.backgroundColor = [UIColor clearColor];
        txtView.editable = NO;
        txtView.frame = CGRectMake(x, y, width, CGRectGetHeight(_contentView.frame) - y - CGRectGetHeight(btn.frame) - bottom - 12);
        txtView.attributedText = attrStr;
        [_contentView addSubview:txtView];
    }
    return self;
}

- (void)show {
    [kCurrentWindow addSubview:self];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 1.0;
                     }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark - Hander

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:self];
    if (!CGRectContainsPoint(self.contentView.frame, point)) {
        [self dismiss];
    }
}

#pragma mark -

- (void)btnClicked {
    [self dismiss];
}

@end
