//
//  WLWebViewController.m
//  welike
//
//  Created by 刘斌 on 2018/5/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLWebViewController.h"
#import "WLAccountManager.h"
#import "RDLocalizationManager.h"
#import "WLAlertController.h"
#import "NSDictionary+JSON.h"
#import "UIColor+LuuBase.h"
#import "WLRouterDefine.h"
#import <WebKit/WebKit.h>
#import "WLShareViewController.h"
#import "WLUserDetailViewController.h"

#define kWebViewNavBarHeight                         44.f

#define kShareWebTitleName                          @"wk-title"
#define kShareWebContentName                        @"wk-sharelink"

@protocol WLWebViewNavBarDelegate <NSObject>

- (void)onClickLeft1Btn;
- (void)onClickLeft2Btn;
- (void)onClickMoreBtn;

@end

@interface WLWebViewNavBar : UIView

@property (nonatomic, strong) UIButton *left1Btn;
@property (nonatomic, strong) UIButton *left2Btn;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) id<WLWebViewNavBarDelegate> delegate;

-(void)changeFrame;

@end

@implementation WLWebViewNavBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.left1Btn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.left1Btn.frame = CGRectMake(0, kSystemStatusBarHeight, kWebViewNavBarHeight, kWebViewNavBarHeight);
        [self.left1Btn addTarget:self action:@selector(clickLeft1Btn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.left1Btn];
        
        self.left2Btn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.left2Btn.frame = CGRectMake(kWebViewNavBarHeight, kSystemStatusBarHeight, kWebViewNavBarHeight, kWebViewNavBarHeight);
        [self.left2Btn addTarget:self action:@selector(clickLeft2Btn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.left2Btn];
        
        self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.moreBtn.frame = CGRectMake(self.width - kWebViewNavBarHeight, kSystemStatusBarHeight, kWebViewNavBarHeight, kWebViewNavBarHeight);
        [self.moreBtn addTarget:self action:@selector(clickMoreBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.moreBtn];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kWebViewNavBarHeight * 2, kSystemStatusBarHeight, self.width - kWebViewNavBarHeight * 3, kWebViewNavBarHeight)];
        self.titleLabel.font = kMediumFont(kNameFontSize);
        self.titleLabel.textColor = kNameFontColor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
    }
    return self;
}

-(void)changeFrame
{
    if (self.left2Btn.hidden)
    {
        self.titleLabel.frame = CGRectMake(kWebViewNavBarHeight, kSystemStatusBarHeight, self.width - kWebViewNavBarHeight * 2, kWebViewNavBarHeight);
    }
    else
    {
          self.titleLabel.frame = CGRectMake(kWebViewNavBarHeight*2, kSystemStatusBarHeight, self.width - kWebViewNavBarHeight * 3, kWebViewNavBarHeight);
    }
}

- (void)clickLeft1Btn
{
    if ([self.delegate respondsToSelector:@selector(onClickLeft1Btn)])
    {
        [self.delegate onClickLeft1Btn];
    }
}

- (void)clickLeft2Btn
{
    if ([self.delegate respondsToSelector:@selector(onClickLeft2Btn)])
    {
        [self.delegate onClickLeft2Btn];
    }
}

- (void)clickMoreBtn
{
    if ([self.delegate respondsToSelector:@selector(onClickMoreBtn)])
    {
        [self.delegate onClickMoreBtn];
    }
}

@end

@interface WLWebViewController () <WLWebViewNavBarDelegate,WKNavigationDelegate>

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) WLWebViewNavBar *navBar;
@property (nonatomic, strong) UIProgressView *progressBar;
@property (nonatomic, strong) WKWebView *webview;
@property (nonatomic, assign) NSInteger menu;

@end

@implementation WLWebViewController

