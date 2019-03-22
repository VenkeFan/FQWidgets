//
//  WLFoldRichView.h
//  welike
//
//  Created by gyb on 2018/8/20.
//  Copyright © 2018年 redefine. All rights reserved.
//  可折叠的富文本view

#import <UIKit/UIKit.h>
#import "TYLabel.h"

@protocol WLFoldRichViewDelegate <NSObject>

-(void)clickUser:(NSString *)userId;
-(void)clickTopic:(NSString *)topicID;
-(void)clickLoction:(NSString *)placeID;
//-(void)clickLink:(NSString *)linkStr;


@end


@class WLPostBase;
@interface WLFoldRichView : UIView<TYLabelDelegate>
{
    TYLabel *contentLabel;
    CGFloat minHeight;
    CGFloat maxHeight;
}

@property (strong,nonatomic) WLPostBase *postBase;
@property (strong,nonatomic) UIColor *contentColor;
@property (assign,nonatomic) NSInteger lineNum; //未折叠的行数
@property (weak,nonatomic) id delegate;


- (id)initWithFrame:(CGRect)frame withMinLineNum:(NSInteger)lineNum;


-(void)fold;

-(void)unfold;


-(BOOL)canUnfold;

-(BOOL)isFold;

@end
