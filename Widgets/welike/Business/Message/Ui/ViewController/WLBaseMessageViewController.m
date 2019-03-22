//
//  WLBaseMessageViewController.m
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBaseMessageViewController.h"
#import "WLMessageManager.h"
#import "WLInputKeyboard.h"
#import "WLMessageGroup.h"
#import "WLAccountManager.h"
#import "WLAssetsViewController.h"
#import "WLImageHelper.h"
#import "WLImageBrowseView.h"
#import "WLPicInfo.h"
#import "WLUserDetailViewController.h"
#import "WLAlertController.h"
#import "WLSingleUserManager.h"
#import "WLWebViewController.h"
#import "WLTrackerBlock.h"
#import "WLHeadView.h"

@interface WLBaseMessageViewController () <WLMessageManagerReceivedDelegate, WLMessageManagerSendDelegate, WLInputKeyboardDelegate, WLAssetsViewControllerDelegate, WLMessageTableViewCellDelegate,WLHeadViewDelegate>

@property (nonatomic, strong) WLInputKeyboard *keyboard;
@property (nonatomic, strong) WLIMSession *currentSession;
@property (nonatomic, strong) WLUser *currentUser;
@property (nonatomic, strong) WLIMMessage *currentMessage;
@property (nonatomic, strong) NSArray<WLMessageGroup *> *messageGroupList;
@property (nonatomic, strong) WLMessageGroup *rootMessageGroup;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL scrollBottom;
@property (nonatomic, copy) NSString *headStr;
@property (nonatomic, copy) NSString *userIdStr;


@end

@implementation WLBaseMessageViewController

- (void)initInputKeyboard
{
    self.keyboard = [WLInputKeyboard keyBoard];
    self.keyboard.delegate = self;
    self.keyboard.placeHolder = [AppContext getStringForKey:@"chat_edit_text_hint" fileName:@"im"];
    self.keyboard.associateTableView = self.tableView;
    [self.view addSubview:self.keyboard];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.rootMessageGroup = [[WLMessageGroup alloc] init];
        [[WLMessageManager instance] registerDelegate:self];
    }
    return self;
}

- (instancetype)initWithChat:(WLIMSession *)session
{
    self = [self init];
    if (self) {
        self.currentSession = session;
        _headStr = session.head;
        _userIdStr = session.remoteUid;
    }
    return self;
}

- (instancetype)initWithUser:(WLUser *)user
{
    self = [self init];
    if (self) {
        self.currentUser = user;
        _headStr = user.headUrl;
        _userIdStr = user.uid;
    }
    return self;
}

- (UITableViewStyle)tableViewStyle
{
    return UITableViewStyleGrouped;
}

- (void)initTableView
{
    _tableView = [[WLBasicTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //    _tableView.emptyDelegate = self;
    //    _tableView.emptyDataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = kLightBackgroundViewColor;
    [self.view addSubview:_tableView];
    [self initLoadMore];
}

- (void)initLoadMore
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(pullDownAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)pullDownAction:(UIRefreshControl *)control
{
    [self loadMoreData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    
    if (self.currentSession != nil)
    {
        __weak typeof(self) weakSelf = self;
        [[WLMessageManager instance] goInSingleSessionWithSid:self.currentSession.sessionId sendDelegate:self completed:^(WLIMSession *session) {
            weakSelf.currentSession = session;
            [weakSelf doViewDidLoad];
        }];
    }
    else if (self.currentUser != nil)
    {
        __weak typeof(self) weakSelf = self;
        [[WLMessageManager instance] goInSingleSessionWithUser:self.currentUser sendDelegate:self completed:^(WLIMSession *session) {
            weakSelf.currentSession = session;
            [weakSelf doViewDidLoad];
        }];
    }

//    [self addTarget:self refreshAction:@selector(refreshData) moreAction:@selector(loadMoreData)];
//    [self beginRefresh];
}

- (void)doViewDidLoad
{
    NSString *title = self.currentSession.nickName;
    if (title.length == 0) {
        title = self.currentSession.sessionId;
    }
    self.navigationBar.title = title;
    self.navigationBar.rightBtn.hidden = NO;
    [self.navigationBar.rightBtn setImage:[AppContext getImageForKey:@"common_more"] forState:UIControlStateNormal];
    
    
    WLHeadView *navAvatarView = [[WLHeadView alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(self.navigationBar.titleView.bounds) - 32) * 0.5, 32, 32)];
    [navAvatarView fq_setImageWithURLString:self.headStr
                                          placeholder:[AppContext getImageForKey:@"head_default"]
                                         cornerRadius:16
                                            completed:nil];
    

    navAvatarView.delegate = self;
    [self.navigationBar.titleView addSubview:navAvatarView];
    
     self.navigationBar.titleLabel.left = navAvatarView.right + 5;
    
    if (self.currentSession.visableChat == NO)
    {
        self.tableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kSafeAreaHeight - kNavBarHeight);
    }
    else
    {
        self.tableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kSafeAreaHeight - kNavBarHeight - kInputToolBarHeight);
        [self initInputKeyboard];
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), kMessageTableBottomPading)];
    
    [self refreshData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    [super scrollViewWillBeginDragging:scrollView];
    [self.keyboard keyboardDown];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [[WLMessageManager instance] exitSingleSession:self.currentSession];
    [[WLMessageManager instance] unregister:self];
}

