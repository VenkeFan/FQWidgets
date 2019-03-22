//
//  WLPublishCheckBox.m
//  welike
//
//  Created by gyb on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPublishCheckBox.h"


@implementation WLPublishCheckBox

- (id)initWithFrame:(CGRect)frame type:(WELIKE_DRAFT_TYPE)type
{
    self = [super initWithFrame:frame];
    if (self)
    {
        checkBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        checkBoxBtn.frame = CGRectMake(0, 1, 33, 33);
        [checkBoxBtn setImage:[AppContext getImageForKey:@"small_check"] forState:UIControlStateNormal];
        [checkBoxBtn setImage:[AppContext getImageForKey:@"small_check_select"] forState:UIControlStateSelected];
        [checkBoxBtn addTarget:self action:@selector(checkBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:checkBoxBtn];
        
        promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(checkBoxBtn.frame.origin.x + checkBoxBtn.frame.size.width, 1, 120, 33)];
        promptLabel.font = kRegularFont(14);
        promptLabel.text = @"";
        promptLabel.textColor = kLightLightFontColor;
        promptLabel.backgroundColor = [UIColor clearColor];
        promptLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:promptLabel];
        
        _isCheck = NO;
        
        if (type == WELIKE_DRAFT_TYPE_POST)
        {
            promptLabel.text = @"";
        }
        
        if (type == WELIKE_DRAFT_TYPE_FORWARD_POST)
        {
            promptLabel.text = [AppContext getStringForKey:@"editor_also_commit" fileName:@"publish"];
            checkBoxBtn.selected = YES;
             _isCheck = YES;
        }
        
        if (type == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
        {
            promptLabel.text = [AppContext getStringForKey:@"editor_also_commit" fileName:@"publish"];
            checkBoxBtn.selected = YES;
             _isCheck = YES;
        }
        
        if (type == WELIKE_DRAFT_TYPE_COMMENT)
        {
            promptLabel.text = [AppContext getStringForKey:@"editor_also_repost" fileName:@"publish"];
        }
        
        if (type == WELIKE_DRAFT_TYPE_REPLY)
        {
            promptLabel.text = [AppContext getStringForKey:@"editor_also_repost" fileName:@"publish"];
        }
        
        if (type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY)
        {
            promptLabel.text = [AppContext getStringForKey:@"editor_also_repost" fileName:@"publish"];
        }
        
    }
    return self;
}

-(void)checkBtnPressed:(UIButton *)btn
{
    if (checkBoxBtn.isSelected)
    {
        btn.selected = NO;
        _isCheck = NO;
    }
    else
    {
        btn.selected = YES;
        _isCheck = YES;
    }
}

-(void)select
{
    checkBoxBtn.selected = YES;
    _isCheck = YES;
}



@end
