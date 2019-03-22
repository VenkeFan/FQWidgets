//
//  WLMentionPostViewController.m
//  welike
//
//  Created by gyb on 2018/4/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRepostViewController.h"
#import "WLDraft.h"
#import "WLRichTextHelper.h"
#import "WLPublishTaskManager.h"
#import "WLTextViewBottomBar.h"
#import "WLRichItem.h"
#import "WLComment.h"
#import "WLPublishCardView.h"
#import "WLTextParse.h"
#import "WLTopicInfoModel.h"
#import "WLDraftManager.h"
#import "WLDraftViewController.h"
#import "WLForwardPost.h"

@interface WLRepostViewController ()

@property(strong,nonatomic) WLForwardDraft *forwardDraft;
//@property(strong,nonatomic) WLPublishCardView *publishCardView;



@end

@implementation WLRepostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.title =  [AppContext getStringForKey:@"editor_repost_title" fileName:@"publish"];
    
    if (self.isReadFromDraft)
    {
        WLForwardDraft *readForwardDraft = (WLForwardDraft *)self.draftBase;
        
        self.type = self.draftBase.type;
        
        
        _forwardDraft = [[WLForwardDraft alloc] init];
        _forwardDraft.type = self.type;
        _forwardDraft.draftId = self.draftBase.draftId;
        
        [self.textViewBottomBar selectCheckBox];
        
        self.publishCardView.hidden = NO;
        self.textView.extraBottomViewSize = self.publishCardView.height;
        [self.publishCardView setPostBase:readForwardDraft.parentPost];
        
        [self readRichContentFromDraft:self.draftBase];
        
        self.textView.selectedRange = NSMakeRange(0, 0);
        
        [self readFromDraft:self.draftBase];
    }
    else
    {
        _forwardDraft = [[WLForwardDraft alloc] init];
        _forwardDraft.type = self.type;
        _forwardDraft.draftId = [LuuUtils uuid];
        
        _forwardDraft.parentPost = self.postBase;
        self.draftBase = _forwardDraft;
        
        [self.textViewBottomBar selectCheckBox];
        
        
        self.publishCardView.hidden = NO;
        self.textView.extraBottomViewSize = self.publishCardView.height;
        [self.publishCardView setPostBase:self.postBase];
        
        
        if (self.type == WELIKE_DRAFT_TYPE_FORWARD_POST)
        {
            WLRichContent *content = [self.postBase.richContent copy];
            
            if (self.postBase.type == WELIKE_POST_TYPE_FORWARD)
            {
                //插入转发文的内容,并将光标置为最前侧
                [self.textView replaceRange:self.textView.selectedTextRange withText:@"//"];
                
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.postBase.uid,self.postBase.nickName,nil];
                
                [self.mentionList addObject:dic];
                [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<mention=@%@",self.postBase.nickName,nil]];
                [self.textView replaceRange:self.textView.selectedTextRange withText:@":"];
                
                [self spliceRichText:content];
            }
            else
            {
                //no need
            }
        }
        
        if (self.type == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
        {
            WLRichContent *content = [self.comment.content copy];
            [self.textView replaceRange:self.textView.selectedTextRange withText:@"//"];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.comment.uid,self.comment.nickName,nil];
            
            [self.mentionList addObject:dic];
            [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<mention=@%@",self.comment.nickName,nil]];
            [self.textView replaceRange:self.textView.selectedTextRange withText:@":"];
            
            [self spliceRichText:content];
        }
        
        
        self.textView.selectedRange = NSMakeRange(0, 0);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
       self.page_type = WLTrackerPublishPage_Repost;
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
                self.source = WLTrackPlaceFrom_Draft;
                self.mainSource = WLTrackPlaceFrom_OtherPage;
                self.page_type = WLTrackerPublishPage_Repost;
              [WLPublishTrack publishPageAppear:self.source main_source:self.mainSource page_type:self.page_type];
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
                self.source = WLTrackPlaceFrom_listCell;
                self.mainSource = mainControllerIndex+1;
                self.page_type = WLTrackerPublishPage_Repost;
                [WLPublishTrack publishPageAppear:self.source main_source:self.mainSource page_type:self.page_type];
            }
            else
                if ([controllerName isEqualToString:@"WLCommentDetailViewController"])
                {
                    self.source = WLTrackPlaceFrom_CommentDetail;
                    self.mainSource = WLTrackPlaceFrom_OtherPage;
                    self.page_type = WLTrackerPublishPage_Repost;
                    [WLPublishTrack publishPageAppear:self.source main_source:self.mainSource page_type:self.page_type];
                }
                else
                    if ([controllerName isEqualToString:@"WLFeedDetailViewController"])
                    {
                        self.source = WLTrackPlaceFrom_PostDetail;
                        self.mainSource = WLTrackPlaceFrom_OtherPage;
                        self.page_type = WLTrackerPublishPage_Repost;
                       [WLPublishTrack publishPageAppear:self.source main_source:self.mainSource page_type:self.page_type];
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
    //if no input
    if (self.textView.attributedText.length == 0)
    {
        [self.textView replaceRange:self.textView.selectedTextRange withText:[AppContext getStringForKey:@"publish_reply_post_empty_content" fileName:@"publish"]];
    }
    
    //else
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
        
        if (weakSelf.textViewBottomBar.isCheck)
        {
            weakSelf.forwardDraft.asComment = YES;
        }
        else
        {
            weakSelf.forwardDraft.asComment = NO;
        }
        
        if (self.type == WELIKE_DRAFT_TYPE_FORWARD_POST)
        {
            weakSelf.forwardDraft.parentPost = weakSelf.postBase;
            weakSelf.forwardDraft.content = richContent;
            
            if (weakSelf.isSaveMod) //保存草稿的情况
            {
                weakSelf.forwardDraft.show = YES;
                [[AppContext getInstance].draftManager insertOrUpdate:weakSelf.forwardDraft];
            }
            else
            {
             //[[AppContext getInstance].publishTaskManager postTask:weakSelf.forwardDraft];
                
                NSArray *emojiArray = [WLTextParse matcheInString:richContent.text regularExpressionWithPattern:emojiRegular];
                NSMutableString *topicStr = [[NSMutableString alloc] init];
                
                for (int i = 0; i < self.topicList.count; i++)
                {
                    WLTopicInfoModel *info = self.topicList[i];
                    [topicStr appendString:[NSString stringWithFormat:@"%@,",info.topicName]];
                }
                
                if (topicStr.length > 0)
                {
                    [topicStr deleteCharactersInRange:NSMakeRange(topicStr.length - 1, 1)];
                }
                else
                {
                    [topicStr appendString:@""];
                }
                
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
                model.also_comment = weakSelf.forwardDraft.asComment;
                model.also_repost = 0;
                model.topic_id = topicStr;
                model.community = @"";
                
                if (!weakSelf.forwardDraft.asComment)
                {
                    model.post_id = @"";
                    
                    if ([weakSelf.forwardDraft.parentPost isKindOfClass:[WLForwardPost class]])
                    {
                        WLForwardPost *forwordPost = (WLForwardPost *)weakSelf.forwardDraft.parentPost;
                        model.repost_id = forwordPost.rootPost.pid;
                    }
                    else
                    {
                        model.repost_id = weakSelf.postBase.pid;
                    }
                }
                else
                {
                    if ([weakSelf.forwardDraft.parentPost isKindOfClass:[WLForwardPost class]])
                    {
                        model.post_id = weakSelf.postBase.pid;
                        WLForwardPost *forwordPost = (WLForwardPost *)weakSelf.forwardDraft.parentPost;
                        model.repost_id = forwordPost.rootPost.pid;
                    }
                    else
                    {
                        model.post_id = weakSelf.postBase.pid;
                        model.repost_id = weakSelf.postBase.pid;
                    }
                }
                
                [[AppContext getInstance].publishTaskManager postTaskWithTrackInfo:model withDraft:weakSelf.forwardDraft];
            }
        }
        
        if (self.type == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
        {
            weakSelf.forwardDraft.parentPost = weakSelf.postBase;
            weakSelf.forwardDraft.content = richContent;
            
            if (weakSelf.isSaveMod) //保存草稿的情况
            {
                weakSelf.forwardDraft.show = YES;
                [[AppContext getInstance].draftManager insertOrUpdate:weakSelf.forwardDraft];
            }
            else
            {
               // [[AppContext getInstance].publishTaskManager postTask:weakSelf.forwardDraft];
                NSArray *emojiArray = [WLTextParse matcheInString:richContent.text regularExpressionWithPattern:emojiRegular];
                NSMutableString *topicStr = [[NSMutableString alloc] init];
                
                for (int i = 0; i < self.topicList.count; i++)
                {
                    WLTopicInfoModel *info = self.topicList[i];
                    [topicStr appendString:[NSString stringWithFormat:@"%@,",info.topicName]];
                }
                
                if (topicStr.length > 0)
                {
                    [topicStr deleteCharactersInRange:NSMakeRange(topicStr.length - 1, 1)];
                }
                else
                {
                    [topicStr appendString:@""];
                }
                
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
                model.also_comment = weakSelf.forwardDraft.asComment;
                model.also_repost = 0;
                model.topic_id = topicStr;
                model.community = @"";
                
                if (!weakSelf.forwardDraft.asComment)
                {
                    model.post_id = @"";
                   
                     if ([weakSelf.forwardDraft.parentPost isKindOfClass:[WLForwardPost class]])
                     {
                         WLForwardPost *forwordPost = (WLForwardPost *)weakSelf.forwardDraft.parentPost;
                         model.repost_id = forwordPost.rootPost.pid;
                     }
                     else
                     {
                        model.repost_id = weakSelf.postBase.pid;
                     }
                }
                else
                {
                    if ([weakSelf.forwardDraft.parentPost isKindOfClass:[WLForwardPost class]])
                    {
                        model.post_id = weakSelf.postBase.pid;
                        WLForwardPost *forwordPost = (WLForwardPost *)weakSelf.forwardDraft.parentPost;
                        model.repost_id = forwordPost.rootPost.pid;
                    }
                    else
                    {
                        model.post_id = weakSelf.postBase.pid;
                        model.repost_id = weakSelf.postBase.pid;
                    }
                }
                
                [[AppContext getInstance].publishTaskManager postTaskWithTrackInfo:model withDraft:weakSelf.forwardDraft];
                
            }
            
        }
        
    }];
    
    [self dismissAndPop];
}