#pragma mark - WLNavigationBarDelegate
- (void)navigationBarRightBtnDidClicked {
    WLAlertController *alert = [WLAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (self.currentSession.sessionType == WLIMSessionTypeP2P)
    {
        NSString *blockAction = [NSString stringWithFormat:@"%@@%@", [AppContext getStringForKey:@"block" fileName:@"common"], self.currentSession.nickName];
        [alert addAction:[UIAlertAction actionWithTitle:blockAction
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [[AppContext getInstance].singleUserManager blockUserWithUid:self.currentSession.remoteUid];
                                                    [WLTrackerBlock appendTrackerWithBlockType:WLTrackerBlockType_Block userID:self.currentSession.remoteUid source:WLTrackerFeedSource_IM_Message];
                                                    [self showToast:[AppContext getStringForKey:@"block_success" fileName:@"user"]];
                                                }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"common_cancel" fileName:@"common"]
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                            }]];
    [[AppContext rootViewController] presentViewController:alert animated:YES completion:nil];
}

#pragma mark - private

- (void)reloadTableView
{
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    self.scrollBottom = YES;
    [self.tableView setContentOffset:CGPointMake(0, MAX(self.tableView.contentSize.height-CGRectGetHeight(self.tableView.frame),0)) animated:NO];
}

- (void)refreshData
{
    __weak typeof(self) weakSelf = self;
    [[WLMessageManager instance] refreshMessagesAndCompleted:^(NSArray<WLIMMessage *> *messages, NSString *sid) {
        if ([weakSelf.currentSession.sessionId isEqualToString:sid]) {
//            self.messageGroupList = [WLMessageGroup groupsWithMessages:messages];
            [weakSelf.rootMessageGroup  appendMessages:messages];
            weakSelf.messageGroupList = [weakSelf.rootMessageGroup allMessageGroups];
            [weakSelf reloadTableView];
        }
    }];
}

