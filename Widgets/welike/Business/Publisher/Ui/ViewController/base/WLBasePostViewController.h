//
//  WLBasePostViewController.h
//  welike
//
//  Created by gyb on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"
#import "WLDraft.h"
#import "YYTextView.h"

@class WLThumbGridView;
@class WLVideoThumbView;
@class WLTextViewBottomBar;
@class WLPublishCardView;
@class WLTopicInfoModel;
@class WLDraftBase;
@class WLVoteView;
@class WLPostBottomView;
@class WLTopicBtn;

@interface WLBasePostViewController : WLNavBarBaseViewController
{
    UIButton *sendBtn;
    UIButton *draftBtn;
}



@property (assign,nonatomic) WELIKE_DRAFT_TYPE type;

@property (strong,nonatomic) NSMutableArray *attachmentArray;
@property (strong,nonatomic) NSMutableArray *mentionList;
@property (strong,nonatomic) NSMutableArray<WLTopicInfoModel *> *topicList;

@property (strong,nonatomic) NSMutableArray *linkList;
@property (assign,nonatomic) NSInteger charNum;

@property (strong,nonatomic) WLTextViewBottomBar *textViewBottomBar; //非post发布器使用
@property (strong,nonatomic) WLPostBottomView *postBottomBar;
@property (strong,nonatomic) WLThumbGridView *thumbGridView;
@property (strong,nonatomic) WLVideoThumbView *videoThumbView;
@property (strong,nonatomic) YYTextView *textView;
@property (strong,nonatomic) WLPublishCardView *publishCardView;
@property (strong,nonatomic) WLVoteView *voteView;
@property (strong,nonatomic) WLTopicBtn *superTopicBtn;

@property (strong,nonatomic) WLPostBase *postBase;

//投票用
@property (assign,nonatomic)   BOOL isVoteStatus;

//草稿箱用
@property (assign,nonatomic) BOOL isReadFromDraft;

@property (strong,nonatomic) WLDraftBase *draftBase;

@property (assign,nonatomic) BOOL isSaveMod;

//打点用
@property (assign,nonatomic) NSInteger source;
@property (assign,nonatomic) NSInteger mainSource;
@property (assign,nonatomic) NSInteger page_type;
@property (assign,nonatomic) NSInteger words_num;//字节数
@property (assign,nonatomic) NSInteger pic_num;
@property (assign,nonatomic) NSInteger exit_type;
@property (assign,nonatomic) NSInteger topic_source;


//@property (nonatomic,copy) void(^leftNavBtnPressed)(WLPublishModel *model);
//@property (strong,nonatomic) WLDraftManager *draftManager;


-(void)readRichContentFromDraft:(WLDraftBase *)draftBase;


-(void)enableOrDisableSendBtn;


- (void)dismissAndPop;


-(void)sendBtnPressed;


-(void)handleTopicPosition;


-(void)enablePostSendBtn;
-(void)disablePostSendBtn;

-(void)leftNavBtnPressed;



@end
