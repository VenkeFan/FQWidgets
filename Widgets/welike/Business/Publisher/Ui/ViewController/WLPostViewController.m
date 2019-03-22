//
//  WLPostViewController.m
//  welike
//
//  Created by gyb on 2018/4/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPostViewController.h"
#import "WLDraft.h"
#import "WLRichTextHelper.h"
#import "WLPublishTaskManager.h"
#import "WLAssetModel.h"
#import "WLThumbGridView.h"
//#import "WLGradientCircleLayer.h"
#import "WLTextParse.h"
#import "WLRichItem.h"
#import "YYText.h"
#import "WLTopicInfoModel.h"
#import "WLSearchLocationViewController.h"
#import "RDLocation.h"
#import "WLTextViewBottomBar.h"
#import "NSDictionary+JSON.h"
#import "WLRouterDefine.h"
#import "WLDraftViewController.h"
#import "WLDraftManager.h"
#import "WLDraft.h"
#import "WLVideoThumbView.h"
#import "WLLocationInfo.h"
#import "WLVoteView.h"
#import "WLPostBottomView.h"
#import "WLTopicBtn.h"
#import "WLPostStatusViewController.h"
#import "WLMainViewController.h"
#import "WLAssetsViewController.h"
#import "WLCameraOperateView.h"
#import "WLCameraViewController.h"
//#import "WLAbstractCameraViewController.h"
//#import "WLRecordShortVideoController.h"
//#import "WLCropVideoViewController.h"

//#define kToolbarHeight 108
#define kPostbarHeight_small 76
#define kPostbarHeight_large 110

@interface WLPostViewController ()<WLAssetsViewControllerDelegate>
{
}

@property (nonatomic,strong)  RDLocation *location;



@property (strong,nonatomic) WLPostDraft *postDraft;

@end

@implementation WLPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [AppContext getStringForKey:@"editor_post_title" fileName:@"publish"];
    
    self.textViewBottomBar.hidden = YES;
    self.superTopicBtn.hidden = NO;
    
    if (kIsiPhoneX)
    {
          self.postBottomBar = [[WLPostBottomView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kPostbarHeight_large - 34, kScreenWidth,kPostbarHeight_large + 34)];
        
    }
    else
    {
          self.postBottomBar = [[WLPostBottomView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kPostbarHeight_large, kScreenWidth,kPostbarHeight_large)];
    }
    
    self.textView.height = kScreenHeight - kNavBarHeight - kPostbarHeight_large;
    self.textView.extraAccessoryViewHeight = self.postBottomBar.height;
    self.postBottomBar.delegate = self;
