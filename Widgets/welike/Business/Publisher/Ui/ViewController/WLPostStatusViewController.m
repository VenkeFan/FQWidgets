//
//  WLPostStatusViewController.m
//  welike
//
//  Created by gyb on 2018/11/13.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLPostStatusViewController.h"
#import "WLPostStatusBar.h"
#import "WLPostStatusManager.h"
#import "WLStatusEditTableView.h"
#import "WLSelectStatusBgView.h"
#import "WLStatusInfo.h"
#import "WLPostStatusMenu.h"
#import "WLEmoticonInputView.h"
#import "WLAssetsViewController.h"
#import "WLImageHelper.h"
#import "SDWebImageManager.h"
#import "WLAssetsManager.h"
#import "WLStatusEditCell.h"
#import "WLDraft.h"
#import "WLRichItem.h"
#import "WLPublishTaskManager.h"
#import "TYTextView.h"
#import "WLAuthorizationHelper.h"


#define big_font kBoldFont(40)
#define middle_font kBoldFont(28)
#define small_font kBoldFont(20)

@interface WLPostStatusViewController ()<UITextViewDelegate,WLPostStatusMenuDelegate,WLSelectStatusBgViewDelegate,WLEmoticonInputViewDelegate,WLPostStatusBarDelegate,WLAssetsViewControllerDelegate>
{
    TYTextView *inputView;
    UIFont *currentFont;
    UIButton *changeBtn;
    
    WLPostStatusMenu *postStatusMenu;
    NSArray *statusList;
    
    NSInteger currentSection; //第几个话题
    NSInteger textIndex; //第几句话
    NSInteger currentPicIndex;//第几个图
    
    CGFloat keyboardHeight;
    
    PHAsset *currentAsset;
    
    
    NSInteger emojiNum;
    
    //打点相关
    BOOL isChangedText;
    NSString *imageId;
    NSString *categoryID;
    NSString *categoryName;
    
    
    
//    NSInteger currentSection;
}

@property (nonatomic, strong) WLPostStatusManager *manager;

@property (strong,nonatomic) WLPostDraft *postDraft;

@end



@implementation WLPostStatusViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [AppContext getStringForKey:@"image_status" fileName:@"publish"];
 
    
    
    self.navigationBar.rightBtn.hidden = NO;
    [self.navigationBar setRightBtnImageName:@"Post_status_write"];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenWidth)];
    bgView.contentMode =  UIViewContentModeScaleAspectFill;
