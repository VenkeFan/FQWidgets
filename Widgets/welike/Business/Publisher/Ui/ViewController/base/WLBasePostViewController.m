//
//  WLBasePostViewController.m
//  welike
//
//  Created by gyb on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBasePostViewController.h"
#import "WLTextEditParser.h"
#import "WLTextViewBottomBar.h"
#import "WLTextLinePositionModifier.h"
#import "WLLinkInputView.h"
#import "WLMaskView.h"
#import "WLAssetsViewController.h"
#import "WLThumbGridView.h"
#import "WLEmoticonInputView.h"
#import "WLContactListViewController.h"
#import "WLAssetModel.h"
#import <Photos/Photos.h>
#import "WLImageHelper.h"
#import "WLDraft.h"
#import "WLPublishTaskManager.h"
#import "WLRichTextHelper.h"
#import "WLVideoThumbView.h"
#import "WLContactsManager.h"
#import "WLRichItem.h"
#import "WLEmojiManager.h"
#import "WLPublishCardView.h"
#import "WLAssetsBrowseViewController.h"
#import "WLAVPlayerView.h"
#import "WLTopicSearchViewController.h"
#import "WLTopicInfoModel.h"
#import "WLTextParse.h"
#import "WLEULAViewController.h"
#import "WLDraftViewController.h"
#import "WLDraftManager.h"
#import "WLPlayerViewController.h"
#import "WLVoteView.h"
#import "IQKeyboardManager.h"

#import "WLPostBottomView.h"
#import "WLAbstractCameraViewController.h"
#import "WLAlertController.h"
#import "WLTopicBtn.h"
#import "WLTrackerRepostAndComment.h"
#import "WLRecordShortVideoController.h"
#import "WLCropVideoViewController.h"

#define kToolbarHeight 79
#define kPostbarHeight_small 76
#define kPostbarHeight_large 110
#define kTextViewOffset 32


#define ActionSheet_tag_save_draft 11
#define ActionSheet_tag_no_save_draft 12

@interface WLBasePostViewController ()<YYTextViewDelegate,WLTextViewBottomBarDelegate,WLAssetsViewControllerDelegate,ThumbGridViewDelegate,WLEmoticonInputViewDelegate,WLNavigationBarDelegate,UIActionSheetDelegate,WLVoteViewDelegate,WLAbstractCameraViewControllerDelegate,WLPostBottomViewDelegate>
{
    CGFloat keyboardHeight;
    WLEmoticonInputView *emoticonInputView;
    
    NSString *realTimeTextStr; //输入时候的实时文本
}


@property (strong,nonatomic) WLLinkInputView *linkInputView;
@property (strong,nonatomic) WLMaskView *maskView;
@property (assign,nonatomic) BOOL isChange;


@end