- (void)loadMoreData
{
    __weak typeof(self) weakSelf = self;
    [[WLMessageManager instance] hisMessagesAndCompleted:^(NSArray<WLIMMessage *> *messages, NSString *sid) {
        if ([weakSelf.currentSession.sessionId isEqualToString:sid]) {
//            self.messageGroupList = [WLMessageGroup groups:self.messageGroupList mergeMessages:messages];
            [weakSelf.rootMessageGroup  appendMessages:messages];
            weakSelf.messageGroupList = [weakSelf.rootMessageGroup allMessageGroups];
            [weakSelf.tableView reloadData];
            [weakSelf.refreshControl endRefreshing];
            if (messages.count==0) {
                [weakSelf.refreshControl removeFromSuperview];
                weakSelf.refreshControl = nil;
            }
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.messageGroupList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < self.messageGroupList.count) {
        WLMessageGroup *group = self.messageGroupList[section];
        return [group messagesCount];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLMessageTableViewCell *cell = nil;
    NSUInteger section = indexPath.section;
    if (section < self.messageGroupList.count) {
        WLMessageGroup *group = self.messageGroupList[section];
        NSUInteger row = indexPath.row;
        if (row < [group messagesCount]) {
            WLIMMessage *message = [group messageAtIndex:row];
            cell = [[message class] messageCellInTableView:tableView];
            [cell bindMessage:message];
            cell.delegate = self;
        }
//        if (self.scrollBottom && section == self.messageGroupList.count-1 && row == [group messagesCount]-1) {
//            self.scrollBottom = NO;
//            [self.tableView setContentOffset:CGPointMake(0, MAX(self.tableView.contentSize.height-CGRectGetHeight(self.tableView.frame),0)) animated:NO];
//        }
    }
    if (cell == nil) {
        cell = [WLMessageTableViewCell reusableCellOfTableView:tableView];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WLMessageSectionHeaderView *headView = [[WLMessageSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(tableView.frame), kMessageSectionHeadHeight)];
    if (section < self.messageGroupList.count) {
        WLMessageGroup *group = self.messageGroupList[section];
        [headView setSetionTimeStamp:group.startTime];
    }
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kMessageSectionHeadHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    NSUInteger section = indexPath.section;
    if (section < self.messageGroupList.count) {
        WLMessageGroup *group = self.messageGroupList[section];
        NSUInteger row = indexPath.row;
        if (row < [group messagesCount]) {
            WLIMMessage *message = [group messageAtIndex:row];
            height = [message messageCellHeightInTableView:tableView];
        }
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - WLMessageManagerReceivedDelegate

- (void)onIMReceivedMessages:(NSArray<WLIMMessage*> *)messages sid:(NSString *)sid
{
    if ([self.currentSession.sessionId isEqualToString:sid]) {
//        self.messageGroupList = [WLMessageGroup groups:self.messageGroupList mergeMessages:messages];
        [self.rootMessageGroup  appendMessages:messages];
        self.messageGroupList = [self.rootMessageGroup allMessageGroups];
        [self reloadTableView];
    }
}

- (void)onUserChanged:(WLUser *)user
{
    [self.rootMessageGroup refreshUser:user];
    [self reloadTableView];
}

#pragma mark - WLMessageManagerSendDelegate

- (void)onIMOneSendResult:(WLIMMessage *)message errCode:(NSInteger)errCode
{
//    NSIndexPath *indexPath = nil;
//    NSInteger secion = self.messageGroupList.count-1;
//    for (NSInteger i = secion; i >= 0; i--) {
//        WLMessageGroup *group = self.messageGroupList[i];
//        NSUInteger row = [group indexOfMessage:message];
//        if (row != NSNotFound) {
//            WLIMMessage *msg = [group messageAtIndex:row];
//            if (errCode != ERROR_SUCCESS) {
//                msg.status = WLIMMessageStatusSendFailed;
//            } else {
//                msg.status = WLIMMessageStatusReceived;
//            }
//            msg.time = message.time;
//            indexPath = [NSIndexPath indexPathForRow:row inSection:secion];
//            break;
//        }
//    }
//    if (indexPath != nil) {
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    }
    if (errCode != ERROR_SUCCESS) {
        message.status = WLIMMessageStatusSendFailed;
    } else {
        message.status = WLIMMessageStatusReceived;
    }
    [self.rootMessageGroup refreshMessage:message];
    [self reloadTableView];
}

- (void)onIAllMSendMessagesError:(NSInteger)errCode
{
    [[WLMessageManager instance] cancelAllSendingMessages];
    [self.rootMessageGroup refreshAllSendingMessages];
    [self reloadTableView];
}

- (void)onIMSendProcess:(NSString *)mid process:(CGFloat)process
{
    
}

#pragma mark - UIScrollViewEmptyDelegate

- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView
{
//    [self beginRefresh];
}

#pragma mark - WLInputKeyboardDelegate

- (void)inputKeyBoardSendText:(NSString *)text
{
    [self sendTextMessage:text inChat:self.currentSession];
    [self reloadTableView];
}

- (void)inputKeyBoardPressedPicButton
{
    WLAssetsViewController *assetsViewController = [[WLAssetsViewController alloc] initWithSelectionMode:WLAssetsSelectionMode_Single];
    assetsViewController.editable = NO;
    assetsViewController.delegate = self;
    RDRootViewController *assetNav = [[RDRootViewController alloc] initWithRootViewController:assetsViewController];
    [self presentViewController:assetNav animated:YES completion:^{
    }];
}

#pragma mark -

- (void)sendTextMessage:(NSString *)text inChat:(WLIMSession *)session
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    WLIMTextMessage *message = [[WLIMTextMessage alloc] init];
    message.messageId = [LuuUtils uuid];
    message.text = text;
    message.sessionId = session.sessionId;
    message.status = WLIMMessageStatusSending;
    message.senderHead = account.headUrl;
    message.senderNickName = account.nickName;
    message.senderUid = account.uid;
    message.time = [[NSDate date] timeIntervalSince1970] * 1000;
    [[WLMessageManager instance] sendMessage:message];
    [self.rootMessageGroup appendLastMessage:message];
    self.messageGroupList = [self.rootMessageGroup allMessageGroups];
}

#pragma mark - WLAssetsViewControllerDelegate

- (void)assetsViewCtr:(WLAssetsViewController *)viewCtr didSelectedWithAssetArray:(NSArray<WLAssetModel *> *)assetArray
{
    if (assetArray.count == 0)
    {
        return;
    }
    WLAssetModel *assetModel = assetArray.firstObject;
    if (assetModel.asset.mediaType == PHAssetMediaTypeImage)
    {
        NSString *localIdentifier = [assetModel.asset.localIdentifier copy];
        NSString *name = nil;
        if ([[assetModel.asset valueForKey:@"filename"] hasSuffix:@"GIF"])
        {
            name = [NSString stringWithFormat:@"%@.gif", [LuuUtils md5Encode:localIdentifier]];
        }
        else
        {
            name = [NSString stringWithFormat:@"%@.jpg", [LuuUtils md5Encode:localIdentifier]];
        }
        NSString *fileName = [[AppContext getCachePath] stringByAppendingPathComponent:name];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [WLImageHelper imageCompressAndLocalSave:assetModel.asset withSavePath:fileName result:^(BOOL result,CGSize size,CGFloat dataLength) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (result) {
                        [self sendPicMessage:fileName inChat:self.currentSession];
                        [self reloadTableView];
                    }
                });
            }];
//        });
    }
}

- (void)assetsViewCtr:(WLAssetsViewController *)viewCtr didCuttedImage:(UIImage *)image
{
    
}

#pragma mark -

- (void)sendPicMessage:(NSString *)localPath inChat:(WLIMSession *)session
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    WLIMPicMessage *message = [[WLIMPicMessage alloc] init];
    message.messageId = [LuuUtils uuid];
    message.localFileName = localPath;
    message.sessionId = session.sessionId;
    message.status = WLIMMessageStatusSending;
    message.senderHead = account.headUrl;
    message.senderNickName = account.nickName;
    message.senderUid = account.uid;
    message.time = [[NSDate date] timeIntervalSince1970] * 1000;
    [[WLMessageManager instance] sendMessage:message];
    [self.rootMessageGroup appendLastMessage:message];
    self.messageGroupList = [self.rootMessageGroup allMessageGroups];
}

