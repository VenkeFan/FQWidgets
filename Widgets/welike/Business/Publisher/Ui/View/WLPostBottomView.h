//
//  WLPostBottomView.h
//  welike
//
//  Created by gyb on 2018/11/5.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLDraft.h"
#import "WLLocationView.h"
#import "RDLocation.h"

@protocol WLPostBottomViewDelegate <NSObject>

-(void)albumBtn;
-(void)camareBtn;
-(void)contactBtn;
-(void)emojiBtn;
-(void)linkBtn;
-(void)voteBtn;
-(void)videoBtn;
-(void)locationBtn;
-(void)locationDeleteBtn;

-(void)statusBtnPressed;


@end


@interface WLPostBottomView : UIView
{
    UIButton *photoBtn;
    UIButton *camareBtn;
    UIButton *videoBtn;
    UIButton *voteBtn;
    UIButton *statusBtn;
    UIButton *emojiBtn;
    UIButton *contactBtn;
    UIButton *linkBtn;
    
    UIView *bottomLine;
    
    UILabel *countLabel;
    WLLocationView *locationView;
}

@property (weak,nonatomic) id delegate;
@property (strong,nonatomic) RDLocation *location;
//@property (readonly ,nonatomic) BOOL sendEnabled;


- (id)initWithFrame:(CGRect)frame;

-(void)changeToEmojiStatus:(BOOL)flag;

//-(void)enableSendeBtn;
//-(void)disableSendBtn;


//-(void)selectCheckBox;

//改变字数并返回是否可以发送
-(void)changeCharNum:(NSInteger)num;

//-(BOOL)isCheck;

//-(void)enableTopicBtn;
//-(void)disableTopicBtn;

-(void)enableAllBtn;
//-(void)disableAllBtn;

//-(void)enableALLBtnExceptVoteBtn;
//-(void)enableALLBtnExceptVoteAndPhotoBtn;


-(void)enablePhotoCamera;
-(void)enableVideo;
-(void)disableaAllBtnExceptEmojiBtn;
-(void)enableALLBtnExceptVoteAndPhotoBtn;


-(void)changeInputStatus:(BOOL)flag; //YES 是输入状态,NO是非输入状态

@end