//    bgView.backgroundColor = [UIColor redColor];
     bgView.image = [AppContext getImageForKey:@"post_status_placehoder"];
    [self.view addSubview:bgView];
    
    statusEditTableView = [[WLStatusEditTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
    statusEditTableView.transform = CGAffineTransformMakeRotation(M_PI / 2 *3);
    statusEditTableView.backgroundColor = [UIColor clearColor];
    statusEditTableView.editDelegate = self;
//    statusEditTableView.alpha = 0.2;
//    statusEditTableView.backgroundColor = kLightBackgroundViewColor;
    [self.view addSubview:statusEditTableView];
    statusEditTableView.center = CGPointMake( kScreenWidth/2.0 ,kNavBarHeight + kScreenWidth/2.0);

     inputView = [[TYTextView alloc] initWithFrame:CGRectMake(25, kNavBarHeight + (kScreenWidth - 50)/2.0, kScreenWidth - 50, 50)];
    inputView.textAlignment = NSTextAlignmentCenter;
//    inputView.layer.borderWidth = 4;
//    inputView.layer.borderColor = [UIColor redColor].CGColor;
    inputView.backgroundColor = [UIColor clearColor];
    inputView.textColor = [UIColor whiteColor];
    inputView.font = kBoldFont(20);
    inputView.userInteractionEnabled = NO;
    inputView.delegate = self;
    inputView.ignoreAboveTextRelatedPropertys = YES;
    inputView.textContainerInset = UIEdgeInsetsZero;
    inputView.textContainer.lineFragmentPadding = 0;
   [self.view addSubview:inputView];
    
    changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeBtn.frame = CGRectMake(kScreenWidth - 12 - 103, kNavBarHeight + kScreenWidth - 10 - 32, 103, 32);
    [changeBtn setTitle:[AppContext getStringForKey:@"change_status_btn" fileName:@"publish"] forState:UIControlStateNormal];
    changeBtn.layer.borderWidth = 1;
    changeBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    changeBtn.layer.cornerRadius = 16;
    changeBtn.titleLabel.font = kBoldFont(14);
    changeBtn.showsTouchWhenHighlighted = YES;
    [changeBtn addTarget:self action:@selector(changeBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeBtn];

    selectStatusBgView = [[WLSelectStatusBgView alloc] initWithFrame:CGRectMake(0, 0, 60, kScreenWidth)];
    selectStatusBgView.transform = CGAffineTransformMakeRotation(M_PI / 2 *3);
    selectStatusBgView.SelectStatusBgDelegate = self;
//    selectStatusBgView.alpha = 0.1;
//    selectStatusBgView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:selectStatusBgView];
    selectStatusBgView.center = CGPointMake(kScreenWidth/2.0, kIsiPhoneX?(kScreenHeight - 49 - 34 - 44 - 60/2.0):(kScreenHeight - 49 - 44 - 60/2.0));

    postStatusMenu = [[WLPostStatusMenu alloc] initWithFrame:CGRectMake(0, kIsiPhoneX?kScreenHeight - 49 - 44 - 34:kScreenHeight - 49 - 44, kScreenWidth, 44)];
    postStatusMenu.delegate = self;
    [self.view addSubview:postStatusMenu];
    
    postStatusBar = [[WLPostStatusBar alloc] initWithFrame:CGRectMake(0,kIsiPhoneX?kScreenHeight - 49 - 34:kScreenHeight - 49, kScreenWidth, kIsiPhoneX?49 + 34:49)];
    postStatusBar.delegate = self;
    [self.view addSubview:postStatusBar];
    
    //适配iphone 4,显示不下的问题
    if (kScreenHeight == 480)
    {
        bgView.height = 240;
           bgView.contentMode =  UIViewContentModeScaleToFill;
        statusEditTableView.height = 240;
        inputView.top = kNavBarHeight + (240 - 50)/2.0;
        inputView.height = 50;
        changeBtn.top = kNavBarHeight + 240 - 5 - 32;
        selectStatusBgView.top = selectStatusBgView.top + 6;
    }
    
    NSMutableArray *status =  [[NSUserDefaults standardUserDefaults] objectForKey:kStatusListKey];
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    if (status.count > 0)
    {
        for (NSInteger i = 0; i < [status count]; i++)
        {
            WLStatusInfo *info = [WLStatusInfo parseFromNetworkJSON:[status objectAtIndex:i]];
            if (info != nil)
            {
                [tempArray addObject:info];
            }
        }

        statusList = [NSArray arrayWithArray:tempArray];

        self->currentSection = 0;
        self->textIndex = 0;
        self->currentPicIndex = 0;
        WLStatusInfo *info = statusList[0];
    
        self->statusEditTableView.statusInfo = info;
        self->selectStatusBgView.statusInfo = info;
        self->postStatusMenu.dataArray = statusList;
        [self->postStatusBar enableSendeBtn];
        self->inputView.text = info.contentList.firstObject;

        self->emojiNum = 0;
        NSInteger charNum = self->inputView.text.length + self->emojiNum;
        [self changeFontWithCharNum:charNum];

        self->inputView.font = self->currentFont;

        CGFloat h = [self heightForTextView:self->inputView WithText:self->inputView.text];
        [self changeInputheight:h];
    }
    else
    {
        [self.manager listAllStatus:^(NSArray *status, NSInteger errCode) {
            
            self->statusList = [NSArray arrayWithArray:status];
            
            self->currentSection = 0;
            self->textIndex = 0;
            self->currentPicIndex = 0;
            WLStatusInfo *info = status[0];
            self->statusEditTableView.statusInfo = info;
            self->selectStatusBgView.statusInfo = info;
            self->postStatusMenu.dataArray = status;
            [self->postStatusBar enableSendeBtn];
            self->inputView.text = info.contentList.firstObject;
            
            self->emojiNum = 0;
            NSInteger charNum = self->inputView.text.length + self->emojiNum;
            [self changeFontWithCharNum:charNum];
            
            self->inputView.font = self->currentFont;
            
            CGFloat h = [self heightForTextView:self->inputView WithText:self->inputView.text];
            [self changeInputheight:h];
            
        }];
    }
    
    _postDraft = [[WLPostDraft alloc] init];
    _postDraft.type = WELIKE_DRAFT_TYPE_POST;
    _postDraft.draftId = [LuuUtils uuid];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [WLAuthorizationHelper requestPhotoAuthorizationWithFinished:^(BOOL granted) {
        if (granted) {
            
        }
        else
        {
            
        }
    }];
}


- (void)navigationBarLeftBtnDidClicked
{
    if (inputView.isFirstResponder)
    {
        [inputView resignFirstResponder];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)navigationBarRightBtnDidClicked
{
    if (inputView.isFirstResponder)
    {
        inputView.userInteractionEnabled = NO;
        [inputView resignFirstResponder];
         [self.navigationBar setRightBtnImageName:@"Post_status_write"];
    }
    else
    {
        [WLStatusTrack postStatusHasEdited:WLStatusTrack_buttontype_edit_text];
        
        [self.navigationBar setRightBtnImageName:@"nickname_check_ok"];
        inputView.userInteractionEnabled = YES;
        [inputView becomeFirstResponder];
    }
}

- (WLPostStatusManager *)manager {
    if (!_manager) {
        _manager = [[WLPostStatusManager alloc] init];
        
    }
    return _manager;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *allString;
    
    if (range.length > 0)
    {
        allString = [NSString stringWithString:[textView.text stringByReplacingCharactersInRange:range withString:text]];
    }
    else
    {
        allString = [NSString stringWithFormat:@"%@%@",textView.text,text];
    }
    
    isChangedText = YES;
    
    
    
    NSInteger charNum = allString.length + emojiNum;
//    NSLog(@"1======%ld",(long)charNum);
    
    if (charNum >300)
    {
        return NO;
    }
    
    if (kScreenHeight == 480)
    {
        if (inputView.text.length +   emojiNum + 2 > 160)
        {
            return NO;
        }
    }
    
    [self changeFontWithCharNum:charNum];
    
    
      textView.font = self->currentFont;
    
    CGFloat height = [self heightForTextView:textView WithText:allString];
    
    [self changeInputheight:height];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
//    NSLog(@"1======%@",textView.text);
//
//   // CGSize currentSize = [textView.text sizeWithFont:textView.font size:CGSizeMake(textView.width, kScreenWidth - 96)];
//
//    NSInteger charNum = self->inputView.text.length + emojiNum;

//    if (charNum == 0)
//    {
//        [postStatusBar disableSendBtn];
//    }
//    else
    {
        if (statusList.count > 0)
        {
             [postStatusBar enableSendeBtn];
        }
        else
        {
            [postStatusBar disableSendBtn];
        }
    }
}

- (float) heightForTextView: (UITextView *)textView WithText:(NSString *) strText{
    CGSize constraint = CGSizeMake(textView.width , kScreenWidth - 50);
    
    //iphone 4
    if (kScreenHeight == 480)
    {
        constraint = CGSizeMake(textView.width , 160);
    }
    
    
    CGRect rect = [strText boundingRectWithSize:constraint
                                        options:(NSStringDrawingUsesLineFragmentOrigin)
                                     attributes:@{NSFontAttributeName:currentFont}
                                        context:nil];
    float textHeight;
    if (rect.size.height < 40)
    {
        textHeight = 40;
    }
    else
    {
        textHeight = rect.size.height + 20;
    }
    
   // float textHeight = size.size.height + 22.0;
    return textHeight;
}

//- (float) heightForString:(NSString *)text andWidth:(float)width{
//    //获取当前文本的属性
//    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text];
//    inputView.attributedText = attrStr;
//    NSRange range = NSMakeRange(0, attrStr.length);
//    // 获取该段attributedString的属性字典
//    NSDictionary *dic = [attrStr attributesAtIndex:0 effectiveRange:&range];
//    // 计算文本的大小
//    CGSize sizeToFit = [text boundingRectWithSize:CGSizeMake(width - 16.0, MAXFLOAT) // 用于计算文本绘制时占据的矩形块
//                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading // 文本绘制时的附加选项
//                                        attributes:dic        // 文字的属性
//                                           context:nil].size; // context上下文。包括一些信息，例如如何调整字间距以及缩放。该对象包含的信息将用于文本绘制。该参数可为nil
//    return sizeToFit.height + 16.0;
//}


#pragma mark - WLPostStatusMenuDelegate
- (void)interestView:(WLPostStatusMenu *)view didSetCurrentIndex:(NSInteger)currentIndex preIndex:(NSInteger)preIndex
{
    if (statusList.count == 0)
    {
        return;
    }
    
    
    currentSection = currentIndex;
    WLStatusInfo *info = statusList[currentIndex];
    
    if (info.picUrlList.count == 0 || info.contentList.count == 0)
    {
        return;
    }
    
    self->selectStatusBgView.statusInfo = info;
    statusEditTableView.statusInfo = info;
     [statusEditTableView changeToIndex:0];
}

#pragma mark - WLSelectStatusBgViewDelegate

- (void)changeBg:(NSInteger)indexNum
{
    [WLStatusTrack postStatusHasEdited:WLStatusTrack_buttontype_change_image];
    [statusEditTableView changeToIndex:indexNum];
}

#pragma mark - Btn
- (void)changeBtnPressed
{
    inputView.textColor = [UIColor whiteColor];
    
    if (statusList.count == 0)
    {
        return;
    }
    
    
    [WLStatusTrack postStatusHasEdited:WLStatusTrack_buttontype_change_text];
    WLStatusInfo *info = statusList[currentSection];
   
    if (info.picUrlList.count == 0 || info.contentList.count == 0)
    {
        return;
    }

    
    textIndex++;
    
    if (textIndex >= info.contentList.count)
    {
        textIndex = 0;
    }
    
    NSString *str = info.contentList[textIndex];
    
    emojiNum = 0;
    NSInteger charNum = str.length;
    [self changeFontWithCharNum:charNum];
   
    
//    NSLog(@"=====%ld",(long)charNum);
    
    self->inputView.font = self->currentFont;
    self->inputView.text = str;
    
   // CGFloat h = inputView.textRender.size.height + 20;
    CGFloat h = [self heightForTextView:self->inputView WithText:str];
    [self changeInputheight:h];
    
    CGFloat hh = self->inputView.contentSize.height;
    
    CGFloat rr = (hh - h)/2.0;
    [self->inputView scrollRectToVisible:CGRectMake(0, rr, self->inputView.width, h) animated:NO];
    
   // [self->inputView insertText:@"00"];
    //[inputView deleteBackward];
}


-(void)changeFontWithCharNum:(NSInteger)num
{
    if (num <= 60)
    {
        self->currentFont = big_font;
    }
    else
    {
        if (num <= 150)
        {
            self->currentFont = middle_font;
        }
        else
        {
            self->currentFont = small_font;
        }
    }
    
    if (kScreenHeight == 480)
    {
        if (num <= 60)
        {
            self->currentFont = kBoldFont(30);
        }
        else
        {
            self->currentFont = kBoldFont(20);
        }
    }
    
    
    //更改emoji
    [self changeAllEmojiSize];
}

#pragma mark - WLPostStatusBarDelegate

-(void)emojiBtnPressed
{
    if (inputView.inputView) {
        inputView.inputView = nil;
        [inputView reloadInputViews];
        [inputView becomeFirstResponder];
        inputView.textColor = [UIColor whiteColor];
    }
    else {
        [WLStatusTrack clickEmoji];
        WLEmoticonInputView *emoticonInputView = [WLEmoticonInputView sharedView];
        emoticonInputView.delegate = self;
        inputView.inputView = emoticonInputView;
        [inputView reloadInputViews];
        [inputView becomeFirstResponder];
    }
}

-(void)photoBtnPressed
{
      [WLStatusTrack selectPic];
    WLAssetsViewController *assetsViewController = [[WLAssetsViewController alloc] initWithSelectionMode:WLAssetsSelectionMode_Single_status];
    assetsViewController.delegate = self;
    RDRootViewController *assetNav = [[RDRootViewController alloc] initWithRootViewController:assetsViewController];
    
    [self presentViewController:assetNav animated:YES completion:^{
    }];
}

-(void)downloadBtnPressed
{
    [WLStatusTrack clickDownloadPic];
    NSString *urlStr = [statusEditTableView currentPicUrl];
    
    if (urlStr.length == 0)
    {
        return;
    }
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:[NSURL URLWithString:urlStr] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image)
        {
            [WLAssetsManager saveImageToCustomAblum:image finished:^(PHAsset *asset) {
                [self showToast:[AppContext getStringForKey:@"picture_save_success" fileName:@"pic_sel"]];
            }];
        }
        else
        {
             [self showToast:[AppContext getStringForKey:@"picture_save_error" fileName:@"pic_sel"]];
        }
    }];
}

