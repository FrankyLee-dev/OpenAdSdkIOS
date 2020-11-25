# 买什么都省H5展示穿山甲原生广告方法

# 下面方法属于参考内容，只要使用和H5暴露出来的方法名称一致即可

## 步骤1：使用WKWebView承接H5页面，在构造webView对象时注册js方法 ##
```
WKUserContentController * wkUController = [[WKUserContentController alloc] init];

// 加载banner广告
[wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"showToutiaoBannerAd"];
// 关闭banner广告
[wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"dismissToutiaoBannerAd"];
        
// 加载信息流广告
[wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"showToutiaoNativeAd"];
// 关闭信息流广告
[wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"dismissToutiaoNativeAd"];

 // 加载激励视频广告       
[wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"loadToutiaoRewardVideoAd"];
 // 播放激励视频广告
[wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"playToutiaoRewardVideoAd"];
        
config.userContentController = wkUController;
```

## 步骤2：通过接收JS传出消息的name进行捕捉的回调方法 ##
```
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
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
                // 加载banner广告
                [self loadData:top:left:width:height];
            }
        }else if([message.name isEqualToString:@"dismissToutiaoBannerAd"]){
            // 移除banner广告
            [self.bannerView removeFromSuperview];
        } else if ([message.name isEqualToString:@"showToutiaoNativeAd"]) {
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
            // 移除信息流广告
            BUNativeExpressAdView *expressAdView = [self.expressAdViews firstObject];
            [expressAdView removeFromSuperview];
            [self.expressAdViews removeAllObjects];

        } else if ([message.name isEqualToString:@"loadToutiaoRewardVideoAd"]) {
            // 加载激励视频
            [self loadRewardVideoAdWithSlotID:_rewardVideoCodeId];
        } else if ([message.name isEqualToString:@"playToutiaoRewardVideoAd"]) {
            // 播放激励视频
            [self showRewardVideoAd];
        }
    } @catch (NSException *exception) {
        NSLog(@"NSException%@",exception);
    } @finally {
        NSLog(@"@finally%@",@"");
    }
    
}
```

## 步骤3：广告回调方法处理 ## 

**banner广告回调方法**    

*可以在banner广告加载时设置好H5传递过来的位置*
*onError,banner广告加载失败的回调*
```
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
```

*onError,banner广告加载失败的回调*
```
- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    NSLog(@"%s",__func__);
    // 告知h5广告加载失败
    [_webView evaluateJavaScript:@"javascript:window.BannerLoadError();" completionHandler:nil];
}
```

*banner广告渲染成功的回调*
```
- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__func__);
    CGFloat height = bannerAdView.bounds.size.height;
    [self.webView.scrollView addSubview:self.bannerView];
    NSString *jsStr = [NSString stringWithFormat:@"javascript:window.BannerLoadSuccess({height:%g});",height];
    [_webView evaluateJavaScript:jsStr completionHandler:nil];
}
```

*用户主动关闭广告回调，dislike*
```
- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterwords {
    NSLog(@"%s",__func__);
    // 告知h5用户关闭了广告
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
```


**激励视频广告回调方法**  

*激励视频广告加载失败的回调*
```
- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [_webView evaluateJavaScript:@"javascript:window.onRewardError();" completionHandler:nil];
}
```

*激励视频广告播放完成的回调，这里现在没有服务器检查* 
```
- (void)nativeExpressRewardedVideoAdServerRewardDidSucceed:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    [_webView evaluateJavaScript:@"javascript:window.onRewardVerify();" completionHandler:nil];
}
```

**信息流广告回调方法**  

*信息流广告加载失败的回调*    
```
- (void)nativeExpressAdFailToLoad:(BUNativeExpressAdManager *)nativeExpressAd error:(NSError *)error {
    [_webView evaluateJavaScript:@"javascript:window.NativeError();" completionHandler:nil];
}
```

*信息流广告渲染成功的回调*  
```
- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView {
    CGFloat marginTop = [self.nativeTop floatValue];
    CGFloat marginLeft = [self.nativeLeft floatValue];
    nativeExpressAdView.frame = CGRectMake(marginLeft, marginTop, nativeExpressAdView.bounds.size.width, nativeExpressAdView.bounds.size.height);
    [self.webView.scrollView addSubview:nativeExpressAdView];
    [_webView evaluateJavaScript:@"javascript:window.NativeRenderSuccess();" completionHandler:nil];
}
```

*用户主动关闭广告回调，dislike*
```
- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {//【重要】需要在点击叉以后 在这个回调中移除视图，否则，会出现用户点击叉无效的情况
    [nativeExpressAdView removeFromSuperview];
    [self.expressAdViews removeAllObjects];
    [_webView evaluateJavaScript:@"javascript:window.NativeShield();" completionHandler:nil];
}
```

## 步骤3：移除监听方法 ##
```
- (void)dealloc{
    //移除注册的js方法
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"showToutiaoBannerAd"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"dismissToutiaoBannerAd"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"showToutiaoNativeAd"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"dismissToutiaoNativeAd"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"loadToutiaoRewardVideoAd"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"playToutiaoRewardVideoAd"];
}
```
