//
//  MsmWebViewController.m
//  openadsdk
//
//  Created by Franky Lee on 2020/9/1.
//  Copyright © 2020 Franky Lee. All rights reserved.
//

#import "MsmWebViewController.h"
#import <WebKit/WebKit.h>
#import "MsmPrefixHeader.pch"
#import <BUAdSDK/BUNativeExpressBannerView.h>
#import <BUAdSDK/BUAdSDK.h>
#import <BUAdSDK/BUNativeExpressAdManager.h>
#import <BUAdSDK/BUNativeExpressAdView.h>
#import "PopoverView.h"
#import "UIViewController+Hidden.h"

#define URL_define @"URL"

// WKWebView 内存不释放的问题解决
@interface WeakWebViewScriptMessageDelegate : NSObject<WKScriptMessageHandler>

//WKScriptMessageHandler 这个协议类专门用来处理JavaScript调用原生OC的方法
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
@implementation WeakWebViewScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

#pragma mark - WKScriptMessageHandler
//遵循WKScriptMessageHandler协议，必须实现如下方法，然后把方法向外传递
//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end

@interface MsmWebViewController ()<
    WKScriptMessageHandler,
    WKUIDelegate,
    WKNavigationDelegate,
    BUNativeExpressBannerViewDelegate,
    BUNativeExpressAdViewDelegate,
    BUNativeExpressRewardedVideoAdDelegate,
    PopoverViewDelegate
>

@property(nonatomic, strong) WKWebView *webView;
//网页加载进度视图
@property(nonatomic, strong) UIProgressView *progressView;
// banner广告view
@property(nonatomic, strong) BUNativeExpressBannerView *bannerView;
// 信息流广告
@property (strong, nonatomic) NSMutableArray<__kindof BUNativeExpressAdView *> *expressAdViews;
@property (strong, nonatomic) BUNativeExpressAdManager *nativeExpressAdManager;
@property(nonatomic, copy) NSString *nativeTop;
@property(nonatomic, copy) NSString *nativeLeft;
// 激励视频
@property (nonatomic, strong) BUNativeExpressRewardedVideoAd *rewardedAd;

@end

@implementation MsmWebViewController

#pragma mark - Override
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationBar];
    [self setupNavigationItem: NO];
    self.expressAdViews = [NSMutableArray new];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    //添加监测网页加载进度的观察者
    [self.webView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                      options:0
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
    [self.webView addObserver:self
                   forKeyPath:URL_define
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
}

// 是否显示navigationbar
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_showToolbar) {
        //设置代理即可
        self.navigationController.delegate = self;
    }
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
//    UIEdgeInsets insets = self.view.safeAreaInsets;
    self.progressView.frame = CGRectMake(0, 0, self.view.frame.size.width, 3);
}
- (void)dealloc{
    //移除注册的js方法
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"showToutiaoBannerAd"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"dismissToutiaoBannerAd"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"showToutiaoNativeAd"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"dismissToutiaoNativeAd"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"loadToutiaoRewardVideoAd"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"playToutiaoRewardVideoAd"];
    //移除观察者
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(title))];
    [_webView removeObserver:self
                  forKeyPath:URL_define];
}