-(void)sendBtnPressed
{
    //收起键盘
    [inputView resignFirstResponder];
    
    if (statusList.count == 0)
    {
        return;
    }
    
    //键盘收起可能会有延时,考虑停顿一下再进行截图
    [self performSelector:@selector(takeSnapshotAndSend) withObject:nil afterDelay:0.5];
}

-(void)takeSnapshotAndSend
{
    [WLAuthorizationHelper requestPhotoAuthorizationWithFinished:^(BOOL granted) {
        if (granted) {
            
            //截图
            UIImage *sendImage = [self nomalSnapshotImage];
            
            //保存至相册并生成asset
            NSMutableArray *attachArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            __weak typeof(self) weakSelf = self;
            
            
            self->imageId = self->statusEditTableView.currentPicUrl;
            self->categoryID = self->statusEditTableView.statusInfo.idStr;
            self->categoryName = self->statusEditTableView.statusInfo.text;
            
            [WLAssetsManager saveImageToCustomAblum:sendImage finished:^(PHAsset *asset) {
                
                WLAttachmentDraft *attachmentDraft = [[WLAttachmentDraft alloc] initWithPHAsset:asset];
                [attachArray addObject:attachmentDraft];
                
                weakSelf.postDraft.picDraftList = attachArray;
                
                WLStatusInfo *info = self->statusList[self->currentSection];
                
                WLRichItem *richItem = [[WLRichItem alloc] init];
                richItem.type = WLRICH_TYPE_TOPIC;
                richItem.source = info.topic;
                richItem.rid = nil;
                richItem.index = 0;
                richItem.length = info.topic.length;
                richItem.target = @"";
                richItem.display = info.topic;
                richItem.title = @"";
                richItem.icon = @"";
                
                WLRichContent *richContent = [[WLRichContent alloc] init];
                richContent.richItemList = [NSArray arrayWithObjects:richItem, nil];
                richContent.text = info.topic;
                richContent.summary = info.topic;
                
                weakSelf.postDraft.content = richContent;
                [[AppContext getInstance].publishTaskManager postTask:weakSelf.postDraft];
                
                [WLStatusTrack postStatusSendPressed:self->isChangedText content:self->inputView.text imageId:self->imageId categoryID:self->categoryID categoryName:self->categoryName];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }];
        }
        else
        {
            return;
        }
    }];
}

