//
//  WebViewController.m
//  IQAgent
//
//  Created by IanFan on 2016/12/9.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()<UIWebViewDelegate>
{
    UIWebView *_webView;
    UUTemplateButton *_templateButton;
    
    NSArray *_toolbarItems;
    
    UIBarButtonItem *_goBackButtonItem;
    UIBarButtonItem *_goForwardButtonItem;
    UIBarButtonItem *_reloadButtonItem;
    UIBarButtonItem *_shareButtonItem;
    
    UIActivityIndicatorView *_activityIndicatorView;
}
@end

@implementation WebViewController

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.toolbarHidden = NO;
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    [self.navigationController.toolbar setBarStyle:UIBarStyleBlackOpaque];
    
    UIBarButtonItem *customItem1 = [[UIBarButtonItem alloc] initWithTitle:@"◀️" style:UIBarButtonItemStylePlain target:self action:@selector(onToolbarTapped:)];
    customItem1.tag = 1;
    UIBarButtonItem *customItem2 = [[UIBarButtonItem alloc] initWithTitle:@"▶️" style:UIBarButtonItemStylePlain target:self action:@selector(onToolbarTapped:)];
    customItem2.tag = 2;
    UIBarButtonItem *customItem3 = [[UIBarButtonItem alloc] initWithTitle:@"🔄" style:UIBarButtonItemStylePlain target:self action:@selector(onToolbarTapped:)];
    customItem3.tag = 3;
//    UIBarButtonItem *customItem4 = [[UIBarButtonItem alloc] initWithTitle:@"◀️" style:UIBarButtonItemStylePlain target:self action:@selector(onToolbarTapped:)];
//    customItem4.tag = 4;
    
    _goBackButtonItem = customItem1;
    _goForwardButtonItem = customItem2;
    _reloadButtonItem = customItem3;
//    _shareButtonItem = customItem4;
    
    NSArray *toolbarItems = [NSArray arrayWithObjects:spaceItem, customItem1, spaceItem, customItem2, spaceItem, customItem3, spaceItem, nil];
    
    [self setToolbarItems:toolbarItems animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[IQLog sharedInstance] logScreenName:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

#pragma mark - Command

- (void)updateWithTemplateButton:(UUTemplateButton *)button {
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    
    _templateButton = button;
    
    _webView = nil;
    [self getActivityIndicatorView];
    [self getWebView];
}

- (void)onToolbarTapped:(UIBarButtonItem *)button {
    if (button.tag == 1) {
        [_webView goBack];
    }
    else if (button.tag == 2) {
        [_webView goForward];
    }
    else if (button.tag == 3) {
        [_webView reload];
    }
}

#pragma mark - WebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self checkButtonItemCanGoBackOrForward];
    
    [self getActivityIndicatorView];
    [_activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self checkButtonItemCanGoBackOrForward];
    
    [_activityIndicatorView stopAnimating];
}

- (void)checkButtonItemCanGoBackOrForward {
    if (_webView.canGoBack) {
        _goBackButtonItem.enabled = YES;
    }
    else {
        _goBackButtonItem.enabled = NO;
    }
    
    if (_webView.canGoForward) {
        _goForwardButtonItem.enabled = YES;
    }
    else {
        _goForwardButtonItem.enabled = NO;
    }
}

#pragma mark - Factory

- (UIWebView *)getWebView {
    if (_webView == nil) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        webView.delegate = self;
        [self.view addSubview:webView];
        
        NSURL *url = [NSURL URLWithString:_templateButton.url];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
        
        _webView = webView;
    }
    return _webView;
}

- (UIActivityIndicatorView *)getActivityIndicatorView {
    if (_activityIndicatorView == nil) {
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.center = self.view.center;
        [view hidesWhenStopped];
        [[self getWebView] addSubview:view];
        _activityIndicatorView = view;
    }
    return _activityIndicatorView;
}

@end