@implementation WLBasePostViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _mentionList = [[NSMutableArray alloc] initWithCapacity:0];
    _linkList = [[NSMutableArray alloc] initWithCapacity:0];
    _topicList = [[NSMutableArray alloc] initWithCapacity:0];
    _attachmentArray = [[NSMutableArray alloc] initWithCapacity:0];
    _charNum = 0;
    
    draftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [draftBtn setTitle:[AppContext getStringForKey:@"publish_draft_title" fileName:@"publish"] forState:UIControlStateNormal];
    draftBtn.frame = CGRectMake(0, 0, 56, 44);
    [draftBtn setTitleColor:kMainColor forState:UIControlStateNormal];
    draftBtn.titleLabel.font = kBoldFont(16);
    [draftBtn addTarget:sendBtn action:@selector(draftBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(0, 0, 56, 24);
    sendBtn.showsTouchWhenHighlighted = YES;
    [sendBtn setTitleColor:send_text_color_disable forState:UIControlStateNormal];
    [sendBtn setTitle:[AppContext getStringForKey:@"editor_post_send" fileName:@"publish"] forState:UIControlStateNormal];
    sendBtn.titleLabel.font = kBoldFont(14);
    sendBtn.backgroundColor = kLargeBtnDisableColor;
    sendBtn.layer.cornerRadius = 3;
    [sendBtn addTarget:self action:@selector(sendBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if (_type == WELIKE_DRAFT_TYPE_FORWARD_POST || _type == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
    {
        sendBtn.enabled = YES;
        sendBtn.backgroundColor = kMainColor;
        [sendBtn setTitleColor:send_text_color_enable forState:UIControlStateNormal];
    }
    else
    {
        sendBtn.enabled = NO;
        sendBtn.backgroundColor = kLargeBtnDisableColor;
        [sendBtn setTitleColor:send_text_color_disable forState:UIControlStateNormal];
    }
    
    self.navigationBar.rightBtnArrayWithGap = [NSArray arrayWithObjects:sendBtn,draftBtn, nil];
    
    if (kIsiPhoneX)
    {
        _textViewBottomBar = [[WLTextViewBottomBar alloc] initWithFrame:CGRectMake(0, kScreenHeight - kToolbarHeight - 34, kScreenWidth,kToolbarHeight + 34) type:_type];

    }
    else
    {
        _textViewBottomBar = [[WLTextViewBottomBar alloc] initWithFrame:CGRectMake(0, kScreenHeight - kToolbarHeight, kScreenWidth,kToolbarHeight) type:_type];
    }
    
    _textViewBottomBar.delegate = self;
    [self.view addSubview:_textViewBottomBar];
    
    if (_type == WELIKE_DRAFT_TYPE_POST)
    {
         _textView = [[YYTextView alloc]initWithFrame:CGRectMake(0, kNavBarHeight + kTextViewOffset, kScreenWidth, kScreenHeight - kNavBarHeight - kToolbarHeight - kTextViewOffset)];
    }
    else
    {
         _textView = [[YYTextView alloc]initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight - kToolbarHeight)];
    }
    
    _textView.tintColor = kMainColor;
    //  _textView.backgroundColor = [UIColor redColor];
    _textView.textContainerInset = UIEdgeInsetsMake(15, 15, 20, 10);
    _textView.showsVerticalScrollIndicator = NO;
    _textView.alwaysBounceVertical = YES;
    _textView.font = kRegularFont(14);
    _textView.allowsPasteAttributedString = NO;
    _textView.allowsCopyAttributedString = NO;
    _textView.textParser = [WLTextEditParser new];
    _textView.delegate = self;
    _textView.extraAccessoryViewHeight = kToolbarHeight;
    _textView.inputAccessoryView = [UIView new];
    _textView.extraBottomViewSize = 37;//纯文本也应该设置
    
    __weak typeof(self) weakSelf = self;
    
    _thumbGridView = [[WLThumbGridView alloc] initWithFrame:CGRectMake(15, 105, kScreenWidth - 30, 0) withTarget:self];
    _thumbGridView.delegate = self;
    [_textView addSubview:_thumbGridView];
    
    _videoThumbView = [[WLVideoThumbView alloc] initWithFrame:CGRectMake(15, 105, kScreenWidth - 30, 186)];
    _videoThumbView.closeBlock =  ^(){
        [weakSelf.attachmentArray removeAllObjects];
        [weakSelf enableOrDisableSendBtn];
        weakSelf.videoThumbView.hidden = YES;
        
        //可以投票
        [weakSelf.postBottomBar enableAllBtn];
        [weakSelf handleTopicPosition];
    };
    _videoThumbView.playSelectVideo = ^{
        [weakSelf tapVideoThumbView];
    };
    
    [_textView addSubview:_videoThumbView];
    _videoThumbView.hidden = YES;
    
    _voteView = [[WLVoteView alloc] initWithFrame:CGRectMake(0, 105, kScreenWidth, 0)];
    _voteView.delegate = self;
//    _voteView.backgroundColor = [UIColor blueColor];
    [_textView addSubview:_voteView];
    _voteView.hidden = YES;
    
    _superTopicBtn = [[WLTopicBtn alloc] initWithFrame:CGRectMake(15, kNavBarHeight + 5, 100, 27)];
    [_superTopicBtn addTarget:self action:@selector(superTopicBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_superTopicBtn];
    _superTopicBtn.hidden = YES;
 
    
    _publishCardView = [[WLPublishCardView alloc] initWithFrame:CGRectMake(15, 105, kScreenWidth - 30, 64)];
    _publishCardView.layer.borderColor = postCardFrameColor.CGColor;
    _publishCardView.layer.borderWidth = 0.5;
    _publishCardView.layer.cornerRadius = 3;
    _publishCardView.clipsToBounds = YES;
    [self.textView addSubview:_publishCardView];
    _publishCardView.hidden = YES;
    
    WLTextLinePositionModifier *modifier = [WLTextLinePositionModifier new];
    modifier.font = kRegularFont(14);
    modifier.paddingTop = 12;
    modifier.paddingBottom = 12;
    modifier.lineHeightMultiple = 1.5;
    _textView.linePositionModifier = modifier;
    
    [self.view addSubview:_textView];

    
      if (self.type != WELIKE_DRAFT_TYPE_POST)
      {
              if ([[NSUserDefaults standardUserDefaults] objectForKey:@"eula"] != nil)
              {
                  [_textView becomeFirstResponder];
              }
      }
    
    NSString *placeHolderStr = [AppContext getStringForKey:@"editor_edit_text_hint" fileName:@"publish"];
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:placeHolderStr];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[NSFontAttributeName] = kRegularFont(14);
    dic[NSForegroundColorAttributeName] = kPlaceHolderColor;
    [atr addAttributes:dic range:NSMakeRange(0, atr.length)];
    _textView.placeholderAttributedText = atr;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"eula"] == nil)
    {
        self.navigationBar.hidden = YES;
        WLEULAViewController *vc = [[WLEULAViewController alloc] init];
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
        vc.accept = ^{
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"eula"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.navigationBar.hidden = NO;
            [self.textView becomeFirstResponder];
        };
        vc.cancel = ^{
            [self closeBtnPressed];
        };
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:80];
    [[IQKeyboardManager sharedManager] registerTextFieldViewClass:[YYTextView class] didBeginEditingNotificationName:YYTextViewTextDidBeginEditingNotification didEndEditingNotificationName:YYTextViewTextDidEndEditingNotification];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_textView resignFirstResponder];
}

-(void)closeBtnPressed
{
    [_textView resignFirstResponder];
    
    [self dismissAndPop];
}

-(void)draftBtnPressed
{
    if (_isReadFromDraft)
    {
        [self navigationBarLeftBtnDidClicked];
    }
    else
    {
        WLDraftViewController *draftViewController = [[WLDraftViewController alloc] init];
        
        [self.navigationController pushViewController:draftViewController animated:YES];
    }
}

-(void)sendBtnPressed
{
    
}


-(void)superTopicBtnPressed
{
    [self topicBtn];
}

#pragma mark - send 按钮控制
-(void)updateCharNum:(NSInteger)charNum
{
    if (_type == WELIKE_DRAFT_TYPE_POST)
    {
        [_postBottomBar changeCharNum:_charNum];
        [self handlePostSendBtn];
    }
    else
    {
        [_textViewBottomBar changeCharNum:_charNum];
        [self handlecommentAndReplySendBtn:_charNum];
    }
}

-(void)handleSendBtnInVoteStatus
{
    if (_isVoteStatus)
    {
        if ([_voteView ifDisableSendBtn])
        {
            [self disablePostSendBtn];
        }
        else
        {
            if (realTimeTextStr.length > 0 && _charNum <= 1000)
            {
                [self enablePostSendBtn];
            }
            else
            {
                 [self disablePostSendBtn];
            }
        }
    }
}

-(void)handleTopicPosition
{
//    if (_isVoteStatus)
//    {
//        _superTopicBtn.top = [_voteView dropdownMenuBottom] + _voteView.top + 5;
//        return;
//    }
//
//    WLAssetModel *assetModel = _attachmentArray.firstObject;
//
//    if (_attachmentArray.count > 0)
//    {
//        if (assetModel.type == WLAssetModelType_Photo || WLAssetModelType_Camera)
//        {
//            _superTopicBtn.top = _thumbGridView.bottom + 5;
//        }
//        else
//            if (assetModel.type == WLAssetModelType_Video)
//            {
//                _superTopicBtn.top = _videoThumbView.bottom + 5;
//            }
//
//    }
//    else
//    {
//         if (_textView.contentSize.height - _textView.extraBottomViewSize > 117)
//         {
//            _superTopicBtn.top = 105 + _textView.contentSize.height - 117 - _textView.extraBottomViewSize;
//         }
//        else
//        {
//            _superTopicBtn.top = 105;
//        }
//    }
}