//    self.postBottomBar.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.postBottomBar];
    

    //从草稿箱进入
    if (self.isReadFromDraft)
    {
        self.type = WELIKE_DRAFT_TYPE_POST;
        
        WLPostDraft *readFromDraft = (WLPostDraft *)self.draftBase;
        
        _postDraft = [[WLPostDraft alloc] init];
        _postDraft.type = WELIKE_DRAFT_TYPE_POST;
        _postDraft.draftId = self.draftBase.draftId;
        
        [self readRichContentFromDraft:self.draftBase];
        
        if (readFromDraft.location.placeId.length > 0)
        {
            self.location = readFromDraft.location;
          //  self.textViewBottomBar.location = readFromDraft.location;
        }
        
        //读取图片和视频信息
        [self readImageAndVideoFromDraft:readFromDraft];
        
         [self handleTopicPosition];
    }
    else
    {
        _postDraft = [[WLPostDraft alloc] init];
        _postDraft.type = WELIKE_DRAFT_TYPE_POST;
        _postDraft.draftId = [LuuUtils uuid];
        
        
        if (_topicInfo.topicName.length > 0)
        {
            self.topic_source = WLTopic_source_detail;
            [self.topicList addObject:_topicInfo];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"eula"] != nil)
            {
                [self.textView becomeFirstResponder];
            }
            [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<topic=#%@",[_topicInfo.topicName substringFromIndex:1],nil]];
            [self.textView replaceRange:self.textView.selectedTextRange withText:@" "];
        }
        else if ([self.routerParams count] > 0)
        {
            NSString *hashType = [self.routerParams stringForKey:WLROUTER_PARAM_PUBLISH_HASH_TYPE];
            if ([hashType isEqualToString:@"MENTION"] == YES)
            {
                NSString *hashTag = [self.routerParams stringForKey:WLROUTER_PARAM_PUBLISH_HASH_TAG];
                NSString *hashId = [self.routerParams stringForKey:WLROUTER_PARAM_PUBLISH_HASH_ID];
                if ([hashTag length] > 0 && [hashId length] > 0)
                {
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"eula"] != nil)
                    {
                        [self.textView becomeFirstResponder];
                    }
                    
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:hashId, hashTag, nil];
                    
                    [self.mentionList addObject:dic];
                    [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<mention=@%@",hashTag,nil]];
                    [self.textView replaceRange:self.textView.selectedTextRange withText:@" "];
                }
            }
            else if ([hashType isEqualToString:@"TOPIC"] == YES)
            {
                NSString *hashTag = [self.routerParams stringForKey:WLROUTER_PARAM_PUBLISH_HASH_TAG];
                if ([hashTag length] > 0)
                {
                    _topicInfo = [[WLTopicInfoModel alloc] init];
                    _topicInfo.topicName = hashTag;
                    
                    [self.topicList addObject:_topicInfo];
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"eula"] != nil)
                    {
                        [self.textView becomeFirstResponder];
                    }
                    [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<topic=#%@", [_topicInfo.topicName substringFromIndex:1], nil]];
                    [self.textView replaceRange:self.textView.selectedTextRange withText:@" "];
                    
                }
            }
            else if ([hashType isEqualToString:@"LINK"] == YES)
            {
                NSString *hashTag = [self.routerParams stringForKey:WLROUTER_PARAM_PUBLISH_HASH_TAG];
                if ([hashTag length] > 0)
                {
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"eula"] != nil)
                    {
                        [self.textView becomeFirstResponder];
                    }
                    NSString *linkString = [NSString stringWithFormat:@"•Web Links<Link=%@>", hashTag];
                    [self.linkList addObject:hashTag];
                    [self.textView replaceRange:self.textView.selectedTextRange withText:linkString];
                    [self.textView replaceRange:self.textView.selectedTextRange withText:@" "];
                }
            }
            else
            {
                NSString *hashTag = [self.routerParams stringForKey:WLROUTER_PARAM_PUBLISH_HASH_TAG];
                if ([hashTag length] > 0)
                {
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"eula"] != nil)
                    {
                        [self.textView becomeFirstResponder];
                    }
                    [self.textView replaceRange:self.textView.selectedTextRange withText:hashTag];
                }
            }
        }
    }
    
    //如果有地理位置
    if (_locationInfo.placeId.length > 0 && _locationInfo.name.length > 0)
    {
        self.location = [[RDLocation alloc] init];
        self.location.placeId = [NSString stringWithString:_locationInfo.placeId];
        self.location.place = [NSString stringWithString:_locationInfo.name];
       // self.textViewBottomBar.location = self.location;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.page_type = WLTrackerPublishPage_Post;
    
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
                [WLPublishTrack publishPageAppear:WLTrackPlaceFrom_Draft main_source:WLTrackPlaceFrom_OtherPage page_type:WLTrackerPublishPage_Post];
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
                self.source = WLTrackPlaceFrom_TabController;
                self.mainSource = mainControllerIndex+1;
                [WLPublishTrack publishPageAppear:WLTrackPlaceFrom_TabController main_source:mainControllerIndex+1 page_type:WLTrackerPublishPage_Post];
            }
            else
                if ([controllerName isEqualToString:@"WLTopicDetailViewController"])
                {
                    self.source = WLTrackPlaceFrom_TopicDetail;
                    self.mainSource = WLTrackPlaceFrom_OtherPage;
                    [WLPublishTrack publishPageAppear:WLTrackPlaceFrom_TopicDetail main_source:WLTrackPlaceFrom_OtherPage page_type:WLTrackerPublishPage_Post];
                }
                else
                    {
                        
                    }
        }
    }
    

//    // grab a reference to the previous view controller
//    id thePresenter = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
//
//    // and test its class
//    if ([thePresenter isKindOfClass:[YourViewController class]]) {
//        // do this
//    } else {
//        // do that
//    }
    
