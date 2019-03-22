//
//  WLCommentPostViewController.m
//  welike
//
//  Created by gyb on 2018/4/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCommentPostViewController.h"
#import "WLDraft.h"
#import "WLRichTextHelper.h"
#import "WLPublishTaskManager.h"
#import "WLTextViewBottomBar.h"
#import "WLComment.h"
#import "WLLoadingView.h"
#import "WLTextParse.h"
#import "WLRichItem.h"
#import "WLDraftManager.h"
#import "WLTopicInfoModel.h"
#import "WLForwardPost.h"

@interface WLCommentPostViewController ()

@property(strong,nonatomic) WLCommentDraft *commentDraft;

@property(strong,nonatomic) WLReplyDraft *replyDraft;

@property(strong,nonatomic) WLReplyOfReplyDraft *replyOfReplyDraft;

@end

@implementation WLCommentPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.title =  [AppContext getStringForKey:@"editor_comment_title" fileName:@"publish"];
    
    //从草稿箱进入
    if (self.isReadFromDraft)
    {
        self.type = self.draftBase.type;
        
        if (self.draftBase.type == WELIKE_DRAFT_TYPE_COMMENT)
        {
            _commentDraft = [[WLCommentDraft alloc] init];
            _commentDraft.type = self.draftBase.type;
            _commentDraft.draftId = self.draftBase.draftId;
            
          
        }
        
        if (self.draftBase.type == WELIKE_DRAFT_TYPE_REPLY)
        {
            _replyDraft = [[WLReplyDraft alloc] init];
            _replyDraft.type = self.draftBase.type;
            _replyDraft.draftId = self.draftBase.draftId;
           
        }
        
        if (self.draftBase.type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY)
        {
            _replyOfReplyDraft = [[WLReplyOfReplyDraft alloc] init];
            _replyOfReplyDraft.type = self.draftBase.type;
            _replyOfReplyDraft.draftId = self.draftBase.draftId;
            
            
        }
        
          [self readPostBaseFromDraft:self.draftBase];
        
        
        [self readRichContentFromDraft:self.draftBase];
    }
    else
    {
        
        if (self.type == WELIKE_DRAFT_TYPE_COMMENT)
        {
            _commentDraft = [[WLCommentDraft alloc] init];
            _commentDraft.type = self.type;
            _commentDraft.draftId = [LuuUtils uuid];
            
            _commentDraft.pid = self.postBase.pid;
            _commentDraft.parentPost = self.postBase;
            self.draftBase = _commentDraft;
        }
        
        if (self.type == WELIKE_DRAFT_TYPE_REPLY)
        {
            _replyDraft = [[WLReplyDraft alloc] init];
            _replyDraft.type = self.type;
            _replyDraft.draftId = [LuuUtils uuid];
            
            _replyDraft.pid = self.comment.pid;
            _replyDraft.parentPost = self.postBase;
            self.draftBase = _replyDraft;
        }
        
        if (self.type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY)
        {
            _replyOfReplyDraft = [[WLReplyOfReplyDraft alloc] init];
            _replyOfReplyDraft.type = self.type;
            _replyOfReplyDraft.draftId = [LuuUtils uuid];
            
            _replyOfReplyDraft.pid = self.postBase.pid;
            _replyOfReplyDraft.parentPost = self.postBase;
            self.draftBase = _replyOfReplyDraft;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    
    //dot
     NSString *superMainControllerName = [UIViewController superControllerName:self.presentingViewController];
    NSInteger mainControllerIndex = [AppContext mainViewController].selectedIndex;
    
    if (superMainControllerName.length == 0) //draft,
    {
        if (self.navigationController.viewControllers.count >= 2)
        {
            NSString *controllerName = [UIViewController superControllerName:self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2]];
            
            if ([controllerName isEqualToString:@"WLDraftViewController"])
            {
                if (self.draftBase.type == WELIKE_DRAFT_TYPE_REPLY ||   self.draftBase.type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY)
                {
                    self.source = WLTrackPlaceFrom_Draft;
                    self.mainSource = WLTrackPlaceFrom_OtherPage;
                    self.page_type = WLTrackerPublishPage_Reply;
                    [WLPublishTrack publishPageAppear:WLTrackPlaceFrom_Draft main_source:WLTrackPlaceFrom_OtherPage page_type:WLTrackerPublishPage_Reply];
                }
                
                if (self.draftBase.type == WELIKE_DRAFT_TYPE_COMMENT)
                {
                    [WLPublishTrack publishPageAppear:WLTrackPlaceFrom_Draft main_source:WLTrackPlaceFrom_OtherPage page_type:WLTrackerPublishPage_Comment];
                    self.source = WLTrackPlaceFrom_Draft;
                    self.mainSource = WLTrackPlaceFrom_OtherPage;
                    self.page_type = WLTrackerPublishPage_Comment;
                }
            }
            else
            {
                
            }
        }
    }
    else
    {
        if ([superMainControllerName isEqualToString:@"RDRootViewController"])
        {
            RDRootViewController *navController = (RDRootViewController *)self.presentingViewController;
            NSString *controllerName = [UIViewController superControllerName:navController.topViewController];
//            NSLog(@"3===%@",controllerName);
            if ([controllerName isEqualToString:@"WLMainViewController"])
            {
                [WLPublishTrack publishPageAppear:WLTrackPlaceFrom_listCell main_source:mainControllerIndex+1 page_type:WLTrackerPublishPage_Comment];
                 self.page_type = WLTrackerPublishPage_Comment;
                self.source = WLTrackPlaceFrom_listCell;
                self.mainSource = mainControllerIndex+1;
            }
            else
                if ([controllerName isEqualToString:@"WLCommentDetailViewController"])
                {
                    if (self.type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY || self.type == WELIKE_DRAFT_TYPE_REPLY)
                    {
                         [WLPublishTrack publishPageAppear:self.source main_source:self.mainSource page_type:self.page_type];
                        self.page_type = WLTrackerPublishPage_Reply;
                        self.source = WLTrackPlaceFrom_CommentDetail;
                        self.mainSource = WLTrackPlaceFrom_OtherPage;
                    }
                }
                else
                    if ([controllerName isEqualToString:@"WLFeedDetailViewController"])
                    {
                        if (self.type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY || self.type == WELIKE_DRAFT_TYPE_REPLY)
                        {
                           [WLPublishTrack publishPageAppear:self.source main_source:self.mainSource page_type:self.page_type];
                            self.page_type = WLTrackerPublishPage_Reply;
                            self.source = WLTrackPlaceFrom_PostDetail;
                            self.mainSource = WLTrackPlaceFrom_OtherPage;
                        }
                        if (self.type == WELIKE_DRAFT_TYPE_COMMENT)
                        {
                            [WLPublishTrack publishPageAppear:self.source main_source:self.mainSource page_type:self.page_type];
                             self.page_type = WLTrackerPublishPage_Comment;
                            self.source = WLTrackPlaceFrom_PostDetail;
                            self.mainSource = WLTrackPlaceFrom_OtherPage;
                        }
                    }
                    else
                        if ([controllerName isEqualToString:@"WLSearchResultViewController"])
                        {
                            self.source = WLTrackPlaceFrom_listCell;
                            self.mainSource = WLTrackPlaceFrom_OtherPage;
                            self.page_type = WLTrackerPublishPage_Repost;
                            [WLPublishTrack publishPageAppear:self.source main_source:self.mainSource page_type:self.page_type];
                        }
                        else
                            if ([controllerName isEqualToString:@"WLUserDetailViewController"])
                            {
                                self.source = WLTrackPlaceFrom_listCell;
                                self.mainSource = WLTrackPlaceFrom_OtherPage;
                                self.page_type = WLTrackerPublishPage_Repost;
                                 [WLPublishTrack publishPageAppear:self.source main_source:self.mainSource page_type:self.page_type];
                            }
                            else
                            {
                                
                            }
        }
    }
    
    [super viewDidAppear:animated];
}