#pragma mark keyboardNotification
- (void)keyboardWasShown:(NSNotification *)notif
{
    //根据键盘高度调整控件位置
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
 
    
    CGSize keyboardSize = [value CGRectValue].size;
    keyboardHeight = keyboardSize.height;
    
    
    if (_type == WELIKE_DRAFT_TYPE_POST)
    {
        if (kIsiPhoneX)
        {
             _textView.frame = CGRectMake(0, _textView.frame.origin.y, _textView.frame.size.width, kScreenHeight - kNavBarHeight - keyboardHeight - kPostbarHeight_small - kTextViewOffset - 36);
        }
        else
        {
             _textView.frame = CGRectMake(0, _textView.frame.origin.y, _textView.frame.size.width, kScreenHeight - kNavBarHeight - keyboardHeight - kPostbarHeight_small - kTextViewOffset);
        }
        
        
        _postBottomBar.top = kScreenHeight - keyboardHeight - kPostbarHeight_small;
        if (_postBottomBar)
        {
            [_postBottomBar changeInputStatus:YES];
        }
        _textView.extraAccessoryViewHeight = _postBottomBar.height;
    }
    else
    {
        _textView.frame = CGRectMake(0, _textView.frame.origin.y, _textView.frame.size.width, kScreenHeight - kNavBarHeight - keyboardHeight - kToolbarHeight);
         _textViewBottomBar.top = kScreenHeight - keyboardHeight - kToolbarHeight;
    }
    
    
//    _textViewBottomBar.top = _textView.bottom;
}

