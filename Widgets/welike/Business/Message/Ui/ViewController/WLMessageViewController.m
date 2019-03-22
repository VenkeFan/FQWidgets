//
//  WLMessageViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLMessageViewController.h"
#import "WLMessageBox.h"
#import "WLChatStrangerCell.h"
#import "WLChatTableViewCell.h"
#import "WLSessionGroup.h"
#import "WLMessageManager.h"
#import "WLAccountManager.h"
#import "WLMessageCountObserver.h"
#import "WLMsgBoxViewController.h"
#import "WLPrivateMessageViewController.h"
#import "WLChatListViewController.h"
#import "WLIMCommon.h"
#import "WLChatBoxCell.h"
#import "WLUnreadView.h"

#define kMessageBoxHeight                 93.f

@interface WLMessageViewController () <UITableViewDelegate, UITableViewDataSource, WLMessageManagerReceivedDelegate, WLMessageCountObserverDelegate>

@property (nonatomic, strong) WLUnreadView *mentionUnread;
@property (nonatomic, strong) WLUnreadView *commentUnread;
@property (nonatomic, strong) WLUnreadView *likeUnread;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<WLIMSession *> *sessionList;
@property (nonatomic, strong) WLSessionGroup *sessionGroup;

@end

@implementation WLMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.sessionGroup = [[WLSessionGroup alloc] initWithGreet:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[WLMessageManager instance] registerDelegate:self];
    [[AppContext getInstance].messageCountObserver registerDelegate:self];
    
     self.mentionUnread = [[WLUnreadView alloc] initWithFrame:CGRectMake(kScreenWidth - kChatBoxCellBadgeRightMargin - kChatBoxCellBadgeSize, (kChatCellHeight - kChatBoxCellBadgeSize) / 2.f, kChatBoxCellBadgeSize, kChatBoxCellBadgeSize)];
    self.commentUnread = [[WLUnreadView alloc] initWithFrame:CGRectMake(kScreenWidth - kChatBoxCellBadgeRightMargin - kChatBoxCellBadgeSize, (kChatCellHeight - kChatBoxCellBadgeSize) / 2.f, kChatBoxCellBadgeSize, kChatBoxCellBadgeSize)];
    self.likeUnread = [[WLUnreadView alloc] initWithFrame:CGRectMake(kScreenWidth - kChatBoxCellBadgeRightMargin - kChatBoxCellBadgeSize, (kChatCellHeight - kChatBoxCellBadgeSize) / 2.f, kChatBoxCellBadgeSize, kChatBoxCellBadgeSize)];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, self.view.width, self.view.height-kNavBarHeight - kTabBarHeight) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsSelectionDuringEditing = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self.view addSubview:self.tableView];
    
    [[AppContext getInstance].messageCountObserver refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    [[WLMessageManager instance] listAllSessionsWithGreet:NO completed:^(NSArray<WLIMSession *> *sessions, BOOL greet) {
        [weakSelf.sessionGroup resetSessions:sessions];
        weakSelf.sessionList = [weakSelf allSessionList];
        [weakSelf.tableView reloadData];
    }];
}

- (void)dealloc
{
    [[WLMessageManager instance] unregister:self];
    [[AppContext getInstance].messageCountObserver unregister:self];
}

#pragma mark - allSessionList

- (NSMutableArray *)allSessionList
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:3];
    for (NSInteger i = 0; i < 3; i++) {
        WLIMSession *session = [[WLIMSession alloc] init];
        switch (i) {
            case 0:
            {
                session.sessionId = MENTION_SESSION_SID;
            }
                break;
            case 1:
            {
                session.sessionId = COMMENT_SESSION_SID;
            }
                break;
            case 2:
            {
                session.sessionId = LIKE_SESSION_SID;
            }
                break;
                
            default:
                break;
        }
        [list addObject:session];
    }
    [list addObjectsFromArray:self.sessionGroup.allSessions];
    return list;
}

