//
//  WLDraftCell.h
//  welike
//
//  Created by gyb on 2018/6/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLDraftInfo;
@class TYLabel;
@class WLPublishCardView;

@protocol TYTextViewDelegate <UITextViewDelegate>

-(void)resendDidTaped:(WLDraftInfo *)draftInfo;

@end


@interface WLDraftCell : UITableViewCell
{
//    UIView *bgView;
    
    TYLabel *richLabel;
    
    UIImageView *thumbView;
    UIImageView *playFlag;
    
    
    UILabel *timeLabel;
    
    UIButton *resendBtn;
    
    WLPublishCardView *publishCardView;
    
       UIView *lineView;
}


@property (nonatomic,strong) WLDraftInfo *draftInfo;
@property (nonatomic,weak) id delegate;


-(void)drawCell;

@end



