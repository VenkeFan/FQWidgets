//
//  WLTextViewBottomBar.h
//  welike
//
//  Created by gyb on 2018/4/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLDraft.h"
#import "WLPublishCheckBox.h"
#import "WLLocationView.h"
#import "RDLocation.h"

@protocol WLTextViewBottomBarDelegate <NSObject>

-(void)camareBtn;
-(void)contactBtn;
-(void)emojiBtn;
-(void)linkBtn;
-(void)voteBtn;
-(void)sendBtnPressed;
-(void)topicBtn;
-(void)locationBtn;
-(void)locationDeleteBtn;


@end



@interface WLTextViewBottomBar : UIView
{
//    UIButton *camareBtn;
    UIButton *contactBtn;
    UIButton *topicBtn;
    UIButton *emojiBtn;
    UIButton *linkBtn;
//    UIButton *voteBtn;
    
    UILabel *countLabel;
    UIButton *sendBtn;
    
    WLPublishCheckBox *publishCheckBox;
    
    WLLocationView *locationView;
    
    WELIKE_DRAFT_TYPE draftType;
}

@property (weak,nonatomic) id delegate;
//@property (readonly,assign,nonatomic) BOOL isCheck;
//@property (strong,nonatomic) RDLocation *location;
@property (readonly ,nonatomic) BOOL sendEnabled;


- (id)initWithFrame:(CGRect)frame type:(WELIKE_DRAFT_TYPE)type;

-(void)changeToEmojiStatus:(BOOL)flag;

-(void)enableSendeBtn;
-(void)disableSendBtn;


-(void)selectCheckBox;

-(void)changeCharNum:(NSInteger)num;

-(BOOL)isCheck;

-(void)enableTopicBtn;
-(void)disableTopicBtn;

-(void)enableAllBtn;
-(void)disableAllBtn;

-(void)enableALLBtnExceptVoteBtn;
-(void)enableALLBtnExceptVoteAndPhotoBtn;

@end