- (void)navigationBarLeftBtnDidClicked
{
    [self leftNavBtnPressed];
    
}



-(void)sendBtnPressed
{
    __weak typeof(self) weakSelf = self;
 
    //先用正则匹配出链接,然后加入数组
    NSArray *linkArray = [WLTextParse urlsInString:self.textView.text];
    
    NSMutableString *originalString = [NSMutableString stringWithString:self.textView.text];
    
    if (linkArray > 0)
    {
        for (NSInteger i = linkArray.count - 1; i >= 0; i--)
        {
            WLRichItem *keywordModel = [linkArray objectAtIndex:i];
            
            [originalString replaceCharactersInRange:NSMakeRange(keywordModel.index, keywordModel.length) withString:@"•Web Links"];
        }
    }
    
    [WLRichTextHelper richTextToNormalItems:self.textView.attributedText mentionArray:self.mentionList linkArray:self.linkList topicArray:self.topicList result:^(NSArray *itemList){
        
        WLRichContent *richContent = [[WLRichContent alloc] init];
        
        if (linkArray.count > 0)
        {
            richContent.text = originalString;
        }
        else
        {
            richContent.text = weakSelf.textView.text;
        }
        
        self.words_num = [NSString getToInt:richContent.text];
       
        if (itemList.count > 0)
        {
            richContent.richItemList = itemList;
        }
        else
        {
            richContent.richItemList = nil;
        }
        
        //在这里用算法处理完所有的换行和空格
        [WLRichTextHelper  removeSpaceAndHuanhang:richContent];
        richContent.summary = [WLRichTextHelper clipContentToIndicatelength:275 withContent:richContent];
        
        
        if (self.type == WELIKE_DRAFT_TYPE_COMMENT)
        {
            weakSelf.commentDraft.content = richContent;
            weakSelf.commentDraft.pid = weakSelf.postBase.pid;
            weakSelf.commentDraft.uid = weakSelf.postBase.uid;
            weakSelf.commentDraft.nickName = weakSelf.postBase.nickName;
            
            if (weakSelf.textViewBottomBar.isCheck)
            {
                weakSelf.commentDraft.asRepost = YES;
                
                if (weakSelf.postBase.type == WELIKE_POST_TYPE_FORWARD)
                {
                    weakSelf.commentDraft.forwardContent = weakSelf.postBase.richContent; //检查
                }
                else
                {
                    weakSelf.commentDraft.forwardContent = nil;
                }
            }
            else
            {
                weakSelf.commentDraft.asRepost = NO;
                weakSelf.commentDraft.forwardContent = nil;
            }
            
            if (weakSelf.isSaveMod) //保存草稿的情况
            {
                 weakSelf.commentDraft.show = YES;
                [[AppContext getInstance].draftManager insertOrUpdate:weakSelf.commentDraft];
            }
            else
            {
//              [[AppContext getInstance].publishTaskManager postTask:weakSelf.commentDraft];
            
                NSArray *emojiArray = [WLTextParse matcheInString:richContent.text regularExpressionWithPattern:emojiRegular];
                
                NSInteger linkCount = 0;
                for (int i = 0; i < itemList.count; i++)
                {
                    WLRichItem *richItem = itemList[i];
                    if ([richItem.type isEqualToString:WLRICH_TYPE_LINK])
                    {
                        linkCount ++;
                    }
                }
                
                WLPublishModel *model = [[WLPublishModel alloc] init];
                model.source = self.source;
                model.main_Source = self.mainSource;
                model.page_type = self.page_type;
                model.exit_state = WLTrackerPublishExit_Send;
                model.words_num = self.words_num;
                model.web_link = linkCount;
                model.emoji_num = emojiArray.count;
                model.at_num = self.mentionList.count;
                model.topic_num = self.topicList.count;
                model.also_repost = weakSelf.commentDraft.asRepost;
                model.also_comment = 0;
                model.post_id = weakSelf.postBase.pid;
                model.community = @"";
                
                if (weakSelf.commentDraft.asRepost)
                {
                     model.repost_id = weakSelf.postBase.pid;
                }
                else
                {
                    model.repost_id = @"";
                }
                
                
                [[AppContext getInstance].publishTaskManager postTaskWithTrackInfo:model withDraft:weakSelf.commentDraft];
            }
        }
        
        if (self.type == WELIKE_DRAFT_TYPE_REPLY)
        {
            weakSelf.replyDraft.content = richContent;
            weakSelf.replyDraft.pid = weakSelf.comment.pid;
            weakSelf.replyDraft.uid = weakSelf.comment.uid;
            weakSelf.replyDraft.cid = weakSelf.comment.cid;
            weakSelf.replyDraft.nickName = weakSelf.comment.nickName;
            
            if (weakSelf.textViewBottomBar.isCheck)
            {
                weakSelf.replyDraft.asRepost = YES;
            }
            else
            {
                weakSelf.replyDraft.asRepost = NO;
            }
            
            weakSelf.replyDraft.commentContent = weakSelf.comment.content;
            
            
            if (weakSelf.isSaveMod) //保存草稿的情况
            {
                 weakSelf.replyDraft.show = YES;
                [[AppContext getInstance].draftManager insertOrUpdate:weakSelf.replyDraft];
            }
            else
            {
                //[[AppContext getInstance].publishTaskManager postTask:weakSelf.replyDraft];
                //=======
                
                NSArray *emojiArray = [WLTextParse matcheInString:richContent.text regularExpressionWithPattern:emojiRegular];
                
                NSInteger linkCount = 0;
                for (int i = 0; i < itemList.count; i++)
                {
                    WLRichItem *richItem = itemList[i];
                    if ([richItem.type isEqualToString:WLRICH_TYPE_LINK])
                    {
                        linkCount ++;
                    }
                }
                
                WLPublishModel *model = [[WLPublishModel alloc] init];
                model.source = self.source;
                model.main_Source = self.mainSource;
                model.page_type = self.page_type;
                model.exit_state = WLTrackerPublishExit_Send;
                model.words_num = self.words_num;
                model.web_link = linkCount;
                model.emoji_num = emojiArray.count;
                model.at_num = self.mentionList.count;
                model.topic_num = self.topicList.count;
                model.also_repost = weakSelf.replyDraft.asRepost;
                model.also_comment = 0;
                model.post_id = weakSelf.postBase.pid;
                model.community = @"";
                
                if (weakSelf.replyDraft.asRepost)
                {
                    model.repost_id = weakSelf.postBase.pid;
                }
                else
                {
                    model.repost_id = @"";
                }
                
                
                [[AppContext getInstance].publishTaskManager postTaskWithTrackInfo:model withDraft:weakSelf.replyDraft]; //5c19d5b41004a4519bd35af8
            }
          
        }
        
        if (self.type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY)
        {
            weakSelf.replyOfReplyDraft.content = richContent;
            weakSelf.replyOfReplyDraft.pid = weakSelf.postBase.pid; //
            weakSelf.replyOfReplyDraft.uid = weakSelf.secondeComment.uid;
            weakSelf.replyOfReplyDraft.cid = weakSelf.comment.cid; //一级评论的id
            weakSelf.replyOfReplyDraft.nickName = weakSelf.secondeComment.nickName;
            weakSelf.replyOfReplyDraft.parentReplyId = weakSelf.secondeComment.cid;
            
            
            
              if (weakSelf.textViewBottomBar.isCheck)
              {
                  weakSelf.replyOfReplyDraft.asRepost = YES;

              }
            else
            {
                  weakSelf.replyOfReplyDraft.asRepost = NO;


            }

            weakSelf.replyOfReplyDraft.parentReplyContent = self->_secondeComment.content;
            
            if (weakSelf.isSaveMod) //保存草稿的情况
            {
                 weakSelf.replyOfReplyDraft.show = YES;
                [[AppContext getInstance].draftManager insertOrUpdate:weakSelf.replyOfReplyDraft];
            }
            else
            {
                // [[AppContext getInstance].publishTaskManager postTask:weakSelf.replyOfReplyDraft];
                NSArray *emojiArray = [WLTextParse matcheInString:richContent.text regularExpressionWithPattern:emojiRegular];
                
                NSInteger linkCount = 0;
                for (int i = 0; i < itemList.count; i++)
                {
                    WLRichItem *richItem = itemList[i];
                    if ([richItem.type isEqualToString:WLRICH_TYPE_LINK])
                    {
                        linkCount ++;
                    }
                }
                
                WLPublishModel *model = [[WLPublishModel alloc] init];
                model.source = self.source;
                model.main_Source = self.mainSource;
                model.page_type = self.page_type;
                model.exit_state = WLTrackerPublishExit_Send;
                model.words_num = self.words_num;
                model.web_link = linkCount;
                model.emoji_num = emojiArray.count;
                model.at_num = self.mentionList.count;
                model.topic_num = self.topicList.count;
                model.also_repost = weakSelf.replyOfReplyDraft.asRepost;
                model.also_comment = 0;
                //model.post_id = weakSelf.postBase.pid;
                //model.repost_id = weakSelf.replyOfReplyDraft.parentPost.p;//5c1a01361004a421acd5a6b4
                model.community = @"";
                
                if (!weakSelf.replyOfReplyDraft.asRepost)
                {
                    model.repost_id = @"";
                }
                else
                {
                    if ([weakSelf.replyOfReplyDraft.parentPost isKindOfClass:[WLForwardPost class]])
                    {
                        model.post_id = weakSelf.postBase.pid;
                        WLForwardPost *forwordPost = (WLForwardPost *)weakSelf.replyOfReplyDraft.parentPost;
                        model.repost_id = forwordPost.rootPost.pid;
                    }
                    else
                    {
                        model.post_id = weakSelf.postBase.pid;
                        model.repost_id = weakSelf.postBase.pid;
                    }
                }
                
                [[AppContext getInstance].publishTaskManager postTaskWithTrackInfo:model withDraft:weakSelf.replyOfReplyDraft];
            }
        }
    }];
    
    [self dismissAndPop];
}