#pragma mark - NavigationBar
- (void)setUpNavigationBar{
    // navigationBar背景色
    [self.navigationController.navigationBar setBarTintColor:MsmNavigationBarColor];
    // 控件颜色
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    // 设置标题
    [self.navigationController.navigationBar setTitleTextAttributes:@{
        NSFontAttributeName:[UIFont systemFontOfSize: 16 weight:UIFontWeightMedium],
        NSForegroundColorAttributeName:[UIColor blackColor]
    }];
    // 默认（YES）
    [self.navigationController.navigationBar setTranslucent:NO];
    // 去除导航栏底部黑色
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    // 更多按钮
    UIButton * moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[[UIImage imageNamed:@"msm_more.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.frame = CGRectMake(0, 0, 20, StatusBarAndNavigationBarHeight);
    UIBarButtonItem * moreButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    
    self.navigationItem.rightBarButtonItems = @[moreButtonItem];
}

#pragma mark - UI
- (void)setupNavigationItem:(BOOL)showBack{
    
    UIButton * exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [exitButton setImage:[[UIImage imageNamed:@"msm_cancel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(exitAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (showBack) {
        // 后退按钮
        UIButton * goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        goBackButton.frame = CGRectMake(0, 0, 20, StatusBarAndNavigationBarHeight);
        [goBackButton setImage:[[UIImage imageNamed:@"msm_back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [goBackButton addTarget:self action:@selector(goBackAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * goBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
        
        // 退出按钮
        exitButton.frame = CGRectMake(40, 0, 60, StatusBarAndNavigationBarHeight);
        UIBarButtonItem * exitButtonItem = [[UIBarButtonItem alloc] initWithCustomView:exitButton];
        self.navigationItem.leftBarButtonItems = @[goBackButtonItem, exitButtonItem];
    } else {
        // 退出按钮
        exitButton.frame = CGRectMake(0, 0, 20, StatusBarAndNavigationBarHeight);
        UIBarButtonItem * exitButtonItem = [[UIBarButtonItem alloc] initWithCustomView:exitButton];
        self.navigationItem.leftBarButtonItems = @[exitButtonItem];
    }
    
    
}

#pragma mark - Event Handle
- (void)goBackAction:(id)sender{
    [_webView goBack];
}

- (void)moreAction:(id)sender{
    [self popSubView];
}
// 退出
- (void)exitAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// 弹窗菜单
- (void)popSubView{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGPoint point = CGPointMake(screenWidth-30, (StatusBarAndNavigationBarHeight+StatusBarHeight)/2-2);
    PopoverView *view = [[PopoverView alloc]initWithPoint:point
                                                   titles:@[@"刷新网页", @"复制链接", @"清除缓存", @"在浏览器打开"]
                                               imageNames:nil];
    view.delegate = self;
    [view show];
    
}

#pragma mark - KVO
//kvo 监听进度 必须实现此方法
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == _webView) {
        
        NSLog(@"网页加载进度 = %f",_webView.estimatedProgress);
        self.progressView.progress = _webView.estimatedProgress;
        if (_webView.estimatedProgress >= 1.0f) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.progress = 0;
            });
        }
        
    }else if([keyPath isEqualToString:@"title"]
             && object == _webView){
        self.navigationItem.title = _webView.title;
    } else if([keyPath isEqualToString:@"URL"]){
        NSLog(@" 当前 URL------%@",_webView.URL.absoluteString);
        [self setupNavigationItem:![_webView.URL.absoluteString isEqualToString:_url]];
    } else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark - Getter
- (UIProgressView *)progressView {
    if (!_progressView){
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 3)];
        _progressView.tintColor = [UIColor greenColor];
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}
- (WKWebView *)webView{
    if(_webView == nil){
        
        //创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        // 创建设置对象
        WKPreferences *preference = [[WKPreferences alloc]init];
        //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
        preference.minimumFontSize = 0;
        //设置是否支持javaScript 默认是支持的
        preference.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preference;
        
        // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
        config.allowsInlineMediaPlayback = YES;
        //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
        config.mediaTypesRequiringUserActionForPlayback = YES;
        //设置是否允许画中画技术 在特定设备上有效
        config.allowsPictureInPictureMediaPlayback = YES;
        //设置请求的User-Agent信息中应用程序名称 iOS9后可用
        config.applicationNameForUserAgent = @"msmds";
        
        //自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
        WeakWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[WeakWebViewScriptMessageDelegate alloc] initWithDelegate:self];
        //这个类主要用来做native与JavaScript的交互管理
        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        //注册一个name为showToutiaoBannerAd的js方法 设置处理接收JS方法的对象
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"showToutiaoBannerAd"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"dismissToutiaoBannerAd"];
        
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"showToutiaoNativeAd"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"dismissToutiaoNativeAd"];
        
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"loadToutiaoRewardVideoAd"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"playToutiaoRewardVideoAd"];
        
        config.userContentController = wkUController;
        
        //以下代码适配文本大小
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        //用于进行JavaScript注入
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [config.userContentController addUserScript:wkUScript];
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-(_showToolbar ? StatusBarAndNavigationBarHeight : 0)+BottomSafeAreaHeight) configuration:config];
        // UI代理
        _webView.UIDelegate = self;
        // 导航代理
        _webView.navigationDelegate = self;
        // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
        _webView.allowsBackForwardNavigationGestures = YES;
        //可返回的页面列表, 存储已打开过的网页
        // WKBackForwardList * backForwardList = [_webView backForwardList];
        NSString *urlStr = _url;
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [_webView loadRequest:request];
        
        
    }
    return _webView;
}