- (id)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self)
    {
        //去掉前后空格
        NSString *checkUrl = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        BOOL hasWelikeParams = NO;
        WLAccount *account = [[AppContext getInstance].accountManager myAccount];
        NSURL *u = [NSURL URLWithString:checkUrl];
        
        if (u.query.length == 0)
        {
//            NSString *newUrl = [NSString stringWithFormat:@"%@?welike_params=dntocoavchlaovdelofr",checkUrl];
//            u = [NSURL URLWithString:newUrl];
//            checkUrl = newUrl;
            
            NSString *newUrl = [NSString stringWithFormat:@"https://%@/?welike_params=dntocoavchlaovdelofr#%@",u.host,u.fragment];
            u = [NSURL URLWithString:newUrl];
            checkUrl = newUrl;
        }
       
        NSArray *queryComponents = [u.query componentsSeparatedByString:@"&"];
        NSMutableDictionary *extParams = [NSMutableDictionary dictionary];
        for (NSString *keyValuePair in queryComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] urlDecode:NSUTF8StringEncoding];
            NSString *value = [[pairComponents lastObject] urlDecode:NSUTF8StringEncoding];
            if ([key isEqualToString:@"welike_params"] == YES)
            {
                hasWelikeParams = YES;
                for (NSInteger i = 0; i < [value length]; i += 2)
                {
                    if (i + 2 > value.length)
                    {
                        break;
                    }
                    
                    NSString *k = [value substringWithRange:NSMakeRange(i, 2)];
                    if ([k isEqualToString:@"dn"] == YES)
                    {
                        [extParams setObject:account.uid forKey:@"dn"];
                    }
                    else if ([k isEqualToString:@"ch"] == YES)
                    {
                        [extParams setObject:@"apple" forKey:@"ch"];
                    }
                    else if ([k isEqualToString:@"ov"] == YES)
                    {
                        [extParams setObject:[UIDevice currentDevice].systemVersion forKey:@"ov"];
                    }
                    else if ([k isEqualToString:@"to"] == YES)
                    {
                        [extParams setObject:account.accessToken forKey:@"to"];
                    }
                    else if ([k isEqualToString:@"co"] == YES)
                    {
                        [extParams setObject:@"IN" forKey:@"co"];
                    }
                    else if ([k isEqualToString:@"la"] == YES)
                    {
                        [extParams setObject:[[RDLocalizationManager getInstance] getCurrentLanguage] forKey:@"la"];
                    }
                    else if ([k isEqualToString:@"av"] == YES)
                    {
                        [extParams setObject:[LuuUtils appVersion] forKey:@"av"];
                    }
                    else if ([k isEqualToString:@"en"] == YES)
                    {
                        [extParams setObject:@"welike" forKey:@"en"];
                    }
                }
            }
            else
            {
                [extParams setObject:value forKey:key];
            }
        }
        
        if (hasWelikeParams == YES)
        {
            self.url = [NSString stringWithFormat:@"https://%@%@?%@", u.host, u.path, [[self class] defaultQueryStringFromDictionary:extParams]];
        }
        else
        {
            self.url = [checkUrl convertToHttps];
        }
        
        if (u.fragment.length > 0)
        {
            self.url = [NSString stringWithFormat:@"%@#%@",self.url,u.fragment];
        }
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.navBar = [[WLWebViewNavBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kNavBarHeight)];
    self.navBar.delegate = self;