//    NSLog(@"1====%@",[AppContext rootViewController]);
//     NSLog(@"2====%@",[AppContext mainViewController]);
    
    
  // [WLPublishTrack publishPageAppear:WLTrackPlaceFrom_TabController main_source:1 page_type:WLTrackerPublishPage_Post];
    
    [super viewDidAppear:animated];
}

//-(void)draftBtnPressed:(id)sender
//{
//    [self.navigationBar.delegate navigationBarRightBtnDidClicked];
//}


-(void)sendBtnPressed
{
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
    
    
    //图片类型
    WLAssetModel *assetModel = self.attachmentArray.firstObject;
    
    __weak typeof(self) weakSelf = self;
    
    if (self.isVoteStatus == YES && self.voteView.imageArray.count > 0) //投票有图
    {
        [WLRichTextHelper richTextToNormalItems:self.textView.attributedText mentionArray:self.mentionList linkArray:self.linkList topicArray:self.topicList result:^(NSArray *itemList) {
            
            NSMutableArray *pollOptionArray = [[NSMutableArray alloc] initWithCapacity:0];
             NSMutableArray *attachArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (int i = 0; i < weakSelf.voteView.optionArray.count; i++) {
                
                WLAssetModel *assetModel ;
                if (weakSelf.voteView.imageArray.count != 0)
                {
                    assetModel = weakSelf.voteView.imageArray[i];
                }
                
                WLPollAttachmentDraft *attachmentDraft = [[WLPollAttachmentDraft alloc] initWithPHAsset:assetModel.asset];
                attachmentDraft.choiceName = weakSelf.voteView.optionArray[i];
                attachmentDraft.time = weakSelf.voteView.time;
                [pollOptionArray addObject:attachmentDraft];
            }
            
            for(WLAssetModel *assetModel in weakSelf.voteView.imageArray)
            {
                WLAttachmentDraft *attachmentDraft = [[WLAttachmentDraft alloc] initWithPHAsset:assetModel.asset];
                [attachArray addObject:attachmentDraft];
            }
            
            weakSelf.postDraft.pollDraftList = pollOptionArray;
            weakSelf.postDraft.picDraftList = attachArray;
            
            WLRichContent *richContent = [[WLRichContent alloc] init];
            if (itemList.count > 0)
            {
                richContent.richItemList = itemList;
            }
            else
            {
                richContent.richItemList = nil;
            }
            
                if (linkArray.count > 0)
                {
                    richContent.text = originalString;
                }
                else
                {
                    richContent.text = weakSelf.textView.text;
                }
            
                self.words_num = [NSString getToInt:richContent.text];
            
                //在这里用算法处理完所有的换行和空格
                [WLRichTextHelper  removeSpaceAndHuanhang:richContent];
                
                richContent.summary = [WLRichTextHelper clipContentToIndicatelength:275 withContent:richContent];
            
            
            weakSelf.postDraft.content = richContent;
            if (weakSelf.location)
            {
                weakSelf.postDraft.location = weakSelf.location;
            }
            
            //发送
            // [[AppContext getInstance].publishTaskManager postTask:weakSelf.postDraft];
            
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
            model.also_repost = 0;
            model.also_comment = 0;
         
            model.post_id = @"";
            model.repost_id = @"";
            model.community = @"";
            model.video_num = 0;
            model.poll_type = WLPoll_type_image;
            model.poll_num = weakSelf.voteView.optionArray.count;
            model.picture_num = model.poll_num;
            model.topic_source = self.topic_source;
            
            NSInteger dayNum = weakSelf.voteView.time/(3600*24);
            switch (dayNum)
            {
                case 1:
                    model.poll_time = WLPoll_time_1;
                    break;
                case 3:
                    model.poll_time = WLPoll_time_2;
                    break;
                case 7:
                    model.poll_time = WLPoll_time_3;
                    break;
                case 30:
                    model.poll_time = WLPoll_time_4;
                    break;
                case 0:
                    model.poll_time = WLPoll_time_5;
                    break;
                    
                default:
                    break;
            }
            
            [[AppContext getInstance].publishTaskManager postTaskWithTrackInfo:model withDraft:weakSelf.postDraft];
        }];
    }
    
    if (self.isVoteStatus == YES && self.voteView.imageArray.count == 0) //投票无图
    {
        [WLRichTextHelper richTextToNormalItems:self.textView.attributedText mentionArray:self.mentionList linkArray:self.linkList topicArray:self.topicList result:^(NSArray *itemList) {
            
            NSMutableArray *attachArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            
            //先把图片赋值,再把选项内容赋值
           // for(WLAssetModel *assetModel in weakSelf.voteView.imageArray)
            for (int i = 0; i < weakSelf.voteView.optionArray.count; i++) {
                
                WLAssetModel *assetModel ;
                if (weakSelf.voteView.imageArray.count != 0)
                {
                    assetModel = weakSelf.voteView.imageArray[i];
                }
                
                WLPollAttachmentDraft *attachmentDraft = [[WLPollAttachmentDraft alloc] initWithPHAsset:assetModel.asset];
                attachmentDraft.choiceName = weakSelf.voteView.optionArray[i];
                attachmentDraft.time = weakSelf.voteView.time;
                [attachArray addObject:attachmentDraft];
            }
          
            weakSelf.postDraft.pollDraftList = attachArray;
            weakSelf.postDraft.picDraftList = nil;
            
            WLRichContent *richContent = [[WLRichContent alloc] init];
            if (itemList.count > 0)
            {
                richContent.richItemList = itemList;
            }
            else
            {
                richContent.richItemList = nil;
            }
            

                if (linkArray.count > 0)
                {
                    richContent.text = originalString;
                }
                else
                {
                    richContent.text = weakSelf.textView.text;
                }
                
                 self.words_num = [NSString getToInt:richContent.text];
                //在这里用算法处理完所有的换行和空格
                [WLRichTextHelper  removeSpaceAndHuanhang:richContent];
                
                richContent.summary = [WLRichTextHelper clipContentToIndicatelength:275 withContent:richContent];
            
            
            
            weakSelf.postDraft.content = richContent;
            if (weakSelf.location)
            {
                weakSelf.postDraft.location = weakSelf.location;
            }
            
            // [[AppContext getInstance].publishTaskManager postTask:weakSelf.postDraft];
            
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
            model.also_repost = 0;
            model.also_comment = 0;
            model.post_id = @"";
            model.repost_id = @"";
            model.community = @"";
            model.video_num = 0;
            model.poll_type = WLPoll_type_no_image;
            model.poll_num = weakSelf.voteView.optionArray.count;
            model.topic_source = self.topic_source;
            
            NSInteger dayNum = weakSelf.voteView.time/(3600*24);
            switch (dayNum)
            {
                case 1:
                    model.poll_time = WLPoll_time_1;
                    break;
                case 3:
                    model.poll_time = WLPoll_time_2;
                    break;
                case 7:
                    model.poll_time = WLPoll_time_3;
                    break;
                case 30:
                    model.poll_time = WLPoll_time_4;
                    break;
                case 0:
                    model.poll_time = WLPoll_time_5;
                    break;
                    
                default:
                    break;
            }
            
            [[AppContext getInstance].publishTaskManager postTaskWithTrackInfo:model withDraft:weakSelf.postDraft];
        }];
    }
    
    
    if (self.isVoteStatus == NO &&self.attachmentArray.count > 0 && assetModel.asset.mediaType == PHAssetMediaTypeImage)
    {
        [WLRichTextHelper richTextToNormalItems:self.textView.attributedText mentionArray:self.mentionList linkArray:self.linkList topicArray:self.topicList result:^(NSArray *itemList) {
            
            NSMutableArray *attachArray = [[NSMutableArray alloc] initWithCapacity:0];
            for(WLAssetModel *assetModel in weakSelf.thumbGridView.imageArray)
            {
                //在这里检查看文件是否已经上传过
                WLAttachmentDraft *attachmentDraft = [[WLAttachmentDraft alloc] initWithPHAsset:assetModel.asset];
                
                NSString *fileJsonStr = [WLUploadRecord getUploadImageUrlWithidertifer:assetModel.asset.localIdentifier];
                if (fileJsonStr.length > 0)
                {
                    NSDictionary *fileJsonDic = [NSDictionary stringToDictionnary:fileJsonStr];
                    NSString *fileUrlStr = fileJsonDic[@"fileUrl"];
                    if (fileUrlStr.length > 0)
                    {
                        attachmentDraft.url = fileUrlStr;
                        attachmentDraft.tmpImgWidth = [fileJsonDic[@"width"] floatValue];
                        attachmentDraft.tmpImgHeight = [fileJsonDic[@"height"] floatValue];
                    }
                }
                
                [attachArray addObject:attachmentDraft];
            }
            
            weakSelf.postDraft.picDraftList = attachArray;
            
            WLRichContent *richContent = [[WLRichContent alloc] init];
            if (itemList.count > 0)
            {
                richContent.richItemList = itemList;
            }
            else
            {
                richContent.richItemList = nil;
            }
            
            if (weakSelf.textView.text.length == 0)
            {
                self.words_num = 0;
                richContent.text = [AppContext getStringForKey:@"publish_share_picture_empty_content" fileName:@"publish"];
                richContent.summary = [AppContext getStringForKey:@"publish_share_picture_empty_content" fileName:@"publish"];
            }
            else
            {
                if (linkArray.count > 0)
                {
                    richContent.text = originalString;
                }
                else
                {
                    richContent.text = weakSelf.textView.text;
                }
                  self.words_num = [NSString getToInt:richContent.text];
                
                //在这里用算法处理完所有的换行和空格
                [WLRichTextHelper  removeSpaceAndHuanhang:richContent];
                
                richContent.summary = [WLRichTextHelper clipContentToIndicatelength:275 withContent:richContent];
            }
            
            weakSelf.postDraft.content = richContent;
            if (weakSelf.location)
            {
                weakSelf.postDraft.location = weakSelf.location;
            }
            
            //发送
            if (weakSelf.isSaveMod) //保存草稿的情况
            {
                 weakSelf.postDraft.show = YES;
                [[AppContext getInstance].draftManager insertOrUpdate:weakSelf.postDraft];
            }
            else
            {
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
                model.also_repost = 0;
                model.also_comment = 0;
                model.post_id = @"";
                model.repost_id = @"";
                model.community = @"";
                model.video_num = 0;
                model.picture_num = attachArray.count;
                 model.topic_source = self.topic_source;
                
                [[AppContext getInstance].publishTaskManager postTaskWithTrackInfo:model withDraft:weakSelf.postDraft];
            }
        }];
    }
    
    
    //视频类型
    if (self.isVoteStatus == NO &&self.attachmentArray.count > 0 && assetModel.asset.mediaType == PHAssetMediaTypeVideo)
    {
        __weak typeof(self) weakSelf = self;
        [WLRichTextHelper richTextToNormalItems:self.textView.attributedText mentionArray:self.mentionList linkArray:self.linkList topicArray:self.topicList result:^(NSArray *itemList){
            
            WLAttachmentDraft *attachmentDraft = [[WLAttachmentDraft alloc] initWithPHAsset:assetModel.asset];
            weakSelf.postDraft.video = attachmentDraft;
            
            WLRichContent *richContent = [[WLRichContent alloc] init];
            if (itemList.count > 0)
            {
                richContent.richItemList = itemList;
            }
            else
            {
                richContent.richItemList = nil;
            }
            if (weakSelf.textView.text.length == 0)
            {
                 self.words_num = 0;
                richContent.text = [AppContext getStringForKey:@"publish_share_video_empty_content" fileName:@"publish"];
                richContent.summary = [AppContext getStringForKey:@"publish_share_video_empty_content" fileName:@"publish"];
            }
            else
            {
                if (linkArray.count > 0)
                {
                    richContent.text = originalString;
                }
                else
                {
                    richContent.text = weakSelf.textView.text;
                }
                
                 self.words_num = [NSString getToInt:richContent.text];
                //在这里用算法处理完所有的换行和空格
                [WLRichTextHelper  removeSpaceAndHuanhang:richContent];
                
                richContent.summary = [WLRichTextHelper clipContentToIndicatelength:275 withContent:richContent];
            }
            
            weakSelf.postDraft.content = richContent;
            
            if (weakSelf.location)
            {
                weakSelf.postDraft.location = weakSelf.location;
            }
            
            if (weakSelf.isSaveMod) //保存草稿的情况
            {
                 weakSelf.postDraft.show = YES;
                [[AppContext getInstance].draftManager insertOrUpdate:weakSelf.postDraft];
            }
            else
            {
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
                model.also_repost = 0;
                model.also_comment = 0;
                model.post_id = @"";
                model.repost_id = @"";
                model.community = @"";
                model.video_num = 1;
                 model.topic_source = self.topic_source;
                
                [[AppContext getInstance].publishTaskManager postTaskWithTrackInfo:model withDraft:weakSelf.postDraft];
            }
        }];
    }
    
    
    //纯文字
    if (self.isVoteStatus == NO && self.attachmentArray.count == 0)
    {
        __weak typeof(self) weakSelf = self;
        
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
            
            weakSelf.postDraft.content = richContent;
            if (weakSelf.location)
            {
                weakSelf.postDraft.location = weakSelf.location;
            }
            
            if (weakSelf.isSaveMod) //保存草稿的情况
            {
                weakSelf.postDraft.show = YES;
                [[AppContext getInstance].draftManager insertOrUpdate:weakSelf.postDraft];
            }
            else
            {
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
                model.also_repost = 0;
                model.also_comment = 0;
                model.post_id = @"";
                model.repost_id = @"";
                model.community = @"";
                model.topic_source = self.topic_source;

                [[AppContext getInstance].publishTaskManager postTaskWithTrackInfo:model withDraft:weakSelf.postDraft];
            }
        }];
    }
    
    [self dismissAndPop];
}