//解决第一次进入的cookie丢失问题
- (NSString *)readCurrentCookieWithDomain:(NSString *)domainStr{
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableString * cookieString = [[NSMutableString alloc]init];
    for (NSHTTPCookie*cookie in [cookieJar cookies]) {
        [cookieString appendFormat:@"%@=%@;",cookie.name,cookie.value];
    }
    
    //删除最后一个“;”
    if ([cookieString hasSuffix:@";"]) {
        [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
    }
    
    return cookieString;
}

//解决 页面内跳转（a标签等）还是取不到cookie的问题
- (void)getCookie{
    
    //取出cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //js函数
    NSString *JSFuncString =
    @"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
    document.cookie=name+'='+value+';expires='+oDate+';path=/'\
    }\
    function getCookie(name)\
    {\
    var arr = document.cookie.match(new RegExp('(^| )'+name+'=([^;]*)(;|$)'));\
    if(arr != null) return unescape(arr[2]); return null;\
    }\
    function delCookie(name)\
    {\
    var exp = new Date();\
    exp.setTime(exp.getTime() - 1);\
    var cval=getCookie(name);\
    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
    }";
    
    //拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        [JSCookieString appendString:excuteJSString];
    }
    //执行js
    [_webView evaluateJavaScript:JSCookieString completionHandler:nil];
    
}

//被自定义的WKScriptMessageHandler在回调方法里通过代理回调回来，绕了一圈就是为了解决内存不释放的问题
//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //JS调用OC
    @try {
        if([message.name isEqualToString:@"showToutiaoBannerAd"]){
            NSLog(@"userContentController:%@",@"showToutiaoBannerAd------");
            // 解析style，加载显示banner广告
            //用message.body获得JS传出的参数体
            NSString * parameter = message.body;
            NSDictionary * adStyleData = [self dictionaryWithJsonString:parameter];
            NSDictionary *data = [adStyleData objectForKey:@"style"];
            if (data != nil) {
                NSString *top = [data objectForKey:@"top"];
                NSString *left = [data objectForKey:@"left"];
                NSString *width = [data objectForKey:@"width"];
                NSString *height = [data objectForKey:@"height"];
                [self loadData:top:left:width:height];
            }
        }else if([message.name isEqualToString:@"dismissToutiaoBannerAd"]){
            // 移除banner广告
            NSLog(@"userContentController:%@",@"dismissToutiaoBannerAd------");
            [self.bannerView removeFromSuperview];
        } else if ([message.name isEqualToString:@"showToutiaoNativeAd"]) {
            NSLog(@"userContentController:%@",@"showToutiaoNativeAd------");
            // 解析style，加载显示信息流广告
            NSString * parameter = message.body;
            NSDictionary * adStyleData = [self dictionaryWithJsonString:parameter];
            NSDictionary *data = [adStyleData objectForKey:@"style"];
            if (data != nil) {
                self.nativeTop = [data objectForKey:@"top"];
                self.nativeLeft = [data objectForKey:@"left"];
                NSString *top = [data objectForKey:@"top"];
                NSString *left = [data objectForKey:@"left"];
                NSString *width = [data objectForKey:@"width"];
                NSString *height = [data objectForKey:@"height"];
                [self loadNativeData:top:left:width:height];
            }
        } else if ([message.name isEqualToString:@"dismissToutiaoNativeAd"]) {
            NSLog(@"userContentController:%@",@"dismissToutiaoNativeAd------");
            // 移除信息流广告
            BUNativeExpressAdView *expressAdView = [self.expressAdViews firstObject];
            [expressAdView removeFromSuperview];
            [self.expressAdViews removeAllObjects];

        } else if ([message.name isEqualToString:@"loadToutiaoRewardVideoAd"]) {
            NSLog(@"userContentController:%@",@"loadToutiaoRewardVideoAd------");
            // 加载激励视频
            [self loadRewardVideoAdWithSlotID:_rewardVideoCodeId];
        } else if ([message.name isEqualToString:@"playToutiaoRewardVideoAd"]) {
            NSLog(@"userContentController:%@",@"playToutiaoRewardVideoAd------");
            // 播放激励视频
            [self showRewardVideoAd];
        }
    } @catch (NSException *exception) {
        NSLog(@"NSException%@",exception);
    } @finally {
        NSLog(@"@finally%@",@"");
    }
    
}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark - WKNavigationDelegate
/*
 WKNavigationDelegate主要处理一些跳转、加载处理操作，WKUIDelegate主要处理JS脚本，确认框，警告框等
 */

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailProvisionalNavigation:%@", error);
    [self.progressView setProgress:0.0f animated:NO];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self getCookie];
    // 禁止webview缩放
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
}