- (UIImage *)nomalSnapshotImage
{
    changeBtn.hidden = YES;
    
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    
    CGRect rect1 =CGRectMake(0 , kNavBarHeight , kScreenWidth , kScreenHeight);
    CGRect ff;
    if (kScreenHeight == 480)
    {
        rect1 =CGRectMake(0 , kNavBarHeight , kScreenWidth , 240);
        ff =  CGRectMake(0, rect1.origin.y * screenScale + screenScale, rect1.size.width *screenScale, rect1.size.height*screenScale - screenScale);
    }
    else
    {
        ff =  CGRectMake(0, rect1.origin.y * screenScale + screenScale, rect1.size.width *screenScale, rect1.size.width*screenScale - screenScale);
    }
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *img =  [UIImage imageWithCGImage:CGImageCreateWithImageInRect([snap CGImage], ff)];//-2是为了去除边缘的白线

    changeBtn.hidden = NO;
    return img;
}


#pragma mark keyboardNotification
- (void)keyboardWasShown:(NSNotification *)notif
{
    //根据键盘高度调整控件位置
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    
    CGSize keyboardSize = [value CGRectValue].size;
    keyboardHeight = keyboardSize.height;
    //_textView.frame = CGRectMake(0, _textView.frame.origin.y, _textView.frame.size.width, kScreenHeight - kNavBarHeight - keyboardHeight - kToolbarHeight);
    //    _textViewBottomBar.top = _textView.bottom;
    if (kIsiPhoneX)
    {
        postStatusBar.top = kScreenHeight - keyboardHeight - postStatusBar.height + 34;
    }
    else
    {
         postStatusBar.top = kScreenHeight - keyboardHeight - postStatusBar.height;
    }
   
}