//    self.navBar.backgroundColor = kMainColor;
    [self.view addSubview:self.navBar];
    
    if ([self.routerParams count] > 0)
    {
        NSString *color = [self.routerParams stringForKey:WLROUTER_PARAM_WEBVIEW_TITLE_COLOR];
        if ([color length] > 0)
        {
            UIColor *c = [UIColor colorwithHexString:color];
            if (c != nil)
            {
                self.navBar.backgroundColor = c;
            }
        }
        
        NSInteger show = [self.routerParams integerForKey:WLROUTER_PARAM_WEBVIEW_SHOW_TITLE def:1];
        if (show == 0)
        {
            self.navBar.hidden = YES;
        }
        
        self.menu = [self.routerParams integerForKey:WLROUTER_PARAM_WEBVIEW_MENU_ITEM def:3];
        if (self.menu == 0 || self.menu == 4) self.menu = 3;
        
        if (self.menu == 7)
        {
            [self.navBar.left1Btn setImage:[AppContext getImageForKey:@"common_icon_back"] forState:UIControlStateNormal];
            [self.navBar.left2Btn setImage:[AppContext getImageForKey:@"common_nav_close"] forState:UIControlStateNormal];
            [self.navBar.moreBtn setImage:[AppContext getImageForKey:@"common_more"] forState:UIControlStateNormal];
        }
        else if (self.menu == 6)
        {
            [self.navBar.left1Btn setImage:[AppContext getImageForKey:@"common_nav_close"] forState:UIControlStateNormal];
            [self.navBar.moreBtn setImage:[AppContext getImageForKey:@"common_more"] forState:UIControlStateNormal];
            self.navBar.left2Btn.hidden = YES;
        }
        else if (self.menu == 5)
        {
            [self.navBar.left1Btn setImage:[AppContext getImageForKey:@"common_icon_back"] forState:UIControlStateNormal];
            [self.navBar.moreBtn setImage:[AppContext getImageForKey:@"common_more"] forState:UIControlStateNormal];
            self.navBar.left2Btn.hidden = YES;
        }
        else if (self.menu == 3)
        {
            [self.navBar.left1Btn setImage:[AppContext getImageForKey:@"common_icon_back"] forState:UIControlStateNormal];
            [self.navBar.left2Btn setImage:[AppContext getImageForKey:@"common_nav_close"] forState:UIControlStateNormal];
            self.navBar.moreBtn.hidden = YES;
        }
        else if (self.menu == 2)
        {
            [self.navBar.left1Btn setImage:[AppContext getImageForKey:@"common_nav_close"] forState:UIControlStateNormal];
            self.navBar.left2Btn.hidden = YES;
            self.navBar.moreBtn.hidden = YES;
        }
        else if (self.menu == 1)
        {
            [self.navBar.left1Btn setImage:[AppContext getImageForKey:@"common_icon_back"] forState:UIControlStateNormal];
            self.navBar.left2Btn.hidden = YES;
            self.navBar.moreBtn.hidden = YES;
        }
    }
    else
    {
        self.menu = 3;
        [self.navBar.left1Btn setImage:[AppContext getImageForKey:@"common_icon_back"] forState:UIControlStateNormal];
        [self.navBar.left2Btn setImage:[AppContext getImageForKey:@"common_nav_close"] forState:UIControlStateNormal];
        self.navBar.moreBtn.hidden = YES;
    }
    
    [self.navBar changeFrame];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 0.0;
    preferences.javaScriptEnabled = YES;
    configuration.preferences = preferences;
    
//    if (self.navBar.left2Btn.hidden == YES)
//    {
//        self.navBar.width = kScreenWidth - 80;
//    }
//    else
//    {
//         self.navBar.width = kScreenWidth - 120;
//    }
    
    if (self.navBar.hidden == YES)
    {
        self.webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, kSystemStatusBarHeight, self.view.width, self.view.height - kSystemStatusBarHeight) configuration:configuration];
    }
    else
    {
        self.webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, self.navBar.bottom, self.view.width, self.view.height - self.navBar.height) configuration:configuration];
    }
    self.webview.navigationDelegate = self;
    
    if ([self.url length] > 0)
    {
        [self.view addSubview:self.webview];
    }
    
    self.progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(0, self.webview.top, self.view.width, 2.f)];
    self.progressBar.tintColor = kMainColor;
    self.progressBar.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.progressBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.webview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webview addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