//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
}

// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString * urlStr = navigationAction.request.URL.absoluteString;
    NSLog(@"发送跳转请求：%@",urlStr);
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        //跳转别的应用如系统浏览器
        // 对于跨域，需要手动跳转
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
        // 不允许web内跳转
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {//应用的web内跳转
        decisionHandler (WKNavigationActionPolicyAllow);
    }
    return;
    
}

// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    NSLog(@"当前跳转地址：%@",urlStr);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
//    decisionHandler(WKNavigationResponsePolicyCancel);
}

//需要响应身份验证时调用 同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    //用户身份信息
    NSURLCredential * newCred = [[NSURLCredential alloc] initWithUser:@"user123" password:@"123" persistence:NSURLCredentialPersistenceNone];
    //为 challenge 的发送方提供 credential
    [challenge.sender useCredential:newCred forAuthenticationChallenge:challenge];
    completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
    
}

//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    
}

#pragma mark - WKUIDelegate

/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"HTML的弹出框" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 确认框
//JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 输入框
//JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 页面是弹出窗口 _blank 处理
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma BUNativeExpressBannerViewDelegate
- (void)loadData:(NSString *)top :(NSString *)left :(NSString *)width :(NSString *)height {
    
    CGFloat marginTop = [top floatValue];
    CGFloat marginLeft = [left floatValue];
    CGFloat screenWidth = [width floatValue];
    CGFloat bannerHeigh = [height floatValue];
    
    [self.bannerView removeFromSuperview];
    self.bannerView = [[BUNativeExpressBannerView alloc] initWithSlotID:_bannerCodeId rootViewController:self adSize:CGSizeMake(screenWidth, bannerHeigh) IsSupportDeepLink:YES];
    self.bannerView.frame = CGRectMake(marginLeft, marginTop, screenWidth, bannerHeigh);
    self.bannerView.delegate = self;
  
    [self.bannerView loadAdData];
}

- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__func__);
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    NSLog(@"%s",__func__);
    [_webView evaluateJavaScript:@"javascript:window.BannerLoadError();" completionHandler:nil];
}

- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__func__);
    CGFloat height = bannerAdView.bounds.size.height;
    [self.webView.scrollView addSubview:self.bannerView];
    NSString *jsStr = [NSString stringWithFormat:@"javascript:window.BannerLoadSuccess({height:%g});",height];
    [_webView evaluateJavaScript:jsStr completionHandler:nil];
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError *)error {
    NSLog(@"%s",__func__);
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__func__);
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__func__);
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterwords {
    NSLog(@"%s",__func__);
    [_webView evaluateJavaScript:@"javascript:window.BannerHideManually();" completionHandler:nil];
    [UIView animateWithDuration:0.25 animations:^{
        bannerAdView.alpha = 0;
    } completion:^(BOOL finished) {
        [bannerAdView removeFromSuperview];
        if (self.bannerView == bannerAdView) {
            self.bannerView = nil;
        }
    }];
}


