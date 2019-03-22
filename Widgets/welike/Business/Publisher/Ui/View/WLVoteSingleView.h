//
//  WLVoteSingleView.h
//  welike
//
//  Created by gyb on 2018/10/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WLAssetModel;
@class YYTextView;
@interface WLVoteSingleView : UIView
{
    UIView *lineFrameView;
    YYTextView *optionTextView;
    UIButton *picBtn;
    UIButton *closeBtn;
    
    
}


@property (strong ,nonatomic) NSString *placeHolderStr;
@property (assign,nonatomic) BOOL deleteBtnEnable; //default YES
@property (assign,nonatomic) NSInteger type;//0为文字模式 ,1为图片模式
@property (assign,nonatomic)  id delegate;
@property (strong,nonatomic)  WLAssetModel  *assetModel;

-(NSString *)inputStr;

@end

@protocol WLVoteSingleViewDelegate <NSObject>

-(void)deleteOption:(WLVoteSingleView *)view;
-(void)addImage:(WLVoteSingleView *)view;
-(void)inputNum:(WLVoteSingleView *)view;
-(void)optionTextViewIsBeginEdit:(WLVoteSingleView *)view;
-(void)optionTextViewIsEndEdit:(WLVoteSingleView *)view;

@end