-(void)locationBtn
{
    [WLPublishTrack locationBtnClicked:self.source main_source:self.mainSource];
    __weak typeof(self) weakSelf = self;
   // if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        WLSearchLocationViewController *searchLocationViewController = [[WLSearchLocationViewController alloc] init];
        //searchLocationViewController.coordinate = CLLocationCoordinate2DMake(_strLatitude, _strLongitude);
        searchLocationViewController.select = ^(RDLocation *locationInfo) {
           // weakSelf.textViewBottomBar.location = locationInfo;
            weakSelf.location = locationInfo;
            
            weakSelf.postBottomBar.location = locationInfo;
        };


        RDRootViewController *locationNav = [[RDRootViewController alloc] initWithRootViewController:searchLocationViewController];
        [self presentViewController:locationNav animated:YES completion:^{

        }];
    }
//    else
//    {
//
//        //TODO:
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:@"Please enable LBS in settings" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"enable LBS" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//            [[UIApplication sharedApplication]openURL:settingURL];
//        }];
//        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//        }];
//        [alert addAction:cancel];
//        [alert addAction:ok];
//        [self presentViewController:alert animated:YES completion:nil];
//    }
}

-(void)albumBtn
{
    [WLPublishTrack cameraBtnClicked:self.source main_source:self.mainSource];
    if (self.attachmentArray.count > 0)
    {
        WLAssetsViewController *assetsViewController = [[WLAssetsViewController alloc] initWithCheckedArray:self.attachmentArray];
        assetsViewController.delegate = self;
        RDRootViewController *assetNav = [[RDRootViewController alloc] initWithRootViewController:assetsViewController];
        
        [self presentViewController:assetNav animated:YES completion:^{
        }];
    }
    else
    {
        WLAssetsViewController *assetsViewController = [[WLAssetsViewController alloc] initWithSelectionMode:WLAssetsSelectionMode_Multiple];
        assetsViewController.delegate = self;
        RDRootViewController *assetNav = [[RDRootViewController alloc] initWithRootViewController:assetsViewController];
        
        [self presentViewController:assetNav animated:YES completion:^{
        }];
    }
}
//-(void)camareBtn
//{
//     [WLPublishTrack cameraBtnClicked:self.source main_source:self.mainSource];
//
//
//    //    WLAbstractCameraViewController *ctr = [WLAbstractCameraViewController generateCameraViewCtr];
//    //    ctr.delegate = self;
//    //
//    //    ctr.outputType = FQCameraOutputType_Photo;
//    //    [self.navigationController pushViewController:ctr animated:YES];
//}
//
//-(void)videoBtn
//{
//    [WLPublishTrack cameraBtnClicked:self.source main_source:self.mainSource];
////    WLAbstractCameraViewController *ctr = [WLAbstractCameraViewController generateCameraViewCtr];
////    ctr.delegate = self;
////
////    ctr.outputType = FQCameraOutputType_Video;
////    [self.navigationController pushViewController:ctr animated:YES];
////    WLRecordShortVideoController *ctr = [[WLRecordShortVideoController alloc] init];
////    RDRootViewController *nav = [[RDRootViewController alloc] initWithRootViewController:ctr];
////    ctr.isLightStatusBar = YES;
////    ctr.target = self;
////    [self presentViewController:nav animated:YES completion:^{
////    }];
//}