#pragma BUNativeExpressAdViewDelegate
// 信息流广告
- (void)loadNativeData:(NSString *)top :(NSString *)left :(NSString *)width :(NSString *)height {
    
    CGFloat screenWidth = [width floatValue];
    CGFloat bannerHeigh = [height floatValue];
    if (!self.expressAdViews) {
        self.expressAdViews = [NSMutableArray arrayWithCapacity:20];
    }
    BUAdSlot *slot1 = [[BUAdSlot alloc] init];
    slot1.ID = _nativeCodeId;
    slot1.AdType = BUAdSlotAdTypeFeed;
    BUSize *imgSize = [BUSize sizeBy:BUProposalSize_Feed228_150];
    slot1.imgSize = imgSize;
    slot1.position = BUAdSlotPositionFeed;
    slot1.isSupportDeepLink = YES;
    
    // self.nativeExpressAdManager可以重用
    if (!self.nativeExpressAdManager) {
        self.nativeExpressAdManager = [[BUNativeExpressAdManager alloc] initWithSlot:slot1 adSize:CGSizeMake(screenWidth, bannerHeigh)];
    }
    self.nativeExpressAdManager.adSize = CGSizeMake(screenWidth, bannerHeigh);
    self.nativeExpressAdManager.delegate = self;
    [self.nativeExpressAdManager loadAd:1];
}

- (void)nativeExpressAdSuccessToLoad:(BUNativeExpressAdManager *)nativeExpressAd views:(NSArray<__kindof BUNativeExpressAdView *> *)views {
    BUNativeExpressAdView *expressAdView = [self.expressAdViews firstObject];
    [expressAdView removeFromSuperview];
    [self.expressAdViews removeAllObjects];//【重要】不能保存太多view，需要在合适的时机手动释放不用的，否则内存会过大
    if (views.count) {
        [self.expressAdViews addObjectsFromArray:views];
        [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BUNativeExpressAdView *expressView = (BUNativeExpressAdView *)obj;
            expressView.rootViewController = self;
            // important: 此处会进行WKWebview的渲染，建议一次最多预加载三个广告，如果超过3个会很大概率导致WKWebview渲染失败。
            [expressView render];
        }];
    }

}

- (void)nativeExpressAdFailToLoad:(BUNativeExpressAdManager *)nativeExpressAd error:(NSError *)error {
    [_webView evaluateJavaScript:@"javascript:window.NativeError();" completionHandler:nil];
}

- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView {
    CGFloat marginTop = [self.nativeTop floatValue];
    CGFloat marginLeft = [self.nativeLeft floatValue];
    nativeExpressAdView.frame = CGRectMake(marginLeft, marginTop, nativeExpressAdView.bounds.size.width, nativeExpressAdView.bounds.size.height);
    [self.webView.scrollView addSubview:nativeExpressAdView];
    [_webView evaluateJavaScript:@"javascript:window.NativeRenderSuccess();" completionHandler:nil];
}

- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView stateDidChanged:(BUPlayerPlayState)playerState {
//    NSLog(@"====== %p playerState = %ld",nativeExpressAdView,(long)playerState);

}

- (void)nativeExpressAdViewRenderFail:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *)error {
    
}

- (void)nativeExpressAdViewWillShow:(BUNativeExpressAdView *)nativeExpressAdView {
    
}

- (void)nativeExpressAdViewDidClick:(BUNativeExpressAdView *)nativeExpressAdView {
    
}

- (void)nativeExpressAdViewPlayerDidPlayFinish:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *)error {
    
}

- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {//【重要】需要在点击叉以后 在这个回调中移除视图，否则，会出现用户点击叉无效的情况
    [nativeExpressAdView removeFromSuperview];
    [self.expressAdViews removeAllObjects];
    [_webView evaluateJavaScript:@"javascript:window.NativeShield();" completionHandler:nil];
}

- (void)nativeExpressAdViewDidClosed:(BUNativeExpressAdView *)nativeExpressAdView {
    
}