-(void)keyboardWillhide:(NSNotification *)notif
{
    keyboardHeight = 0;
    if (kIsiPhoneX)
    {
        if (_type == WELIKE_DRAFT_TYPE_POST)
        {
            _textView.frame = CGRectMake(0, _textView.frame.origin.y, _textView.frame.size.width, kScreenHeight - kNavBarHeight - keyboardHeight -  kPostbarHeight_large - 34 - kTextViewOffset);
        }
        else{
            _textView.frame = CGRectMake(0, _textView.frame.origin.y, _textView.frame.size.width, kScreenHeight - kNavBarHeight - keyboardHeight -  kToolbarHeight - 34);
        }
        
        
         _textViewBottomBar.top = kScreenHeight - 34 - kToolbarHeight;
         _postBottomBar.top =  kScreenHeight - 34 - kPostbarHeight_large;
    }
    else
    {
          if (_type == WELIKE_DRAFT_TYPE_POST)
          {
                _textView.frame = CGRectMake(0, _textView.frame.origin.y, _textView.frame.size.width, kScreenHeight - kNavBarHeight - keyboardHeight -  kPostbarHeight_large - kTextViewOffset);
          }
        else
        {
              _textView.frame = CGRectMake(0, _textView.frame.origin.y, _textView.frame.size.width, kScreenHeight - kNavBarHeight - keyboardHeight -  kToolbarHeight);
        }
        
      
        _textViewBottomBar.top = kScreenHeight - kToolbarHeight;
        _postBottomBar.top =  kScreenHeight - kPostbarHeight_large;
    }
    
    if (_postBottomBar)
    {
        [_postBottomBar changeInputStatus:NO];
         _textView.extraAccessoryViewHeight = _postBottomBar.height;
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notif
{
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGSize keyboardSize = [value CGRectValue].size;
    keyboardHeight = keyboardSize.height;
}

#pragma mark YYTextViewDelegate
-(void)tapTextView
{
    if ([_textView.inputView isKindOfClass:[WLEmoticonInputView class]])
    {
        [self emojiBtn];
    }
    
    //如果是投票模式,则scroll可以滑动
//    if (_isVoteStatus)
//    {
//        _textView.scrollEnabled = YES;
//    }
}

- (void)textViewDidBeginEditing:(YYTextView *)textView
{
    if (_postBottomBar)
    {
        [_postBottomBar changeInputStatus:YES];
       
        
        if (_isVoteStatus)
        {
            [_postBottomBar enableALLBtnExceptVoteAndPhotoBtn];
        }
    }
}

- (void)textViewDidChange:(YYTextView *)textView
{
   // NSLog(@"text======%f",textView.contentSize.height - _textView.extraBottomViewSize);
    
    //when change > screenheight,change position of thunbView
    if (textView.contentSize.height - _textView.extraBottomViewSize > 117)
    {
        _thumbGridView.top = 105 + textView.contentSize.height - 117 - _textView.extraBottomViewSize;
        _videoThumbView.top = _thumbGridView.top;
        _publishCardView.top = _thumbGridView.top;
        _voteView.top = _thumbGridView.top;
    }
    else
    {
        _thumbGridView.top = 105;
        _videoThumbView.top = _thumbGridView.top;
        _publishCardView.top = _thumbGridView.top;
        _voteView.top = _thumbGridView.top;
    }
    
    [self handleTopicPosition];
}


- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"input:%@",text);
    NSLog(@"range:%lu === %lu",(unsigned long)range.location,(unsigned long)range.length);
    __weak typeof(self) weakSelf = self;
    
    _isChange = YES;
    
    if (text.length > 0)
    {
        NSArray *allEmojis =  [WLEmojiManager emotionsArray];
        BOOL isFond = NO;
        NSInteger inputLength = text.length;
        
        //如果是表情
        NSArray *emojiArray = [WLTextParse matcheInString:text regularExpressionWithPattern:emojiRegular];
        if (emojiArray.count > 0)
        {
            for (NSTextCheckingResult *result in emojiArray)
            {
                 NSString *emojiName = [WLTextParse replacementStringForResult:result inString:text regularExpressionWithPattern:emojiRegular];
                
                if ([allEmojis containsObject:[emojiName substringWithRange:NSMakeRange(1, emojiName.length - 2)]])
                {
                    self->_charNum += 2;
                    isFond = YES;
                    [self updateCharNum: self->_charNum];
                }
                
                inputLength -= emojiName.length;
            }
            
            if (inputLength > 0)
            {
                  self->_charNum += inputLength;
                  [self updateCharNum: self->_charNum];
            }
        }
        
        //如果是链接
        if ([text rangeOfString:@"•Web Links<Link="].length > 0)
        {
            self->_charNum += 10;
             isFond = YES;
             [self updateCharNum: self->_charNum];
        }
        
        //如果是@
        if ([text rangeOfString:@"<mention=@"].length > 0 )
        {
            for (NSDictionary *dic in self.mentionList)
            {
                if ([[text substringFromIndex:10] isEqualToString:dic.allKeys.firstObject])
                {
                    isFond = YES;
                    self->_charNum += 4;
                    [self updateCharNum: self->_charNum];
                    break;
                }
            }
        }
        
        //如果是#
        if ([text rangeOfString:@"<topic=#"].length > 0 )
        {
            for (WLTopicInfoModel *info in self.topicList)
            {
                if ([[text substringFromIndex:8] isEqualToString:info.topicName])
                {
                    isFond = YES;
                    self->_charNum += 4;
                    [self updateCharNum: self->_charNum];
                    break;
                }
            }
        }
        
        if (isFond == NO)
        {
            //如果range的范围和当前的文本范围不一致,则字数应该发生变化
            if (text.length != range.length)
            {
                self->_charNum += (text.length - range.length);
            }
            else
            {
                self->_charNum += text.length;
            }
            
            if ([text isEqualToString:@"@"])
            {
                [weakSelf contactBtn];
            }
            if ([text isEqualToString:@"#"])
            {
                 [weakSelf topicBtn];
            }
          
            [self updateCharNum: self->_charNum];
        }
    }
    
    if (text.length == 0)
    {
        [WLRichTextHelper allRichItems:self.textView.attributedText mentionArray:self.mentionList linkArray:self.linkList result:^(NSArray *itemList) {
            
            NSInteger removeNum = range.length;
            NSInteger from = range.location + range.length - 1;
            while (removeNum > 0)
            {
                 BOOL isRichItem = NO;
                
                  for (WLRichItem *item in itemList)
                  {
                      if (from >= item.index && from < item.index + item.length)
                      {
                          isRichItem = YES;
                          if ([item.type isEqualToString:WLRICH_TYPE_TOPIC])
                          {
                              weakSelf.charNum -= 4;
                                                            
                              for (NSInteger i = weakSelf.topicList.count - 1; i >= 0; i--)
                              {
                                  WLTopicInfoModel *info = weakSelf.topicList[i];
                                  
                                  if ([info.topicName isEqual:[item.source substringFromIndex:1]])
                                  {
                                       [weakSelf.topicList removeObject:info];
                                  }
                              }
                              
                              if (weakSelf.topicList.count < 3)
                              {
                                  [weakSelf.textViewBottomBar enableTopicBtn];
                                  [weakSelf.superTopicBtn  changeToEnable];
                              }
                              
                              removeNum -= item.length;
                              from -= item.length;
                          }
                          
                          if ([item.type isEqualToString:WLRICH_TYPE_EMOJI])
                          {
                              weakSelf.charNum -= 2;
                              removeNum -= 1;
                              from -= 1;
                          }
                          
                          if ([item.type isEqualToString:WLRICH_TYPE_LINK])
                          {
                              weakSelf.charNum -= 10;
                              removeNum -= item.length;
                              from -= item.length;
                              
                              for (NSInteger i = weakSelf.linkList.count - 1; i >= 0; i--)
                              {
                                  NSString *linkStr = weakSelf.linkList[i];
                                  if ([linkStr isEqualToString:item.source])
                                  {
                                      [weakSelf.linkList removeObject:linkStr];
                                      break;
                                  }
                              }
                          }
                          
                          if ([item.type isEqualToString:WLRICH_TYPE_MENTION])
                          {
                              weakSelf.charNum -= 4;
                              removeNum -= item.length;
                              from -= item.length;
                              
                              for (NSInteger i = weakSelf.mentionList.count - 1; i >= 0; i--)
                              {
                                  NSDictionary *dic = weakSelf.mentionList[i];
                                  if ([dic.allKeys.firstObject isEqualToString:[item.source substringFromIndex:1]])
                                  {
                                      [weakSelf.mentionList removeObject:dic];
                                      break;
                                  }
                              }
                          }
                       
                          [weakSelf updateCharNum: weakSelf.charNum];
                      }
                  }
                
                if (isRichItem == NO)
                {
                    weakSelf.charNum -= 1;
                    removeNum -= 1;
                     from -= 1;
                    [self updateCharNum:weakSelf.charNum];
                }
            }
        }];
    }
    
    if (_type == WELIKE_DRAFT_TYPE_FORWARD_POST || _type == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
    {
        return YES;
    }
    else
    {
        //判断是否为空,是否可以发
        NSString *allString;
        
        if (range.length > 0)
        {
            allString = [NSString stringWithString:[textView.text stringByReplacingCharactersInRange:range withString:text]];
        }
        else
        {
            allString = [NSString stringWithFormat:@"%@%@",textView.text,text];
        }
        
        realTimeTextStr =  [allString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //可以看成是实时输入的内容
        
        //NSLog(@"======%@",realTimeTextStr);
        
        if (realTimeTextStr.length == 0)
        {
            [self enablePostSendBtn];
        }
        
         [self updateCharNum: self->_charNum];
        
        return YES;
    }
}

#pragma mark ScrollDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   // NSLog(@"=======%f",scrollView.contentOffset.y);
}




#pragma mark WLNavigationBarDelegate
//-(void)navigationBarRightBtnDidClicked
//{
//    if (_isReadFromDraft)
//    {
//        [self navigationBarLeftBtnDidClicked];
//    }
//    else
//    {
//        WLDraftViewController *draftViewController = [[WLDraftViewController alloc] init];
//
//        [self.navigationController pushViewController:draftViewController animated:YES];
//    }
//}


-(void)leftNavBtnPressed
{
    //检测如果有改动,则弹出
    NSString *stringRemovedWhitespace =  [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [_textView resignFirstResponder];
    
    if (_type == WELIKE_DRAFT_TYPE_POST && stringRemovedWhitespace.length == 0 && self.attachmentArray.count == 0)
    {
        _isChange = NO;
    }
    
    if ((_type == WELIKE_DRAFT_TYPE_COMMENT || _type == WELIKE_DRAFT_TYPE_REPLY || _type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY) && stringRemovedWhitespace.length == 0) {
         _isChange = NO;
    }
    
    //投票情况直接设为NO
    if (_type == WELIKE_DRAFT_TYPE_POST && _isVoteStatus)
    {
        _isChange = NO;
    }
    
    
    if (_isChange)
    {
        UIActionSheet *quitSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[AppContext getStringForKey:@"editor_discard_cancel" fileName:@"publish"] destructiveButtonTitle:[AppContext getStringForKey:@"editor_discard_save" fileName:@"publish"] otherButtonTitles:[AppContext getStringForKey:@"editor_discard_confrim" fileName:@"publish"], nil];
        quitSheet.tag = ActionSheet_tag_save_draft;
        [quitSheet showInView:self.view];
    }
    else
        if (_isVoteStatus)
        {
            UIActionSheet *quitSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[AppContext getStringForKey:@"editor_discard_cancel" fileName:@"publish"] destructiveButtonTitle:nil otherButtonTitles:[AppContext getStringForKey:@"editor_discard_confrim" fileName:@"publish"], nil];
            quitSheet.tag = ActionSheet_tag_no_save_draft;
            [quitSheet showInView:self.view];
        }
        else
        {
            [self dismissAndPop];
        }
}

