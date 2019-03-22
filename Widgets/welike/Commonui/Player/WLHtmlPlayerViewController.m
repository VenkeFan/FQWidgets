//
//  WLHtmlPlayerViewController.m
//  welike
//
//  Created by fan qi on 2018/6/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLHtmlPlayerViewController.h"
#import <WebKit/WebKit.h>

@interface WLHtmlPlayerViewController () <WKNavigationDelegate>

@property (nonatomic, copy) NSString *playerUrlString;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, weak) UIProgressView *progressView;

@end

@implementation WLHtmlPlayerViewController

- (instancetype)initWithUrlString:(NSString *)urlString {
    if (self = [super init]) {
        _playerUrlString = [urlString copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUI];
    [self loadRequest];
    [self addObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc {
    [self removeObservers];
}

- (void)layoutUI {
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.selectionGranularity = WKSelectionGranularityCharacter;
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight)
                                  configuration:configuration];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
}

- (void)loadRequest {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"embed" ofType:@"html"];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath isDirectory:NO];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:fileUrl resolvingAgainstBaseURL:NO];
    [urlComponents setQueryItems:@[[NSURLQueryItem queryItemWithName:@"source" value:[_playerUrlString urlEncode:NSUTF8StringEncoding]]]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:urlComponents.URL];
    [_webView loadRequest:request];
}

#pragma mark - Observer

- (void)addObservers {
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObservers {
    [_webView removeObserver:self forKeyPath:@"title"];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        NSString *title = change[NSKeyValueChangeNewKey];
        if (![self.title isEqualToString:title]) {
            self.title = title;
        }
        
        return;
    }
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        double progress = [change[NSKeyValueChangeNewKey] doubleValue];;
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:progress animated:YES];
        
        if(progress >= 1.0f) {
            [UIView animateWithDuration:0.25 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
        
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
//    NSLog(@"didFailNavigation: %@", error);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
//    NSLog(@"didFailProvisionalNavigation: %@", error);
}

#pragma mark - Getter

- (UIProgressView *)progressView {
    if (!_progressView) {
        UIProgressView *view = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        view.alpha = 0.0;
        view.progressTintColor = kMainColor;
        view.trackTintColor = kLightBackgroundViewColor;
        view.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, 2.0);
        [self.view addSubview:view];
        _progressView = view;
    }
    return _progressView;
}

@end