- (void)nativeExpressAdViewWillPresentScreen:(BUNativeExpressAdView *)nativeExpressAdView {
    
}

- (void)nativeExpressAdViewDidCloseOtherController:(BUNativeExpressAdView *)nativeExpressAdView interactionType:(BUInteractionType)interactionType {
    NSString *str = nil;
    if (interactionType == BUInteractionTypePage) {
        str = @"ladingpage";
    } else if (interactionType == BUInteractionTypeVideoAdDetail) {
        str = @"videoDetail";
    } else {
        str = @"appstoreInApp";
    }
}

#pragma BUNativeExpressRewardedVideoAdDelegate
// 激励视频
- (void)loadRewardVideoAdWithSlotID:(NSString *)slotID {
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = @"13374";
    self.rewardedAd = [[BUNativeExpressRewardedVideoAd alloc] initWithSlotID:slotID rewardedVideoModel:model];
    self.rewardedAd.delegate = self;
    [self.rewardedAd loadAdData];
    //为保证播放流畅建议可在收到视频下载完成回调后再展示视频。
}
// 播放视频
- (void)showRewardVideoAd {
    if (self.rewardedAd) {
        [self.rewardedAd showAdFromRootViewController:self];
    }
}

- (void)nativeExpressRewardedVideoAdDidLoad:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [_webView evaluateJavaScript:@"javascript:window.onRewardError();" completionHandler:nil];
}

- (void)nativeExpressRewardedVideoAdCallback:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd withType:(BUNativeExpressRewardedVideoAdType)nativeExpressVideoType{
    
}

- (void)nativeExpressRewardedVideoAdDidDownLoadVideo:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdViewRenderSuccess:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdViewRenderFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    
}

- (void)nativeExpressRewardedVideoAdWillVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdDidVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdWillClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdDidClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdDidClick:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdDidClickSkip:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdDidPlayFinish:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    
}

- (void)nativeExpressRewardedVideoAdServerRewardDidSucceed:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    [_webView evaluateJavaScript:@"javascript:window.onRewardVerify();" completionHandler:nil];
}

- (void)nativeExpressRewardedVideoAdServerRewardDidFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError * _Nullable)error {
    
}

- (void)nativeExpressRewardedVideoAdDidCloseOtherController:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd interactionType:(BUInteractionType)interactionType {
    NSString *str = nil;
    if (interactionType == BUInteractionTypePage) {
        str = @"ladingpage";
    } else if (interactionType == BUInteractionTypeVideoAdDetail) {
        str = @"videoDetail";
    } else {
        str = @"appstoreInApp";
    }
    
}

#pragma mark - PopoverViewDelegate
- (void)didSelectedRowAtIndex:(NSInteger)index{
    
    if (index == 0) {
        // 刷新网页
        [_webView reload];
    } else if(index == 1){
        // 复制链接
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:_url];
        [self showAlert:@"复制成功"];
    } else if (index == 2) {
        // 清空缓存
        [self cleanCache];
        [_webView evaluateJavaScript:@"javascript:window.localStorage.clear()" completionHandler:nil];
    } else if (index == 3) {
        // 在浏览器打开
        NSURL *originalURL =[NSURL URLWithString:_url];
        [[UIApplication sharedApplication]openURL:originalURL options:@{} completionHandler:nil];
    }
}

// 清除webview缓存
- (void)cleanCache {
    if ([[[UIDevice currentDevice]systemVersion]intValue ] >= 9.0) {
        NSArray * types =@[WKWebsiteDataTypeMemoryCache,WKWebsiteDataTypeDiskCache]; // 9.0之后才有的
        NSSet *websiteDataTypes = [NSSet setWithArray:types];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            [self showAlert:@"清除缓存成功"];
        }];
    }else{
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSLog(@"%@", cookiesFolderPath);
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
        [self showAlert:@"清除缓存成功"];
    }
}

// 提示弹窗
- (IBAction)showAlert:(NSString *)msg {
    //显示提示框
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //响应事件
                                                              NSLog(@"action = %@", action);
                                                          }];
   
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