#pragma mark WLTextViewBottomBarDelegate
-(void)locationBtn
{
    
}

-(void)locationDeleteBtn
{
    
}

-(void)albumBtn
{
   //重载
}

-(void)camareBtn
{
   //重载
}

-(void)videoBtn
{
    //重载
}


-(void)contactBtn
{
    __weak typeof(self) weakSelf = self;
    
     [WLPublishTrack mentionBtnClicked:self.source main_source:self.mainSource page_type:_page_type];
    
    
    WLContactListViewController *contactListViewController = [[WLContactListViewController alloc] init];
    RDRootViewController *nav = [[RDRootViewController alloc] initWithRootViewController:contactListViewController];
    
    contactListViewController.select = ^(WLContact *contact) {
        
        [WLPublishTrack contactPageSelectPersons:self.source main_source:self.mainSource page_type:self.page_type];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:contact.uid,contact.nickName,nil];
        
        [self->_mentionList addObject:dic];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_textView becomeFirstResponder];
            
            NSRange contactRange = [self textRangeToRange:weakSelf.textView.selectedTextRange];;
            contactRange.length = 1;
            
            if (contactRange.location >= 1)
            {
                NSString *lastChar =  [weakSelf.textView.text substringFromIndex:weakSelf.textView.text.length - 1];
                //NSLog(@"%@",lastChar);
                //删除
                if ([lastChar isEqualToString:@"@"])
                {
                      [weakSelf.textView deleteBackward];
                }
            }
            
            [self->_textView replaceRange:self->_textView.selectedTextRange withText:[NSString stringWithFormat:@"<mention=@%@",contact.nickName,nil]];
            [self->_textView replaceRange:self->_textView.selectedTextRange withText:@" "];
        });
    };
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

-(void)emojiBtn
{
    if (_textView.inputView) {
        _textView.inputView = nil;
        [_textView reloadInputViews];
        [_textView becomeFirstResponder];
        
        [_textViewBottomBar changeToEmojiStatus:NO];
          [_postBottomBar changeToEmojiStatus:NO];
        
    }
    else {
        [WLPublishTrack publishEmojiBtnClicked:self.source main_source:self.mainSource page_type:_page_type];
        
        WLEmoticonInputView *emoticonInputView = [WLEmoticonInputView sharedView];
        emoticonInputView.delegate = self;
        _textView.inputView = emoticonInputView;
        [_textView reloadInputViews];
        [_textView becomeFirstResponder];
        
        [_textViewBottomBar changeToEmojiStatus:YES];
         [_postBottomBar changeToEmojiStatus:YES];
    }
}

-(void)linkBtn
{
     [WLPublishTrack linkBtnClicked:self.source main_source:self.mainSource page_type:_page_type];
    if ([_textView.inputView isKindOfClass:[WLEmoticonInputView class]])
    {
        _textView.inputView = nil;
        [_textView reloadInputViews];
        [_textView becomeFirstResponder];
        [_textViewBottomBar changeToEmojiStatus:NO];
         [_postBottomBar changeToEmojiStatus:NO];
    }
    
    
    __weak typeof(self) weakSelf = self;
    
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    
    if (!_maskView)
    {
        _maskView = [[WLMaskView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _maskView.closeBlock =  ^(){
            
            [weakSelf.textView becomeFirstResponder];
            
            [UIView animateWithDuration:.3 animations:^{
                weakSelf.maskView.alpha = 0;
                weakSelf.linkInputView.top = kScreenHeight - self->keyboardHeight;
            } completion:^(BOOL finished) {
                if (finished) {
                    [weakSelf.maskView removeFromSuperview];
                    weakSelf.maskView = nil;
                    [weakSelf.linkInputView removeFromSuperview];
                    weakSelf.linkInputView = nil;
                }
            }];
        };
        
        [keywindow addSubview:_maskView];
    }
    
    
    if (!_linkInputView)
    {
        _linkInputView = [[WLLinkInputView alloc] initWithFrame:CGRectZero];
        _linkInputView.submitBlock = ^(NSString *linkStr) {
            
            NSString *linkString = [NSString stringWithFormat:@"•Web Links<Link=%@>",linkStr];
            [weakSelf.linkList addObject:linkStr];
            [weakSelf.textView replaceRange:weakSelf.textView.selectedTextRange withText:linkString];
            [weakSelf.linkInputView closeBtnPressed];
            
            [weakSelf enableOrDisableSendBtn];
              [WLPublishTrack publishLinkTInputViewClick:weakSelf.source main_source:weakSelf.mainSource page_type:weakSelf.page_type];
        };
        
        _linkInputView.closeBlock =  ^(){
            [weakSelf.textView becomeFirstResponder];
            [UIView animateWithDuration:.3 animations:^{
                weakSelf.maskView.alpha = 0;
                weakSelf.linkInputView.top = kScreenHeight - self->keyboardHeight;
            } completion:^(BOOL finished) {
                if (finished) {
                    [weakSelf.maskView removeFromSuperview];
                    weakSelf.maskView = nil;
                    [weakSelf.linkInputView removeFromSuperview];
                    weakSelf.linkInputView = nil;
                }
            }];
        };
        
        [keywindow addSubview:_linkInputView];
    }
    
    
    if (![_textView isFirstResponder])
    {
         [_textView becomeFirstResponder];
    }
   
    _linkInputView.frame = CGRectMake(0, kScreenHeight - keyboardHeight, kScreenWidth, 135);
    _maskView.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        weakSelf.maskView.alpha = 1;
        weakSelf.linkInputView.bottom = kScreenHeight - self->keyboardHeight;
    }completion:^(BOOL finished) {
        [weakSelf.linkInputView becomeFirstResponder];
        [WLPublishTrack publishLinkBtnDisplayed:weakSelf.source main_source:weakSelf.mainSource page_type:weakSelf.page_type];
    }];
}