#pragma mark - WLMessageCountObserverDelegate
- (void)messagesCountChanged:(BOOL)has
{
    WLAccountSetting *setting = [[AppContext getInstance].accountManager mySetting];
    self.mentionUnread.unreadCount = setting.mentionCount;
    self.commentUnread.unreadCount = setting.commentCount;
    self.likeUnread.unreadCount = setting.likeCount;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sessionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    WLIMSession *session = nil;
    
    NSInteger row = indexPath.row;
    if ([self.sessionList count] > row)
    {
        session = [self.sessionList objectAtIndex:row];
    }
    if (session != nil)
    {
//        BOOL last = (row == ([self.sessionList count] - 1)) ? YES : NO;
        if ([session.sessionId isEqualToString:STRANGER_SESSION_SID] == YES)
        {
            WLChatStrangerCell *strangerCell = nil;
            strangerCell = [tableView dequeueReusableCellWithIdentifier:WLChatStrangerCellIdentifier];
            if (strangerCell == nil)
            {
                strangerCell = [[WLChatStrangerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLChatStrangerCellIdentifier];
            }
            strangerCell.isTail = YES;
            strangerCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [strangerCell bindChat:session];
            cell = strangerCell;
        } else if ([session.sessionId isEqualToString:MENTION_SESSION_SID] || [session.sessionId isEqualToString:COMMENT_SESSION_SID] || [session.sessionId isEqualToString:LIKE_SESSION_SID]) {
            WLChatBoxCell *sessionCell = nil;
            sessionCell = [tableView dequeueReusableCellWithIdentifier:WLChatBoxCellIdentifier];
            if (sessionCell == nil)
            {
                sessionCell = [[WLChatBoxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLChatBoxCellIdentifier];
            }
            sessionCell.isTail = YES;
            sessionCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [sessionCell bindChat:session];
            if ([session.sessionId isEqualToString:MENTION_SESSION_SID]) {
                [sessionCell.contentView addSubview:self.mentionUnread];
            } else if ([session.sessionId isEqualToString:COMMENT_SESSION_SID]) {
                [sessionCell.contentView addSubview:self.commentUnread];
            } else if ([session.sessionId isEqualToString:LIKE_SESSION_SID]) {
                [sessionCell.contentView addSubview:self.likeUnread];
            }
            cell = sessionCell;
        }
        else
        {
            WLChatTableViewCell *sessionCell = nil;
            sessionCell = [tableView dequeueReusableCellWithIdentifier:WLChatTableViewCellIdentifier];
            if (sessionCell == nil)
            {
                sessionCell = [[WLChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLChatTableViewCellIdentifier];
            }
            sessionCell.isTail = YES;
            [sessionCell bindChat:session];
            cell = sessionCell;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kChatCellHeight;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLIMSession *session = nil;
    NSInteger row = indexPath.row;
    if ([self.sessionList count] > row)
    {
        session = [self.sessionList objectAtIndex:row];
    }
    if ([session.sessionId isEqualToString:STRANGER_SESSION_SID] || [session.sessionId isEqualToString:MENTION_SESSION_SID] || [session.sessionId isEqualToString:COMMENT_SESSION_SID] || [session.sessionId isEqualToString:LIKE_SESSION_SID])
    {
        return UITableViewCellEditingStyleNone;
    }
    else
    {
        return UITableViewCellEditingStyleDelete;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        WLIMSession *session = nil;
        NSInteger row = indexPath.row;
        if ([self.sessionList count] > row)
        {
            session = [self.sessionList objectAtIndex:row];
        }
        [self.sessionGroup removeSession:session];
        [self.sessionList removeObjectAtIndex:row];
        [[WLMessageManager instance] removeSession:session];
        if (@available(iOS 11.0, *))
        {
            [tableView performBatchUpdates:^{
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            } completion:nil];
        }
        else
        {
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [tableView endUpdates];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLIMSession *session = nil;
    
    NSInteger row = indexPath.row;
    if ([self.sessionList count] > row)
    {
        session = [self.sessionList objectAtIndex:row];
    }
    if (session != nil)
    {
        if ([session.sessionId isEqualToString:STRANGER_SESSION_SID] == YES)
        {
            WLChatListViewController *vc = [[WLChatListViewController alloc] init];
            [[AppContext rootViewController] pushViewController:vc animated:YES];
        } else if ([session.sessionId isEqualToString:MENTION_SESSION_SID]) {
            self.mentionUnread.unreadCount = 0;
            WLAccountSetting *setting = [[AppContext getInstance].accountManager mySetting];
            setting.mentionCount = 0;
            [[AppContext getInstance].accountManager updateSetting:setting];
            [[AppContext getInstance].messageCountObserver loadFromLocal];
            WLMsgBoxViewController *vc = [[WLMsgBoxViewController alloc] init];
            vc.type = WELIKE_MSG_BOX_TYPE_MENTION;
            [[AppContext rootViewController] pushViewController:vc animated:YES];
        } else if ([session.sessionId isEqualToString:COMMENT_SESSION_SID]) {
            self.commentUnread.unreadCount = 0;
            WLAccountSetting *setting = [[AppContext getInstance].accountManager mySetting];
            setting.commentCount = 0;
            [[AppContext getInstance].accountManager updateSetting:setting];
            [[AppContext getInstance].messageCountObserver loadFromLocal];
            WLMsgBoxViewController *vc = [[WLMsgBoxViewController alloc] init];
            vc.type = WELIKE_MSG_BOX_TYPE_COMMENT;
            [[AppContext rootViewController] pushViewController:vc animated:YES];
        } else if ([session.sessionId isEqualToString:LIKE_SESSION_SID]) {
            self.likeUnread.unreadCount = 0;
            WLAccountSetting *setting = [[AppContext getInstance].accountManager mySetting];
            setting.likeCount = 0;
            [[AppContext getInstance].accountManager updateSetting:setting];
            [[AppContext getInstance].messageCountObserver loadFromLocal];
            WLMsgBoxViewController *vc = [[WLMsgBoxViewController alloc] init];
            vc.type = WELIKE_MSG_BOX_TYPE_LIKE;
            [[AppContext rootViewController] pushViewController:vc animated:YES];
        } else {
            session.unreadCount = 0;
            WLPrivateMessageViewController *contrloller = [[WLPrivateMessageViewController alloc] initWithChat:session];
//            contrloller
            [[AppContext rootViewController] pushViewController:contrloller animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - WLMessageManagerReceivedDelegate
- (void)onIMSessionsUpdated:(NSArray<WLIMSession*> *)sessions
{
    for (int i = 0; i < sessions.count; i++)
    {
        WLIMSession *newSessions = sessions[i];

        for (WLIMSession *s in self.sessionGroup.allSessions)
        {
            if ([s.sessionId isEqual:newSessions.sessionId])
            {
                [self.sessionGroup removeSession:s];
                break;
            }
        }
    }
    
    
    [self.sessionGroup appendSessions:sessions];
    self.sessionList = [self allSessionList];
    [self.tableView reloadData];
}

@end
