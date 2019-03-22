//
//  WLMainViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLMainViewController.h"
#import "WLHomeViewController.h"
#import "WLDiscoveryViewController.h"
#import "WLMessageViewController.h"
#import "WLRegisterMobileViewController.h"
#import "WLMeViewController.h"
#import "WLPostViewController.h"
#import "WLPublishTaskManager.h"
#import "WLMessageCountObserver.h"
#import "WLTrackerBanner.h"
#import "WLTrackerActivity.h"

@interface WLMainViewController () <WLPublishTaskManagerDelegate, WLHomeViewControllerDelegate, WLMessageCountObserverDelegate> {
    CFTimeInterval beginTime;
    CFTimeInterval endTime;
}

@end

@implementation WLMainViewController

#pragma mark - LifeCycle

- (void)loadView
{
    [super loadView];
    [[AppContext getInstance].publishTaskManager registerDelegate:self];
    [[AppContext getInstance].messageCountObserver registerDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WLHomeViewController *homeCtr = [[WLHomeViewController alloc] init];
//    homeCtr.navigationBar.titleAlignment = WLNavigationBarTitleAlignment_Center;
    homeCtr.delegate = self;
    homeCtr.title = [AppContext getStringForKey:@"main_tab_home" fileName:@"feed"];
    
    WLDiscoveryViewController *disCtr = [[WLDiscoveryViewController alloc] init];
    disCtr.title = [AppContext getStringForKey:@"main_tab_discover" fileName:@"feed"];
    
    WLMessageViewController *msgCtr = [[WLMessageViewController alloc] init];
    msgCtr.navigationBar.titleAlignment = WLNavigationBarTitleAlignment_Center;
    msgCtr.title = [AppContext getStringForKey:@"main_tab_message" fileName:@"feed"];
    
    WLMeViewController *meCtr = [[WLMeViewController alloc] init];
    
    self.viewControllers = @[homeCtr, disCtr, msgCtr, meCtr];
    
    [[AppContext getInstance].messageCountObserver loadFromLocal];
}

- (void)close
{
    [[AppContext getInstance].publishTaskManager unregister:self];
    [[AppContext getInstance].messageCountObserver unregister:self];
}

#pragma mark - Override

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (selectedIndex == super.selectedIndex) {
        if (selectedIndex < self.viewControllers.count && [self.viewControllers[selectedIndex] respondsToSelector:@selector(refreshViewController)]) {
            [self.viewControllers[selectedIndex] performSelector:@selector(refreshViewController)];
        }
    } else {
        if (selectedIndex < self.viewControllers.count && [self.viewControllers[selectedIndex] respondsToSelector:@selector(viewControllerDidAppeared)]) {
            [self.viewControllers[selectedIndex] performSelector:@selector(viewControllerDidAppeared)];
        }
        if (super.selectedIndex < self.viewControllers.count && [self.viewControllers[super.selectedIndex] respondsToSelector:@selector(viewControllerWillDisappear)]) {
            [self.viewControllers[super.selectedIndex] performSelector:@selector(viewControllerWillDisappear)];
        }
    }
    
    [self p_trackerTransition];
    
    [super setSelectedIndex:selectedIndex];
    
    [self p_trackerAppear];
    
    if (selectedIndex == 0) {
        [WLTrackerBanner appendTrackerWithBannerAction:WLTrackerBannerAction_Display
                                                source:WLTrackerBannerSource_Home];
    } else if (selectedIndex == 1) {
        [WLTrackerBanner appendTrackerWithBannerAction:WLTrackerBannerAction_Display
                                                source:WLTrackerBannerSource_Discover];
    }
}

- (void)clickedUnExclusiveViewController
{
    [super clickedUnExclusiveViewController];
  
    WLPostViewController *postViewController = [[WLPostViewController alloc] init];
    postViewController.title = [AppContext getStringForKey:@"editor_post_title" fileName:@"publish" ];
    RDRootViewController *nav = [[RDRootViewController alloc] initWithRootViewController:postViewController];
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

#pragma mark - WLMessageCountObserverDelegate
- (void)messagesCountChanged:(BOOL)has
{
    if (has == YES)
    {
        FQTabBarItem *item = [self.tabBarView.items objectAtIndex:2];
        item.badgeView.hidden = NO;
    }
    else
    {
        FQTabBarItem *item = [self.tabBarView.items objectAtIndex:2];
        item.badgeView.hidden = YES;
    }
}

#pragma mark - WLHomeViewControllerDelegate

- (void)homeViewControllerDidEmptyClicked:(WLHomeViewController *)ctr {
    [self setSelectedIndex:1];
}

#pragma mark - WLPublishTaskManagerDelegate

- (void)onPublishTaskBegin:(NSString *)taskId
{
    [self.tabBarView setUploading:YES];
}

- (void)onPublishTask:(NSString *)taskId process:(CGFloat)process
{
    NSLog(@"3上传进度%f",process);
    [self.tabBarView setUploadProgress:process];//6
}

- (void)onPublishTask:(NSString *)taskId end:(NSInteger)errCode
{
    [self.tabBarView setUploading:NO];
    
    if (errCode == 0)
    {
        [self showToast:[AppContext getStringForKey:@"editor_send_successed" fileName:@"publish"]];
    }
    else
    {
        [self showToastWithNetworkErr:errCode];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:WLNotificationUpdateDraft object:nil];
}

#pragma mark - Private

- (void)p_trackerAppear {
    beginTime = CACurrentMediaTime();
    [WLTrackerActivity appendTrackerWithActivityType:WLTrackerActivityType_Appear
                                                 cls:[self.viewControllers[self.selectedIndex] class]
                                            duration:0];
}

- (void)p_trackerTransition {
    endTime = CACurrentMediaTime();
    CFTimeInterval duration = (endTime - beginTime) * 1000;
    [WLTrackerActivity appendTrackerWithActivityType:WLTrackerActivityType_Transition
                                                 cls:[self.viewControllers[self.selectedIndex] class]
                                            duration:duration];
}

@end