-(void)topicBtn
{
    [WLPublishTrack addTopicClicked:self.source main_source:self.mainSource page_type:self.page_type];
    
    if (self.topicList.count >= 3)
    {
        [self showToast:[AppContext getStringForKey:@"topic_count_over_limit" fileName:@"publish"]];
        return;
    }
    
    
    __weak typeof(self) weakSelf = self;
    WLTopicSearchViewController *topicSearchViewController = [[WLTopicSearchViewController alloc] init];
    topicSearchViewController.select = ^(WLTopicInfoModel *topic) {
        
        if (topic.topic_source > 0)
        {
            [WLPublishTrack topicSelect:self.source main_source:self.mainSource page_type:self.page_type topic_source:topic.topic_source topic_id:topic.topicID];
        }
        
        if (self->_topic_source == 0)
        {
            self->_topic_source = topic.topic_source;
        }
        
        
        
        if (topic.topicName.length == 0)
        {
            return;
        }
        
        [weakSelf.topicList addObject:topic];
        
        if (weakSelf.topicList.count < 3)
        {
            [weakSelf.textViewBottomBar enableTopicBtn];
             [weakSelf.superTopicBtn  changeToEnable];
        }
        else
        {
             [weakSelf.textViewBottomBar disableTopicBtn];
            [weakSelf.superTopicBtn  changeToDisable];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.textView becomeFirstResponder];
            
            NSRange contactRange = [self textRangeToRange:weakSelf.textView.selectedTextRange];;
            contactRange.length = 1;
            
            if (contactRange.location >= 1)
            {
                NSString *lastChar =  [weakSelf.textView.text substringFromIndex:weakSelf.textView.text.length - 1];
                //NSLog(@"%@",lastChar);
                //删除
                if ([lastChar isEqualToString:@"#"])
                {
                    [weakSelf.textView deleteBackward];
                }
            }
            
            [weakSelf.textView replaceRange:weakSelf.textView.selectedTextRange withText:[NSString stringWithFormat:@"<topic=#%@",topic.topicName,nil]];
            [weakSelf.textView replaceRange:weakSelf.textView.selectedTextRange withText:@" "];
        });
        
    };
    
    topicSearchViewController.hasIput = ^{
         [WLPublishTrack inputTopicInSearchBar:self.source main_source:self.mainSource page_type:self.page_type];
    };
    
    
    RDRootViewController *assetNav = [[RDRootViewController alloc] initWithRootViewController:topicSearchViewController];
    
    [self presentViewController:assetNav animated:YES completion:^{
        [WLPublishTrack searchTopicControllerAppear:self.source main_source:self.mainSource page_type:self.page_type];
    }];

}

-(void)voteBtn
{
    
}


- (void)statusBtnPressed{
}


#pragma mark WLEmoticonInputViewDelegate
- (void)emoticonInputDidTapText:(NSString *)text
{
    if (text.length)
    {
        [_textView replaceRange:_textView.selectedTextRange withText:[NSString stringWithFormat:@"[%@]",text]];
    }
}

- (void)emoticonInputDidTapBackspace
{
    [_textView deleteBackward];
    [self enableOrDisableSendBtn];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ThumbGridViewDelegate
-(void)removeThumbAtIndex:(NSInteger)index
{
    if (_attachmentArray.count > index)
    {
        [_attachmentArray removeObjectAtIndex:index];
    }
    
    //重新分配序号
    for ( int i = 0; i < _attachmentArray.count; i++)
    {
        WLAssetModel *model = _attachmentArray[i];
        model.checkedIndex = i+1;
    }
    
    [self enableOrDisableSendBtn];
    
    if (_attachmentArray.count == 0)
    {
        //可以投票
        [self.postBottomBar enableAllBtn];
        [self handleTopicPosition];
    }
}

-(void)browseThumbAtIndex:(NSInteger)index
{
    WLAssetsBrowseViewController *assetsBrowseViewController = [[WLAssetsBrowseViewController alloc] initWithItemArray:_attachmentArray  currentIndex:index];
    assetsBrowseViewController.statusBarHidden = YES;
    [self.navigationController pushViewController:assetsBrowseViewController animated:YES];
}

-(void)addPhoto
{
    WLAssetsViewController *assetsViewController = [[WLAssetsViewController alloc] initWithCheckedArray:_attachmentArray];
    assetsViewController.delegate = self;
    RDRootViewController *assetNav = [[RDRootViewController alloc] initWithRootViewController:assetsViewController];
    
    [self presentViewController:assetNav animated:YES completion:^{
        
    }];
}

-(void)tapVideoThumbView
{
    //    WLAssetsBrowseViewController *assetsBrowseViewController = [[WLAssetsBrowseViewController alloc] initWithItemArray:_attachmentArray  currentIndex:0];
    //    assetsBrowseViewController.statusBarHidden = YES;
    //    [self.navigationController pushViewController:assetsBrowseViewController animated:YES];
    
    WLAssetModel *assetModel = _attachmentArray.firstObject;
    
    if (assetModel.avAsset) {
        WLPlayerViewController *ctr = [[WLPlayerViewController alloc] initWithAsset:assetModel.avAsset];
        ctr.isLightStatusBar = YES;
        [self.navigationController pushViewController:ctr animated:YES];
        
    } else if (assetModel.asset) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:assetModel.asset
                                                        options:nil
                                                  resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          WLPlayerViewController *ctr = [[WLPlayerViewController alloc] initWithAsset:asset];
                                                          ctr.isLightStatusBar = YES;
                                                          [self.navigationController pushViewController:ctr animated:YES];
                                                      });
                                                  }];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.textView resignFirstResponder];
    
    if (actionSheet.tag == ActionSheet_tag_save_draft)
    {
        if (buttonIndex == 0)
        {
            _isSaveMod = YES;

            [self sendBtnPressed];

            
            [WLTrackerRepostAndComment appendTrackerWithDraft:self.draftBase
                                                       status:WLTrackerReAndComStatus_Draft];

            _exit_type = WLTrackerPublishExit_draft;
        }
        
        if (buttonIndex == 1)
        {
            [self dismissAndPop];
            
            [WLTrackerRepostAndComment appendTrackerWithDraft:self.draftBase
                                                       status:WLTrackerReAndComStatus_Discard];
             _exit_type = WLTrackerPublishExit_closeWithOutSave;
        }
        
        if (buttonIndex == 2)
        {
            
        }
    }
    
      if (actionSheet.tag == ActionSheet_tag_no_save_draft)
      {
          if (buttonIndex == 0)
          {
              [self dismissAndPop];
              
              [WLTrackerRepostAndComment appendTrackerWithDraft:self.draftBase
                                                         status:WLTrackerReAndComStatus_Discard];
              _exit_type = WLTrackerPublishExit_closeWithOutSave;
          }
          
          if (buttonIndex == 1)
          {
              
          }
      }
}