#pragma mark - WLMessageTableViewCellDelegate

- (void)message:(WLIMMessage *)message avatarViewPressed:(WLHeadView *)avatarView
{
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:message.senderUid];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

- (void)message:(WLIMMessage *)message avatarViewLongPressed:(UILongPressGestureRecognizer *)longPress
{
    
}

- (void)messageCell:(WLMessageTableViewCell *)cell longPressed:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        self.currentMessage = cell.message;
        if (![self becomeFirstResponder]) {
            return;
        }
        NSMutableArray *menuItems = [NSMutableArray arrayWithCapacity:5];
        switch (cell.message.type)
        {
            case WLIMMessageTypeTxt:
            {
                NSString *copyStr = [AppContext getStringForKey:@"copy" fileName:@"feed"];
                UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:copyStr  action:@selector(copyTextMessage:)];
                [menuItems addObject:copyItem];
            }
                break;
            case WLIMMessageTypePic:
            {
                NSString *saveStr = [AppContext getStringForKey:@"picture_prompt" fileName:@"pic_sel"];
                UIMenuItem *saveItem = [[UIMenuItem alloc] initWithTitle:saveStr action:@selector(savePicMessage:)];
                [menuItems addObject:saveItem];
            }
                break;
            default:
                break;
        }
        if (menuItems.count > 0) {
            UIMenuController *controller = [UIMenuController sharedMenuController];
            [controller setMenuVisible:YES];
            [controller setMenuItems:menuItems];
            CGRect rect = [cell.bubbleImageView convertRect:cell.bubbleImageView.bounds toView:self.tableView];
            [controller setTargetRect:rect inView:self.tableView];
            [controller setMenuVisible:YES animated:YES];
        }
    }
}