-(void)camareBtn
{
    [WLPublishTrack cameraBtnClicked:self.source main_source:self.mainSource];
    WLCameraViewController *ctr = [WLCameraViewController new];
    ctr.delegate = self;
    ctr.isLightStatusBar = YES;
    ctr.outputType = FQCameraOutputType_Photo;
    [self.navigationController pushViewController:ctr animated:YES];
}

-(void)videoBtn
{
    [WLPublishTrack cameraBtnClicked:self.source main_source:self.mainSource];
    WLCameraViewController *ctr = [WLCameraViewController new];
    ctr.delegate = self;
    ctr.isLightStatusBar = YES;
    ctr.outputType = FQCameraOutputType_Video;
    [self.navigationController pushViewController:ctr animated:YES];
}


-(void)voteBtn
{
    [WLPublishTrack voteBtnClicked:self.source main_source:self.mainSource page_type:self.page_type];
    
    self.navigationBar.rightBtn.enabled = NO;
    self.isVoteStatus = YES;
    draftBtn.enabled = NO;
    
    //停止所有按钮
    [self.postBottomBar enableALLBtnExceptVoteAndPhotoBtn];
    
    //显示投票控件
    self.voteView.height = 130 + 160;
    self.textView.extraBottomViewSize = self.voteView.height;
    self.voteView.hidden = NO;
    
    
    //添加富文本信息
    WLTopicInfoModel *topicInfo = [[WLTopicInfoModel alloc] init];
    topicInfo.topicName = @"#poll";
    [self.topicList insertObject:topicInfo atIndex:0];
    
    [self.textView setSelectedRange:NSMakeRange(0, 0)];
    
    [self.textView replaceRange:self.textView.selectedTextRange withText:[NSString stringWithFormat:@"<topic=#%@",[topicInfo.topicName substringFromIndex:1],nil]];
    [self.textView replaceRange:self.textView.selectedTextRange withText:@" "];
    
    [self disableSendBtn];
  
    [self handleTopicPosition];
}