-(void)keyboardWillhide:(NSNotification *)notif
{
    keyboardHeight = 0;
    if (kIsiPhoneX)
    {
        postStatusBar.top = kScreenHeight - postStatusBar.height;
    }
    else
    {
        postStatusBar.top = kScreenHeight - postStatusBar.height;
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notif
{
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGSize keyboardSize = [value CGRectValue].size;
    keyboardHeight = keyboardSize.height;
}

- (void)endEdit
{
    [WLStatusTrack postStatusHasEdited:WLStatusTrack_buttontype_change_image];
    inputView.userInteractionEnabled = NO;
    
    [inputView resignFirstResponder];
    [self.navigationBar setRightBtnImageName:@"Post_status_write"];
}


#pragma mark WLAssetsViewControllerDelegate
- (void)assetsViewCtr:(WLAssetsViewController *)viewCtr didSelectedWithAssetArray:(NSArray<WLAssetModel *> *)assetArray
{
    if (assetArray.count == 0)
    {
        return;
    }

    WLAssetModel *assetModel = assetArray.firstObject;
    currentAsset = assetModel.asset;
    if (assetModel.type == WLAssetModelType_Photo)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //读出图片,然后显示
            [WLImageHelper imageFromAsset:assetModel.asset size:CGSizeMake(kScreenWidth, kScreenWidth) result:^(UIImage *image) {
                [self->statusEditTableView changeCustomImage:image];
            }];
        });
    }
}