- (void)dealloc
{
    [self.webview removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webview removeObserver:self forKeyPath:@"title"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        if (object == self.webview)
        {
            [self.progressBar setAlpha:1.0f];
            [self.progressBar setProgress:self.webview.estimatedProgress animated:YES];
            if(self.webview.estimatedProgress >= 1.0f)
            {
                __weak typeof(self) weakSelf = self;
                [UIView animateWithDuration:0.5f
                                      delay:0.3f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [weakSelf.progressBar setAlpha:0.0f];
                                 }
                                 completion:^(BOOL finished) {
                                     [weakSelf.progressBar setProgress:0.0f animated:NO];
                                 }];
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else if ([keyPath isEqualToString:@"title"])
    {
        if (object == self.webview)
        {
            self.navBar.titleLabel.text = self.webview.title;
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)onBack
{
    [self.webview goBack];
}

- (void)onClose
{
    [[AppContext rootViewController] popViewControllerAnimated:YES];
}

#pragma mark - Share

- (void)showShareController {
//    NSString *js = @"document.documentElement.innerHTML.toString()"
//    NSString *js = @"document.getElementsByTagName('head')";
    
    [self.webview evaluateJavaScript:@"document.documentElement.innerHTML.toString()"
                   completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                       if (!error) {
                           NSString *innerHtml = result;
                           
                           NSArray *metas = [self metaPropertysInHtmlStr:innerHtml];
                           
                           NSString *shareTitle = [self shareContentWithTag:kShareWebTitleName inMetas:metas];
                           NSString *shareLink = [self shareContentWithTag:kShareWebContentName inMetas:metas];
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               WLShareModel *shareModel = [WLShareModel modelWithID:nil
                                                                               type:WLShareModelType_WebView
                                                                              title:shareTitle
                                                                               desc:nil
                                                                             imgUrl:nil
                                                                            linkUrl:shareLink];
                               
                               WLShareViewController *ctr = [[WLShareViewController alloc] init];
                               ctr.shareModel = shareModel;
                               [self presentViewController:ctr animated:YES completion:nil];
                           });
                       }
                   }];
}

- (NSArray<NSDictionary *> *)metaPropertysInHtmlStr:(NSString *)htmlStr {
    NSMutableArray<NSString *> *metas = [NSMutableArray array];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<meta(.*)>" options:kNilOptions error:nil];
    NSArray<NSTextCheckingResult *> *resultArray = [regex matchesInString:htmlStr
                                                                  options:kNilOptions
                                                                    range:NSMakeRange(0, htmlStr.length)];
    for (NSTextCheckingResult *result in resultArray) {
        if (result.range.location == NSNotFound || result.range.length < 1) {
            continue;
        }
        
        NSString *metaStr = [htmlStr substringWithRange:result.range];
        [metas addObject:metaStr];
    }
    
    
    NSMutableArray<NSDictionary *> *metaDicArray = [NSMutableArray arrayWithCapacity:metas.count];
    for (int i = 0; i < metas.count; i++) {
        NSString *metaStr = metas[i];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        NSRegularExpression *nameRegex = [NSRegularExpression regularExpressionWithPattern:@"name=\"(.*?)\"" options:kNilOptions error:nil];
        NSTextCheckingResult *nameResult = [nameRegex matchesInString:metaStr
                                                              options:kNilOptions
                                                                range:NSMakeRange(0, metaStr.length)].firstObject;
        if (nameResult.range.location == NSNotFound || nameResult.range.length < 1) {
            continue;
        }
        
        NSRegularExpression *contentRegex = [NSRegularExpression regularExpressionWithPattern:@"content=\"(.*?)\"" options:kNilOptions error:nil];
        NSTextCheckingResult *contentResult = [contentRegex matchesInString:metaStr
                                                                    options:kNilOptions
                                                                      range:NSMakeRange(0, metaStr.length)].firstObject;
        if (contentResult.range.location == NSNotFound || contentResult.range.length < 1) {
            continue;
        }
        
        NSString *nameProperty = [metaStr substringWithRange:nameResult.range];
        NSArray *keyValues = [self scannerString:nameProperty];
        if (keyValues.count > 1) {
            [dic setObject:keyValues[1] forKey:keyValues[0]];
        }
        
        NSString *contentProperty = [metaStr substringWithRange:contentResult.range];
        keyValues = [self scannerString:contentProperty];
        if (keyValues.count > 1) {
            [dic setObject:keyValues[1] forKey:keyValues[0]];
        }
        
        [metaDicArray addObject:dic];
    }
    
    return metaDicArray;
}

- (NSArray *)scannerString:(NSString *)str {
    NSScanner *scanner = [NSScanner scannerWithString:str];
    NSString *key = nil;
    NSString *value = nil;
    
    while (!scanner.isAtEnd) {
        [scanner scanUpToString:@"\"" intoString:&key];
        [scanner scanString:@"\"" intoString:nil];
        [scanner scanUpToString:@"\"" intoString:&value];
    }
    
    if (key.length > 1) {
        key = [key substringToIndex:key.length - 1];
    }
    
    if (!key || !value) {
        return nil;
    }
    
    return @[key, value];  
}

- (NSString *)shareContentWithTag:(NSString *)tag inMetas:(NSArray *)metas {
    NSString *shareContent = nil;
    
    for (int i = 0; i < metas.count; i++) {
        NSDictionary *metaDic = metas[i];
        if ([metaDic[@"name"] isEqualToString:tag]) {
            shareContent = metaDic[@"content"];
        }
    }
    
    return shareContent;
}

#pragma mark - WLWebViewNavBarDelegate
- (void)onClickLeft1Btn
{
    if (self.menu == 7)
    {
        [self onBack];
    }
    else if (self.menu == 6)
    {
        [self onClose];
    }
    else if (self.menu == 5)
    {
        [self onBack];
    }
    else if (self.menu == 3)
    {
        [self onBack];
    }
    else if (self.menu == 2)
    {
        [self onClose];
    }
    else if (self.menu == 1)
    {
        [self onBack];
    }
}

- (void)onClickLeft2Btn
{
    if (self.menu == 7)
    {
        [self onClose];
    }
    else if (self.menu == 3)
    {
        [self onClose];
    }
}

- (void)onClickMoreBtn
{
    WLAlertController *alert = [WLAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"feed_share" fileName:@"feed"]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self showShareController];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"common_cancel" fileName:@"common"]
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                            }]];
    [[AppContext rootViewController] presentViewController:alert animated:YES completion:nil];
}