#pragma mark - WLVoteViewDelegate
-(void)addOption:(CGFloat)currentHeight
{
    _textView.extraBottomViewSize = _voteView.height + 200;
    
    [self disablePostSendBtn];
    
    [self handleTopicPosition];
}

-(void)openAlbum:(NSInteger)indexNum
{
    WLAssetsViewController *assetsViewController = [[WLAssetsViewController alloc] initWithSelectionMode:WLAssetsSelectionMode_Single_poll];
    assetsViewController.delegate = self;
    RDRootViewController *assetNav = [[RDRootViewController alloc] initWithRootViewController:assetsViewController];
    
    [self presentViewController:assetNav animated:YES completion:^{
    }];
}

-(void)allOptionHasbeenFill:(BOOL)isFill
{
    [self handleTopicPosition];
    if (isFill)
    {
        BOOL whetherDisable  = [_voteView ifDisableSendBtn];
        if (whetherDisable)
        {
            [self disablePostSendBtn];
        }
        else{
            [self enablePostSendBtn];
        }
    }
    else
    {
        [self disablePostSendBtn];
    }
    
}

- (void)optionBeginToInput {
    //reload
}


- (void)optionEndInput {
      //reload
}

-(void)tapMenu
{
    [_textView bringSubviewToFront:_voteView];
}

-(void)foldMenu
{
      [_textView bringSubviewToFront:_superTopicBtn];
}





#pragma mark - WLAssetsViewControllerDelegate
- (void)assetsViewCtr:(WLAssetsViewController *)viewCtr didSelectedWithAssetArray:(NSArray *)assetArray
{
    if (assetArray.count == 0)
    {
        return;
    }
    
    WLAssetModel *assetModel = assetArray.firstObject;
    if (assetModel.type == WLAssetModelType_Video)
    {
      
        [_attachmentArray removeAllObjects];
        [_attachmentArray addObjectsFromArray:assetArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_postBottomBar enableVideo];
            [self->_videoThumbView setVideoAsset:assetModel.asset];
            self->_videoThumbView.hidden = NO;
            self->_textView.extraBottomViewSize = self->_videoThumbView.height + 37;//37是addtopic的高度
            [self enableOrDisableSendBtn];
            
            [self->_thumbGridView setImageArray:nil];//每次更新需要清空图片选择
            
            self->_isChange = YES;
            [self handleTopicPosition];
        });
    }
    
    if (assetModel.type == WLAssetModelType_Photo)
    {
        [_attachmentArray removeAllObjects];
        [_attachmentArray addObjectsFromArray:assetArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self->_isVoteStatus == YES)
            {
                [self->_voteView selectVoteImage:assetArray[0]];
                
                [self enableOrDisableSendBtn];
                
                [self handleTopicPosition];
            }
            else
            {
                [self->_postBottomBar enablePhotoCamera];
                [self->_thumbGridView setImageArray:[NSMutableArray arrayWithArray:self->_attachmentArray]];
                self->_textView.extraBottomViewSize = self->_thumbGridView.height + 37;//37是addtopic的高度;
                self->_thumbGridView.hidden = NO;
                [self enableOrDisableSendBtn];
                //每次更新需要清空视频选择
                [self->_videoThumbView setVideoAsset:nil];
                
                self->_isChange = YES;
                
                [self handleTopicPosition];
            }
        });
    }
}

#pragma mark - WLAbstractCameraViewControllerDelegate

- (void)cameraViewCtr:(WLAbstractCameraViewController *)viewCtr didConfirmWithImage:(UIImage *)image {
    if (!image) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [WLAssetsManager saveImageToCameraRoll:image
                                  finished:^(PHAsset *asset) {
                                      
                                      if (weakSelf.attachmentArray.count == 9)
                                      {
                                          [weakSelf.attachmentArray removeLastObject];
                                      }
                                      
                                      WLAssetModel *itemModel = [[WLAssetModel alloc]
                                                                 initWithType:WLAssetModelType_Photo
                                                                 asset:asset];
                                      itemModel.checked = YES;
                                      itemModel.checkedIndex = weakSelf.attachmentArray.count + 1;
                                      
                                      [weakSelf.attachmentArray addObject:itemModel];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self->_postBottomBar enablePhotoCamera];
                                          [self->_thumbGridView setImageArray:[NSMutableArray arrayWithArray:self->_attachmentArray]];
                                          self->_textView.extraBottomViewSize = self->_thumbGridView.height + 37;//37是addtopic的高度
                                          self->_thumbGridView.hidden = NO;
                                          [self enableOrDisableSendBtn];
                                          //每次更新需要清空视频选择
                                          [self->_videoThumbView setVideoAsset:nil];
                                          
                                          self->_isChange = YES;
                                          [self handleTopicPosition];
                                      });
                                  }];
    
    [viewCtr.navigationController popViewControllerAnimated:YES];
}

- (void)cameraViewCtr:(WLAbstractCameraViewController *)viewCtr didConfirmWithVideoAsset:(PHAsset *)videoAsset
{
    if (!videoAsset) {
        return;
    }
    
    WLAssetModel *itemModel = [[WLAssetModel alloc] initWithType:WLAssetModelType_Video asset:videoAsset];
    itemModel.checked = YES;
    itemModel.checkedIndex = 1;
    
    
    [_attachmentArray removeAllObjects];
    [_attachmentArray addObject:itemModel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_postBottomBar  enableVideo];
        [self->_videoThumbView setVideoAsset:videoAsset];
        self->_videoThumbView.hidden = NO;
        self->_textView.extraBottomViewSize = self->_videoThumbView.height + 37;//37是addtopic的高度
        [self enableOrDisableSendBtn];
        
        [self->_thumbGridView setImageArray:nil];
        
        self->_isChange = YES;
        [self handleTopicPosition];
        [viewCtr.navigationController popViewControllerAnimated:YES];
    });
}