-(void)readPostBaseFromDraft:(WLDraftBase *)draftBase
{
    if ([draftBase isKindOfClass:[WLCommentDraft class]])
    {
        WLCommentDraft *commentDraft = (WLCommentDraft *)draftBase;
        
        self.postBase = [[WLPostBase alloc] init];
        self.postBase.pid = commentDraft.pid;
        self.postBase.uid = commentDraft.uid;
        self.postBase.nickName = commentDraft.nickName;
        self.postBase.richContent =  commentDraft.forwardContent;
    }
    
    if ([draftBase isKindOfClass:[WLReplyDraft class]])
    {
          WLReplyDraft *commentDraft = (WLReplyDraft *)draftBase;
        
        self.comment = [[WLComment alloc] init];
        
       
        self.comment.pid = commentDraft.pid;
        self.comment.cid = commentDraft.cid;
        self.comment.uid = commentDraft.uid;
        self.comment.nickName = commentDraft.nickName;
        self.comment.content = commentDraft.commentContent;
        
        
    }
    
    if ([draftBase isKindOfClass:[WLReplyOfReplyDraft class]])
    {
        WLReplyOfReplyDraft *commentDraft = (WLReplyOfReplyDraft *)draftBase;
        
        self.postBase = [[WLPostBase alloc] init];
        self.comment = [[WLComment alloc] init];
        self.secondeComment =  [[WLComment alloc] init];
        
        self.postBase.pid = commentDraft.pid;
        
        self.comment.pid = commentDraft.uid;
        self.comment.cid = commentDraft.cid;
        self.comment.nickName = commentDraft.nickName;
        self.secondeComment.cid = commentDraft.parentReplyId;
        self.secondeComment.content = commentDraft.parentReplyContent;
        
    }
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
