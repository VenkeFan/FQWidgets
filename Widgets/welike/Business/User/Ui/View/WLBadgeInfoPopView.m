//
//  WLBadgeInfoPopView.m
//  welike
//
//  Created by fan qi on 2019/2/21.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLBadgeInfoPopView.h"
#import "WLBadgeModel.h"
#import "WLRouter.h"

@interface WLBadgeInfoPopBlockView : UIView

- (void)setTitle:(NSString *)title info:(NSString *)info;

@end

@implementation WLBadgeInfoPopBlockView {
    UILabel *_titleLabel;
    UILabel *_infoLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *(^createLabel)(UIFont *, UIColor *, NSString *) = ^(UIFont *font, UIColor *txtColor, NSString *text){
            UILabel *lab = [[UILabel alloc] init];
            lab.text = text;
            lab.font = font;
            lab.textColor = txtColor;
            lab.textAlignment = NSTextAlignmentLeft;
            lab.numberOfLines = 0;
            
            return lab;
        };
        
        _titleLabel = createLabel(kBoldFont(kNameFontSize), kNameFontColor, @"");
        [self addSubview:_titleLabel];
        
        _infoLabel = createLabel(kRegularFont(kMediumNameFontSize), kBodyFontColor, @"");
        [self addSubview:_infoLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setTitle:(NSString *)title info:(NSString *)info {
    CGFloat y = 0;
    
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    y += (CGRectGetHeight(_titleLabel.frame) + 8);
    
    _infoLabel.frame = CGRectMake(0, y, CGRectGetWidth(self.frame), 0);
    _infoLabel.text = info;
    [_infoLabel sizeToFit];
    y += CGRectGetHeight(_infoLabel.frame);
    
    self.height = y;
}

@end

@interface WLBadgeInfoPopView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *separateView;
@property (nonatomic, strong) WLBadgeInfoPopBlockView *typeView;
@property (nonatomic, strong) WLBadgeInfoPopBlockView *awardView;
@property (nonatomic, strong) WLBadgeInfoPopBlockView *introView;
@property (nonatomic, strong) UIButton *btn;

@end

@implementation WLBadgeInfoPopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)]) {
        self.backgroundColor = kUIColorFromRGBA(0x000000, 0.4);
        self.alpha = 0.0;
        
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) - 40 * 2, 0);
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = kCornerRadius;
        [self addSubview:_contentView];
        
        UIImageView *accessoryView = [[UIImageView alloc] init];
        UIImage *img = [AppContext getImageForKey:@"badge_info_pop_icon"];
        accessoryView.image = img;
        accessoryView.contentMode = UIViewContentModeScaleAspectFit;
        accessoryView.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        accessoryView.center = CGPointMake(CGRectGetWidth(_contentView.frame) * 0.5, CGRectGetHeight(accessoryView.frame) * 0.5 - 40);
        [_contentView addSubview:accessoryView];
        
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 96, 96)];
        _iconView.center = CGPointMake(CGRectGetWidth(_contentView.frame) * 0.5, accessoryView.centerY);
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.clipsToBounds = YES;
        [_contentView addSubview:_iconView];
        
        UILabel *(^createLabel)(UIFont *, UIColor *, NSString *) = ^(UIFont *font, UIColor *txtColor, NSString *text){
            UILabel *lab = [[UILabel alloc] init];
            lab.text = text;
            lab.font = font;
            lab.textColor = txtColor;
            
            return lab;
        };
        
        _nameLabel = createLabel(kBoldFont(kNameFontSize), kNameFontColor, @"");
        _nameLabel.numberOfLines = 0;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:_nameLabel];
        
        _separateView = [[UIImageView alloc] initWithImage:[AppContext getImageForKey:@"badge_info_pop_separate"]];
        [_contentView addSubview:_separateView];
        
        _typeView = [[WLBadgeInfoPopBlockView alloc] init];
        [_contentView addSubview:_typeView];
        
        _awardView = [[WLBadgeInfoPopBlockView alloc] init];
        [_contentView addSubview:_awardView];
        
        _introView = [[WLBadgeInfoPopBlockView alloc] init];
        [_contentView addSubview:_introView];
        
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.backgroundColor = kMainColor;
        _btn.layer.cornerRadius = kCornerRadius;
        [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btn.titleLabel.font = kBoldFont(kNameFontSize);
        [_btn addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_btn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Public

- (void)setItemModel:(WLBadgeModel *)itemModel {
    _itemModel = itemModel;
    
    CGFloat x = 24, y = 0, width = CGRectGetWidth(self.contentView.frame) - x * 2;
    
    {
        [self.iconView fq_setImageWithURLString:itemModel.iconUrl];
        y += (CGRectGetMaxY(self.iconView.frame) + 12);
    }
    
    {
        self.nameLabel.text = itemModel.name;
        self.nameLabel.frame = CGRectMake(0, 0, width, 0);
        [self.nameLabel sizeToFit];
        self.nameLabel.center = CGPointMake(self.iconView.center.x, y + CGRectGetHeight(self.nameLabel.frame) * 0.5);
        y += (CGRectGetHeight(self.nameLabel.frame) + 12);
    }
    
    {
        [self.separateView sizeToFit];
        self.separateView.center = CGPointMake(self.iconView.center.x, y + CGRectGetHeight(self.separateView.frame) * 0.5);
        y += (CGRectGetHeight(self.separateView.frame) + 24);
    }
    
    {
        self.typeView.frame = CGRectMake(x, y, width, 0);
        NSString *typeInfo = @"";
        switch (itemModel.type) {
            case WLBadgeModelType_Social:
                typeInfo = @"Social media badge";
                break;
            case WLBadgeModelType_Verified:
                typeInfo = @"Verified badge";
                break;
            case WLBadgeModelType_Growth:
                typeInfo = @"Growth badge";
                break;
            case WLBadgeModelType_Activity:
                typeInfo = @"Activity badge";
                break;
        }
        [self.typeView setTitle:[AppContext getStringForKey:@"badges_pop_type" fileName:@"user"]
                           info:typeInfo];
        y += (CGRectGetHeight(self.typeView.frame) + 8);
    }
    
    {
        self.awardView.frame = CGRectMake(x, y, width, 0);
        [self.awardView setTitle:[AppContext getStringForKey:@"badges_pop_award" fileName:@"user"]
                            info:[self dateStrFromTimestamp:itemModel.receivedTime]];
        y += (CGRectGetHeight(self.awardView.frame) + 8);
    }
    
    {
        self.introView.frame = CGRectMake(x, y, width, 0);
        [self.introView setTitle:[AppContext getStringForKey:@"badges_pop_intro" fileName:@"user"]
                            info:itemModel.desc];
        y += (CGRectGetHeight(self.introView.frame) + 24);
    }
    
    {
        self.btn.frame = CGRectMake(12, y, CGRectGetWidth(self.contentView.frame) - 12 * 2, 40);
        if (self.itemModel.forwardUrl.length > 0) {
            [self.btn setTitle:[AppContext getStringForKey:@"badges_pop_learn_more" fileName:@"user"] forState:UIControlStateNormal];
        } else {
            [self.btn setTitle:[AppContext getStringForKey:@"badges_pop_confirm" fileName:@"user"] forState:UIControlStateNormal];
        }
        y += (CGRectGetHeight(self.btn.frame) + 16);
    }
    
    self.contentView.height = y;
    self.contentView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5);
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
    
    if (self.itemModel.forwardUrl.length > 0) {
        NSArray *array = [self.itemModel.forwardUrl componentsSeparatedByString:@"&"];
        NSMutableArray *arrayM = [NSMutableArray array];
        for (int i = 0; i < array.count; i++) {
            if ([array[i] containsString:@"topic_name="]) {
                NSRange range = [array[i] rangeOfString:@"topic_name="];
                if (range.length - range.location >= [array[i] length]) {
                    continue;
                }
                NSString *name = [array[i] substringFromIndex:range.length - range.location];
                NSString *encodingName = [name urlEncode:NSUTF8StringEncoding];
                
                NSString *newText = [array[i] stringByReplacingOccurrencesOfString:name withString:encodingName];
                [arrayM addObject:newText];
            } else {
                [arrayM addObject:array[i]];
            }
        }
        NSString *newUrl = [arrayM componentsJoinedByString:@"&"];
        
        WLRouterBuilder *builder = [WLRouterBuilder createByUri:newUrl];
        [WLRouter go:builder];
    }
}

- (NSString *)dateStrFromTimestamp:(NSTimeInterval)timestamp {
    NSString *str = [AppContext getStringForKey:@"badges_pop_not_owned" fileName:@"user"];
    if (timestamp == 0) {
        return str;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    str = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp / 1000]];
    
    return str;
}

@end