//- (void)didConfirmWithVideoAsset:(PHAsset *)videoAsset;
- (void)shortVideoCtr:(WLCropVideoViewController *)viewCtr didConfirmWithVideoAsset:(PHAsset *)videoAsset
{
    if (!videoAsset) {
        return;
    }
    
    WLAssetModel *itemModel = [[WLAssetModel alloc] initWithType:WLAssetModelType_Video asset:videoAsset];
    itemModel.checked = YES;
    itemModel.checkedIndex = 1;
    
    
    [_attachmentArray removeAllObjects];
    [_attachmentArray addObject:itemModel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_postBottomBar  enableVideo];
        [self->_videoThumbView setVideoAsset:videoAsset];
        self->_videoThumbView.hidden = NO;
        self->_textView.extraBottomViewSize = self->_videoThumbView.height + 37;//37是addtopic的高度
        [self enableOrDisableSendBtn];
        
        [self->_thumbGridView setImageArray:nil];
        
        self->_isChange = YES;
        [self handleTopicPosition];
        [viewCtr.navigationController popViewControllerAnimated:YES];
    });
}


//用于实时改变
-(void)handlePostSendBtn
{
    if (_isVoteStatus == YES)
    {
         [self handleSendBtnInVoteStatus];
    }
    else
    {
        if (_charNum > 1000)
        {
            [self disablePostSendBtn];
        }
        else
        {
            if (_attachmentArray.count > 0)
            {
                [self enablePostSendBtn];
            }
            else
            {
                if (realTimeTextStr.length > 0)
                {
                    [self enablePostSendBtn];
                }
                else
                {
                    [self disablePostSendBtn];
                }
            }
        }
    }
}

-(void)handlecommentAndReplySendBtn:(NSInteger)num
{
    if (num == 0)
    {
        if (_type == WELIKE_DRAFT_TYPE_FORWARD_POST || _type == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
        {
            [self enablePostSendBtn];
        }
        else
        {
            [self disablePostSendBtn];
        }
    }
    
    if (num > 0 && num <= 275)
    {
        [self enablePostSendBtn];
    }
    
    if (num > 275 && num <= 1000)
    {
        if (_type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY || _type == WELIKE_DRAFT_TYPE_REPLY || _type == WELIKE_DRAFT_TYPE_COMMENT)
        {
            [self disablePostSendBtn];
        }
        else
        {
            [self enablePostSendBtn];
        }
    }
    
    if (num > 1000)
    {
        if (_type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY || _type == WELIKE_DRAFT_TYPE_REPLY || _type == WELIKE_DRAFT_TYPE_COMMENT)
        {
            [self disablePostSendBtn];
        }
        else
        {
            [self disablePostSendBtn];
        }
    }
}



//此函数不适用实时输入时候的判断,仅作为添加视频和图片后的判断,或者textVIew代理执行后的判断
-(void)enableOrDisableSendBtn
{
    NSString *currentStr = _textView.text;
    
    NSString *stringRemovedWhitespace =  [currentStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    BOOL isCharNumZero = NO;
    
    if (stringRemovedWhitespace.length == 0)
    {
        isCharNumZero = YES;
    }
    
    if (_type == WELIKE_DRAFT_TYPE_POST)
    {
         if (self->_attachmentArray.count == 0 && isCharNumZero == YES)
         {
             [self disablePostSendBtn];
         }
        else
        {
            [self enablePostSendBtn];
        }
    }
    else
    {
        if (_type == WELIKE_DRAFT_TYPE_FORWARD_POST || _type == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
        {
//            [self->_textViewBottomBar enableSendeBtn];
             [self enablePostSendBtn];
        }
        else
        {
            if (isCharNumZero == NO)
            {
               // [self->_textViewBottomBar enableSendeBtn];
                  [self enablePostSendBtn];
            }
            else
            {
                //[self->_textViewBottomBar disableSendBtn];
                [self disablePostSendBtn];
            }
        }
    }
    
    [self handleSendBtnInVoteStatus];
}

//额外处理post情况
-(void)enablePostSendBtn
{
//    NSArray *rightItems = [self.navigationBar rightBtnArray];
//
//    if (_type == WELIKE_DRAFT_TYPE_POST && rightItems.count == 2)
    {
       // UIButton *sendBtn = rightItems[0];
        sendBtn.enabled = YES;
        [sendBtn setTitleColor:send_text_color_enable forState:UIControlStateNormal];
        sendBtn.backgroundColor = kMainColor;
    }
}

-(void)disablePostSendBtn
{
//    NSArray *rightItems = [self.navigationBar rightBtnArray];
//
//    if (_type == WELIKE_DRAFT_TYPE_POST && rightItems.count == 2)
    {
       // UIButton *sendBtn = rightItems[0];
        sendBtn.enabled = NO;
        [sendBtn setTitleColor:send_text_color_disable forState:UIControlStateNormal];
        sendBtn.backgroundColor = kLargeBtnDisableColor;
    }
}


-(NSRange)textRangeToRange:(UITextRange *)textRange
{
    NSInteger startOffset = [_textView offsetFromPosition:_textView.beginningOfDocument toPosition:textRange.start];
    NSInteger endOffset = [_textView offsetFromPosition:_textView.beginningOfDocument toPosition:textRange.end];
    NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
    return offsetRange;
}


-(void)readRichContentFromDraft:(WLDraftBase *)draftBase
{
    WLRichContent *content = draftBase.content;
    
    if (content.richItemList == 0)
    {
        [self.textView replaceRange:self.textView.selectedTextRange withText:content.text];
    }
    else
    {
        NSInteger offsetNum = 0;
        
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
                        self.textView.text = content.text;
                        self.textView.selectedRange = NSMakeRange(content.text.length - 1, 0);
                        
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
                    
                    
                    //这里对异常进行处理,若产生异常,则去掉富文本,只显示普通文本
                    if (richItem.index - frontRichItem.index - frontRichItem.length < 0 || richItem.index - frontRichItem.index - frontRichItem.length > self.textView.text.length)
                    {
                        self.textView.text = content.text;
                        self.textView.selectedRange = NSMakeRange(content.text.length - 1, 0);
                        
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


- (void)dismissAndPop
{
    if (self.presentingViewController)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end