-(void)changeInputheight:(CGFloat)height
{
//    NSLog(@"3======%f",height);
//      NSLog(@"2-------%f",inputView.contentSize.height);
    if (height > inputView.contentSize.height)
    {
        inputView.top = kNavBarHeight + (kScreenWidth - height)/2.0;
        inputView.height = height;
    }
    else
    {
        inputView.top = kNavBarHeight + (kScreenWidth - inputView.contentSize.height)/2.0;
        inputView.height = inputView.contentSize.height;
    }
    
    //适配iphone 4
    if (kScreenHeight == 480)
    {
        inputView.top = kNavBarHeight + (240 - inputView.height)/2.0;
    }
}

- (void)emoticonInputDidTapText:(NSString *)text
{
    if (inputView.text.length +   emojiNum + 2 > 300)
    {
        return;
    }
 
    isChangedText = YES;
    
    if (kScreenHeight == 480)
    {
        if (inputView.text.length +   emojiNum + 2 > 160)
        {
            return;
        }
    }
    
    TYTextAttachment *attachMent = [[TYTextAttachment alloc]init];
    attachMent.size = CGSizeMake(currentFont.pointSize, currentFont.pointSize);
    attachMent.image = [AppContext getImageForKey:text];
    attachMent.verticalAlignment = TYAttachmentAlignmentCenter;
    NSAttributedString *attString = [NSAttributedString attributedStringWithAttachment:attachMent];
    [inputView insertAttributedText:attString];
   
      emojiNum++;
    
    NSInteger charNum = inputView.text.length +   emojiNum;
//    NSLog(@"1======%ld",(long)charNum);
    

    [self changeFontWithCharNum:charNum];
    
    
    inputView.font = self->currentFont;
    inputView.textColor = [UIColor whiteColor];
    
    
    CGFloat height = [self heightForTextView:inputView WithText:inputView.text];
    
    [self changeInputheight:height];
    
}

- (void)emoticonInputDidTapBackspace
{
    //拿到光标位置
    NSRange range = [inputView selectedRange];
    if (inputView.attributedText.length == 0)
    {
        return;
    }
    
    NSAttributedString *attString =  [inputView.attributedText  attributedSubstringFromRange:NSMakeRange(range.location - 1, 1)];

    NSDictionary *dic = [attString attributesAtIndex:0 effectiveRange:nil];

    if ([dic.allKeys containsObject:@"NSAttachment"])
    {
        emojiNum--;
    }

  [inputView deleteBackward];
   // NSLog(@"=======%@",attString);
}

//对所有的表情进行大小更新
-(void)changeAllEmojiSize
{
    NSMutableAttributedString *newStr = [[NSMutableAttributedString alloc] initWithAttributedString:inputView.attributedText];
    
    for (int i = 0; i < newStr.length; i++)
    {
        NSRange range = NSMakeRange(newStr.length - 1 - i, 1);
        NSAttributedString *attString =  [newStr  attributedSubstringFromRange:range];
        
        NSDictionary *dic = [attString attributesAtIndex:0 effectiveRange:nil];
        
        if ([dic.allKeys containsObject:@"NSAttachment"])
        {
            TYTextAttachment *attachMent = [dic objectForKey:@"NSAttachment"];
            attachMent.size = CGSizeMake(currentFont.pointSize, currentFont.pointSize);
            NSAttributedString *attString = [NSAttributedString attributedStringWithAttachment:attachMent];
            [newStr replaceCharactersInRange:range withAttributedString:attString];
        }
    }
    
    inputView.attributedText = newStr;
}


@end