- (void)statusBtnPressed{
    
    [self dismissViewControllerAnimated:NO completion:^{
  
        [WLStatusTrack postStatusAppear:WLStatusTrack_from_status_btn];
        
        WLPostStatusViewController *postStatusViewController = [[WLPostStatusViewController alloc] init];
        
        RDRootViewController *nav = [[RDRootViewController alloc] initWithRootViewController:postStatusViewController];
        
        [[AppContext rootViewController] presentViewController:nav animated:YES completion:^{
            
        }];
    }];
}




-(void)readImageAndVideoFromDraft:(WLPostDraft *)readFromDraft
{
//    NSArray *picDraftList; -> WLAttachmentDraft-->WLAssetModel->asset
//   WLAttachmentDraft *video;
    if (readFromDraft.picDraftList.count == 0 && readFromDraft.video.asset.localIdentifier.length == 0)
    {
        [self.postBottomBar enableAllBtn];
    }
    else
    {
        if (readFromDraft.picDraftList.count > 0)
        {
            self.attachmentArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (int i = 0; i < readFromDraft.picDraftList.count; i++)
            {
                WLAttachmentDraft *draft = readFromDraft.picDraftList[i];
                WLAssetModel *assetModel = [[WLAssetModel alloc] initWithType:WLAssetModelType_Photo asset:draft.asset];
                assetModel.type = WLAssetModelType_Photo;
                assetModel.checkedIndex = i + 1;
                assetModel.checked = YES;
                [self.attachmentArray addObject:assetModel];
            }
            
            [self.thumbGridView setImageArray:[NSMutableArray arrayWithArray:self.attachmentArray]];
            self.textView.extraBottomViewSize = self.thumbGridView.height + 37;
            [self enableOrDisableSendBtn];
            [self.videoThumbView setVideoAsset:nil];
            [self.postBottomBar enablePhotoCamera];
            
            self.videoThumbView.hidden = YES;
            self.thumbGridView.hidden = NO;
        }
        
        if (readFromDraft.video.asset.localIdentifier.length > 0)
        {
            self.attachmentArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            WLAssetModel *assetModel = [[WLAssetModel alloc] initWithType:WLAssetModelType_Video asset:readFromDraft.video.asset];
            assetModel.type = WLAssetModelType_Video;
            assetModel.checkedIndex = 1;
            assetModel.checked = YES;
            [self.attachmentArray addObject:assetModel];
            
            [self.videoThumbView setVideoAsset:readFromDraft.video.asset];
            self.textView.extraBottomViewSize = self.videoThumbView.height + 37;
            [self enableOrDisableSendBtn];
            [self.thumbGridView setImageArray:nil];
            
            [self.postBottomBar enableVideo];
            
            self.videoThumbView.hidden = NO;
            self.thumbGridView.hidden = YES;
        }
    }
}