-(void)spliceRichText:(WLRichContent *)content
{
    if (content.richItemList == 0)
    {
        [self.textView replaceRange:self.textView.selectedTextRange withText:content.text];
    }
    else
    {
        NSInteger offsetNum = 2 + self.postBase.nickName.length + 1;
        
        //处理所有的items,将其后移
        for(WLRichItem *richItem in content.richItemList)
        {
            richItem.index = richItem.index + offsetNum;
        }
        
        
        for (int i = 0; i < content.richItemList.count; i++)
        {
            WLRichItem *richItem = content.richItemList[i];
            if (richItem.index - offsetNum > 0) //第一个左边有值
            {
                if (i == 0)
                {
                    NSString *itemStr = [content.text substringWithRange:NSMakeRange(0, richItem.index - offsetNum)];
                    [self.textView replaceRange:self.textView.selectedTextRange withText:itemStr];
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MENTION])
                    {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:richItem.rid,[richItem.source substringFromIndex:1],nil];
                        [self.mentionList addObject:dic];
                        [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<mention=%@",richItem.source]];
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_LINK])
                    {
                        NSString *linkString = [NSString stringWithFormat:@"•Web Links<Link=%@>",richItem.source];
                        if (richItem.source.length > 0)
                        {
                            [self.linkList addObject:richItem.source];
                            [self.textView replaceRange:self.textView.selectedTextRange withText:linkString];
                        }
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MORE])
                    {
                        
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_TOPIC])
                    {
                        WLTopicInfoModel *info = [[WLTopicInfoModel alloc] init];
                        info.topicName = [richItem.source substringFromIndex:1];
                        info.topicID = [richItem.rid substringFromIndex:1];
                        
                        [self.topicList addObject:info];
                        [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<topic=%@",richItem.source]];
                    }
                    
                }
                else
                {
                    WLRichItem *frontRichItem = content.richItemList[i - 1];
                    
                    //这里对异常进行处理
                    if (richItem.index - frontRichItem.index - frontRichItem.length < 0 || richItem.index - frontRichItem.index - frontRichItem.length > self.textView.text.length)
                    {
                        return;
                    }
                    
                    NSString *itemStr = [content.text substringWithRange:NSMakeRange(frontRichItem.index + frontRichItem.length - offsetNum, richItem.index - frontRichItem.index - frontRichItem.length)];
                    [self.textView replaceRange:self.textView.selectedTextRange withText:itemStr];
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MENTION])
                    {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:richItem.rid,[richItem.source substringFromIndex:1],nil];
                        [self.mentionList addObject:dic];
                        [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<mention=%@",richItem.source]];
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_LINK])
                    {
                        NSString *linkString = [NSString stringWithFormat:@"•Web Links<Link=%@>",richItem.source];
                        if (richItem.source.length > 0)
                        {
                            [self.linkList addObject:richItem.source];
                            [self.textView replaceRange:self.textView.selectedTextRange withText:linkString];
                        }
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MORE])
                    {
                        
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_TOPIC])
                    {
                        WLTopicInfoModel *info = [[WLTopicInfoModel alloc] init];
                        info.topicName = [richItem.source substringFromIndex:1];
                        info.topicID = [richItem.rid substringFromIndex:1];
                        
                        [self.topicList addObject:info];
                        
                        [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<topic=%@",richItem.source]];
                    }
                }
                
            }
            else  //==0  //第一个左边无值
            {
                if (i == 0)
                {
                    if ([richItem.type isEqual:WLRICH_TYPE_MENTION])
                    {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:richItem.rid,[richItem.source substringFromIndex:1],nil];
                        [self.mentionList addObject:dic];
                        [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<mention=%@",richItem.source]];
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_LINK])
                    {
                        NSString *linkString = [NSString stringWithFormat:@"•Web Links<Link=%@>",richItem.source];
                        if (richItem.source.length > 0)
                        {
                            [self.linkList addObject:richItem.source];
                            [self.textView replaceRange:self.textView.selectedTextRange withText:linkString];
                        }
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MORE])
                    {
                        
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_TOPIC])
                    {
                        WLTopicInfoModel *info = [[WLTopicInfoModel alloc] init];
                        info.topicName = [richItem.source substringFromIndex:1];
                        info.topicID = [richItem.rid substringFromIndex:1];
                        
                        [self.topicList addObject:info];
                        
                        [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<topic=%@",richItem.source]];
                    }
                }
                else
                {
                    WLRichItem *frontRichItem = content.richItemList[i - 1];
                    
                    //这里对异常进行处理
                    if (richItem.index - frontRichItem.index - frontRichItem.length < 0 || richItem.index - frontRichItem.index - frontRichItem.length > self.textView.text.length)
                    {
                        return;
                    }
                    
                    [self.textView replaceRange:self.textView.selectedTextRange withText:[content.text substringWithRange:NSMakeRange(frontRichItem.index + frontRichItem.length - offsetNum, richItem.index - frontRichItem.index - frontRichItem.length)]];
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MENTION])
                    {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:richItem.rid,[richItem.source substringFromIndex:1],nil];
                        [self.mentionList addObject:dic];
                        [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<mention=%@",richItem.source]];
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_LINK])
                    {
                        NSString *linkString = [NSString stringWithFormat:@"•Web Links<Link=%@>",richItem.source];
                        if (richItem.source.length > 0)
                        {
                            [self.linkList addObject:richItem.source];
                            [self.textView replaceRange:self.textView.selectedTextRange withText:linkString];
                        }
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MORE])
                    {
                        
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_TOPIC])
                    {
                        WLTopicInfoModel *info = [[WLTopicInfoModel alloc] init];
                        info.topicName = [richItem.source substringFromIndex:1];
                        info.topicID = [richItem.rid substringFromIndex:1];
                        
                        [self.topicList addObject:info];
                        
                        [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<topic=%@",richItem.source]];
                    }
                }
            }
            
            //最后一个item的右侧,还有值
            if (i == content.richItemList.count - 1)
            {
                [self.textView replaceRange:self.textView.selectedTextRange withText:[content.text substringFromIndex:richItem.index - offsetNum + richItem.length]];
            }
        }
    }
}


-(void)readFromDraft:(WLDraftBase *)draftBase
{
    WLForwardDraft *readForwardDraft = (WLForwardDraft *)self.draftBase;
    
    self.postBase = [[WLPostBase alloc] init];
    
    self.postBase = readForwardDraft.parentPost;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

