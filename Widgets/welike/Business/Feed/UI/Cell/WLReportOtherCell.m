//
//  WLReportOtherCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLReportOtherCell.h"

#define kReportOtherCellSelSize               20.f
#define kReportOtherCellTopMargin             15.f
#define kReportOtherCellTextHeight            123.f

@implementation WLReportOtherDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        self.selected = NO;
    }
    return self;
}

- (CGFloat)cellHeight
{
    return kReportOtherCellTopMargin + kReportOtherCellSelSize + kReportOtherCellTopMargin + kReportOtherCellTextHeight + kReportOtherCellTopMargin;
}

@end

@interface WLReportOtherCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *selView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, weak) WLReportOtherDataSourceItem *feedback;

@end

@implementation WLReportOtherCell

- (void)setDataSourceItem:(WLReportOtherDataSourceItem *)item
{
    [self.contentView removeAllSubviews];
    
    self.backgroundColor = kLightBackgroundViewColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.titleLabel == nil)
    {
        self.titleLabel = [[UILabel alloc] init];
    }
    self.titleLabel.frame = CGRectMake(kLargeBtnXMargin, kReportOtherCellTopMargin, kScreenWidth - kLargeBtnXMargin * 2 - kReportOtherCellSelSize - kLargeBtnXMargin, kReportOtherCellSelSize);
    self.titleLabel.font = [UIFont systemFontOfSize:kLinkFontSize];
    self.titleLabel.textColor = kNameFontColor;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = item.title;
    [self.contentView addSubview:self.titleLabel];
    
    if (self.selView == nil)
    {
        self.selView = [[UIImageView alloc] init];
    }
    self.selView.frame = CGRectMake(kScreenWidth - kLargeBtnXMargin - kReportOtherCellSelSize, kReportOtherCellTopMargin, kReportOtherCellSelSize, kReportOtherCellSelSize);
    if (item.selected == YES)
    {
        self.selView.image = [AppContext getImageForKey:@"radio_on"];
    }
    else
    {
        self.selView.image = [AppContext getImageForKey:@"radio_off"];
    }
    [self.contentView addSubview:self.selView];
    
    if (self.textView == nil)
    {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(kLargeBtnXMargin, self.titleLabel.bottom + kReportOtherCellTopMargin, kScreenWidth - kLargeBtnXMargin * 2, kReportOtherCellTextHeight)];
    }
    self.textView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.textView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeText:) name:UITextViewTextDidChangeNotification object:self.textView];
    
    self.feedback = item;
}

- (void)textViewDidChangeText:(NSNotification *)notification
{
    UITextView *textView = (UITextView *)notification.object;
    if (textView != self.textView) return;
    
    self.feedback.feedback = textView.text;
}

@end