-(void)enableSendeBtn
{
    sendBtn.enabled = YES;
    [sendBtn setTitleColor:send_text_color_enable forState:UIControlStateNormal];
    sendBtn.backgroundColor = kMainColor;
}


-(void)disableSendBtn
{
    sendBtn.enabled = NO;
    [sendBtn setTitleColor:send_text_color_disable forState:UIControlStateNormal];
    sendBtn.backgroundColor = kLargeBtnDisableColor;
}

-(void)optionBeginToInput
{
    [self.postBottomBar disableaAllBtnExceptEmojiBtn];
}

-(void)optionEndInput
{
     [self.postBottomBar enableALLBtnExceptVoteAndPhotoBtn];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigationBarLeftBtnDidClicked
{
    [self leftNavBtnPressed];

        WLPublishModel *model = [[WLPublishModel alloc] init];
        model.source = self.source;
        model.main_Source = self.mainSource;
        model.page_type = self.page_type;
    
        NSArray *linkArray = [WLTextParse urlsInString:self.textView.text];
        self.words_num = [NSString getToInt:self.textView.text];
    
        model.words_num = self.words_num;
        model.web_link = linkArray.count + self.linkList.count;
    
        NSArray *emojiArray = [WLTextParse matcheInString:self.textView.text regularExpressionWithPattern:emojiRegular];
        model.emoji_num = emojiArray.count;
    
        model.at_num = self.mentionList.count;
        model.topic_num = self.topicList.count;
        model.also_repost = 0;
        model.also_comment = 0;
    
    NSMutableString *topicStr = [NSMutableString string];
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
    
    model.topic_id = topicStr;
    model.topic_source = 0;
    model.post_id = @"";
    model.repost_id = @"";
    model.community = @"";
    
    model.picture_num = self.attachmentArray.count;
    model.picture_size = 0;
    model.picture_upload_time = 0;
    
    WLAssetModel *assetModel = self.attachmentArray.firstObject;
    if ( assetModel.asset.mediaType == PHAssetMediaTypeVideo)
    {
         model.video_num = 1;
        
    }
    else
    {
         model.video_num = 0;
    }
    
    model.video_size = 0;
    model.video_convert_time = 0;
    model.video_upload_time = 0;
    
    if (self.isVoteStatus == YES)
    {
        if (self.voteView.imageArray.count > 0)
        {
            model.poll_type = WLPoll_type_image;
            model.poll_num = self.voteView.imageArray.count;
        }
        else
        {
            model.poll_type = WLPoll_type_no_image;
            model.poll_num = self.voteView.optionArray.count;
        }
        
        NSInteger dayNum = self.voteView.time/(3600*24);
        switch (dayNum)
        {
            case 1:
                model.poll_time = WLPoll_time_1;
                break;
            case 3:
                model.poll_time = WLPoll_time_2;
                break;
            case 7:
                model.poll_time = WLPoll_time_3;
                break;
            case 30:
                model.poll_time = WLPoll_time_4;
                break;
            case 0:
                model.poll_time = WLPoll_time_5;
                break;
                
            default:
                model.poll_time = 0;
                break;
        }
        
        
    }
    else
    {
        model.poll_type = 0;
        model.poll_num = 0;
        model.poll_time = 0;
    }
    
    [WLPublishTrack publishControllerClose:model];
}



@end

