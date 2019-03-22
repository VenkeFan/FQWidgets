//
//  WLChatListViewController.m
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLChatListViewController.h"
#import "WLChatStrangerCell.h"
#import "WLChatTableViewCell.h"
#import "WLMessageManager.h"
#import "WLSessionGroup.h"
#import "WLPrivateMessageViewController.h"

@interface WLChatListViewController () <WLMessageManagerReceivedDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<WLIMSession *> *sessionList;
@property (nonatomic, strong) WLSessionGroup *sessionGroup;

@end

@implementation WLChatListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.sessionGroup = [[WLSessionGroup alloc] initWithGreet:YES];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.navigationBar.title = [AppContext getStringForKey:@"stranger" fileName:@"common"];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight - kSafeAreaBottomY) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsSelectionDuringEditing = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[WLMessageManager instance] registerDelegate:self];
    
    __weak typeof(self) weakSelf = self;
    [[WLMessageManager instance] listAllSessionsWithGreet:YES completed:^(NSArray<WLIMSession *> *sessions, BOOL greet) {
        [weakSelf.sessionGroup resetSessions:sessions];
        weakSelf.sessionList = [NSMutableArray arrayWithArray:weakSelf.sessionGroup.allSessions];
        [weakSelf.tableView reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[WLMessageManager instance] unregister:self];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sessionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLChatTableViewCell *cell = nil;
    WLIMSession *session = nil;
    
    NSInteger row = indexPath.row;
    if ([self.sessionList count] > row)
    {
        session = [self.sessionList objectAtIndex:row];
    }
    if (session != nil)
    {
        BOOL last = (row == ([self.sessionList count] - 1)) ? YES : NO;
        cell = [tableView dequeueReusableCellWithIdentifier:WLChatTableViewCellIdentifier];
        if (cell == nil)
        {
            cell = [[WLChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLChatTableViewCellIdentifier];
            if (last == YES)
            {
                cell.isTail = NO;
            }
            else
            {
                cell.isTail = YES;
            }
            [cell bindChat:session];
        }
        else
        {
            if (last == YES)
            {
                cell.isTail = NO;
            }
            else
            {
                cell.isTail = YES;
            }
            [cell bindChat:session];
        }
    }
    
    return cell;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kChatCellHeight;
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
        session.unreadCount = 0;
        WLPrivateMessageViewController *contrloller = [[WLPrivateMessageViewController alloc] initWithChat:session];
        [[AppContext rootViewController] pushViewController:contrloller animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - WLMessageManagerReceivedDelegate
- (void)onIMSessionsUpdated:(NSArray<WLIMSession*> *)sessions
{
    [self.sessionGroup appendSessions:sessions];
    self.sessionList = [NSMutableArray arrayWithArray:self.sessionGroup.allSessions];
    [self.tableView reloadData];
}

@end