- (void)message:(WLIMMessage *)message didTouchBubbleImageView:(WLMessageTableViewCell *)cell
{
    if (message.type == WLIMMessageTypePic) {
        WLIMPicMessage *picMessage = (WLIMPicMessage *)message;
        WLPicInfo *picInfo = [[WLPicInfo alloc] init];
        if ([picMessage.picUri length] > 0) {
            picInfo.picUrl = picMessage.picUri;
        } else if (picMessage.localFileName.length > 0) {
            picInfo.picUrl = picMessage.localFileName;
        }
        [self.keyboard keyboardDown];
        FQImageBrowseItemModel *model = [[FQImageBrowseItemModel alloc] init];
        model.imageInfo = picInfo;
        model.thumbView = cell.bubbleImageView;
        model.userName = picMessage.senderNickName;
        UIView *rootView = ([UIApplication sharedApplication].keyWindow.rootViewController).view;
        WLImageBrowseView *groupView = [[WLImageBrowseView alloc] initWithItemArray:@[model]];
        groupView.useCache = NO;
        [groupView displayWithFromView:cell.bubbleImageView toView:rootView];
    }
}

- (void)message:(WLIMMessage *)message didTouchStateView:(WLMessageTableViewCell *)cell
{
    [self resendMessage:message];
    [self reloadTableView];
}

- (void)message:(WLIMMessage *)message didTouchLinkUrl:(NSString *)linkUrl
{
    WLWebViewController *vc = [[WLWebViewController alloc] initWithUrl:linkUrl];
    [[AppContext rootViewController] pushViewController:vc animated:YES];
//    NSURL *url = [NSURL URLWithString:linkUrl];
//    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark -

- (void)resendMessage:(WLIMMessage *)message
{
    message.time = [[NSDate date] timeIntervalSince1970] * 1000;
    message.status = WLIMMessageStatusSending;
    [[WLMessageManager instance] sendMessage:message];
    [self.rootMessageGroup appendLastMessage:message];
    self.messageGroupList = [self.rootMessageGroup allMessageGroups];
}


- (void)copyTextMessage:(id)sender
{
    if (self.currentMessage.type == WLIMMessageTypeTxt) {
        WLIMTextMessage *message = (WLIMTextMessage *)self.currentMessage;
        [[UIPasteboard generalPasteboard] setString:message.text];
    }
}

- (void)savePicMessage:(id)sender
{
    if (self.currentMessage.type == WLIMMessageTypePic) {
        WLIMPicMessage *messasge = (WLIMPicMessage *)self.currentMessage;
        UIImage *image = [messasge.userInfo objectForKey:MessageImageCacheKey];
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        if (image != nil && authStatus == PHAuthorizationStatusAuthorized) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        } else {
            [self image:image didFinishSavingWithError:[NSError errorWithDomain:@"authStatus" code:authStatus userInfo:nil] contextInfo:nil];
        }
    }
}

// 保存完毕回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error == NULL) {
        NSString *successStr = [AppContext getStringForKey:@"picture_save_success" fileName:@"pic_sel"];;
        [self showToast:successStr];
    } else {
        NSString *failureStr = [AppContext getStringForKey:@"picture_save_error" fileName:@"pic_sel"];
        [self showToast:failureStr];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if ([self isFirstResponder] && (action == @selector(copyTextMessage:) || action == @selector(savePicMessage:))) {
        return YES;
    } else {
        return NO;
    }
}

- (void)onClick:(WLHeadView *)headView
{
//    NSLog(@"123131");
    
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:_userIdStr];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

@end