+ (NSString *)defaultQueryStringFromDictionary:(NSDictionary *)dictionary
{
    if ([dictionary count] <= 0) return @"";
    
    NSMutableString *postStr = [NSMutableString string];
    NSArray *allKeys = [dictionary allKeys];
    for (id key in allKeys)
    {
        NSString *keyName = [NSString stringWithFormat:@"%@", key];
        NSString *valName = [NSString stringWithFormat:@"%@", [dictionary objectForKey:key]];
        [postStr appendFormat:@"%@=%@&", keyName, [valName urlEncode:NSUTF8StringEncoding]];
    }
    
    return [NSString stringWithString:[postStr substringWithRange:NSMakeRange(0, [postStr length] - 1)]];
}

#pragma mark - WLWebViewDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void(^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *strRequest = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   
    NSURL *u = [NSURL URLWithString:strRequest];
    NSArray *queryComponents = [u.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *extParams = [NSMutableDictionary dictionary];
    
    for (NSString *keyValuePair in queryComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] urlDecode:NSUTF8StringEncoding];
        NSString *value = [[pairComponents lastObject] urlDecode:NSUTF8StringEncoding];
        
        [extParams setObject:value forKey:key];
    }
    
    if ([extParams.allKeys containsObject:@"page_name"] && [extParams.allKeys containsObject:@"uid"])
    {
        NSString *uid = [extParams objectForKey:@"uid"];
        //打开用户资料
        WLUserDetailViewController *vc = [[WLUserDetailViewController alloc] initWithUserID:uid];
        [[AppContext rootViewController] pushViewController:vc animated:YES];
        decisionHandler(WKNavigationActionPolicyCancel);//不允许跳转
    }
    else
    {
         decisionHandler(WKNavigationActionPolicyAllow);//允许跳转
    }
}

@end
