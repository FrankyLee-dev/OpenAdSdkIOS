//
//  BUDExpressBannerViewController.m
//  BUDemo
//
//  Created by xxx on 2019/5/15.
//  Copyright © 2019 bytedance. All rights reserved.
//

#import "BUDExpressBannerViewController.h"
#import <BUAdSDK/BUNativeExpressBannerView.h>
#import <BUAdSDK/BUAdSDK.h>

@interface BUDExpressBannerViewController ()<BUNativeExpressBannerViewDelegate>

@property(nonatomic, strong) BUNativeExpressBannerView *bannerView;

@end

@implementation BUDExpressBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton * splashButton = [UIButton buttonWithType:UIButtonTypeSystem];
    splashButton.frame=CGRectMake((UIScreen.mainScreen.bounds.size.width-140)/2, 100, 140, 30);
    splashButton.backgroundColor=[UIColor darkGrayColor];
    [splashButton setTitle:@"打开Banner广告"
            forState:UIControlStateNormal];
    [splashButton addTarget:self
            action:@selector(showBanner)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:splashButton];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame=CGRectMake((UIScreen.mainScreen.bounds.size.width-140)/2, 200, 140, 30);
    button.backgroundColor=[UIColor darkGrayColor];
    [button setTitle:@"加载banner广告"
            forState:UIControlStateNormal];
    [button addTarget:self
            action:@selector(loadBannerAd)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

/***important:
 广告加载成功的时候，会立即渲染WKWebView。
 如果想预加载的话，建议一次最多预加载三个广告，如果超过3个会很大概率导致WKWebview渲染失败。
 */
- (void)loadBannerWithSlotID:(NSString *)slotID {
    [self.bannerView removeFromSuperview];
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 40;
    CGFloat bannerHeigh = screenWidth/600*300;
    self.bannerView = [[BUNativeExpressBannerView alloc] initWithSlotID:slotID rootViewController:self adSize:CGSizeMake(screenWidth, bannerHeigh) IsSupportDeepLink:YES interval:30];
    self.bannerView.frame = CGRectMake(0, 400, screenWidth, bannerHeigh);
    self.bannerView.delegate = self;
    [self.bannerView loadAdData];
    
}

- (void)loadBannerAd {
    [self loadBannerWithSlotID:@"945413865"];
}

- (void)showBanner {
    [self.view addSubview:self.bannerView];
}

#pragma BUNativeExpressBannerViewDelegate
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%@",@"nativeExpressBannerAdViewDidLoad-----");
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    NSLog(@"%@",[NSString stringWithFormat:@"error:%@", error]);
}

- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%@",@"nativeExpressBannerAdViewRenderSuccess------");
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError *)error {
    NSLog(@"%@",[NSString stringWithFormat:@"error:%@", error]);
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%@",@"nativeExpressBannerAdViewWillBecomVisible------");
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%@",@"nativeExpressBannerAdViewDidClick------");
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterwords {
    [UIView animateWithDuration:0.25 animations:^{
        bannerAdView.alpha = 0;
    } completion:^(BOOL finished) {
        [bannerAdView removeFromSuperview];
        self.bannerView = nil;
    }];
    NSLog(@"%@",@"nativeExpressBannerAdView------");
}

- (void)nativeExpressBannerAdViewDidCloseOtherController:(BUNativeExpressBannerView *)bannerAdView interactionType:(BUInteractionType)interactionType {
    NSString *str = nil;
    if (interactionType == BUInteractionTypePage) {
        str = @"ladingpage";
    } else if (interactionType == BUInteractionTypeVideoAdDetail) {
        str = @"videoDetail";
    } else {
        str = @"appstoreInApp";
    }
    NSLog(@"%@",str);
}

@end
