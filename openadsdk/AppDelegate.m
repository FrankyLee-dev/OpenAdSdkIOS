//
//  AppDelegate.m
//  openadsdk
//
//  Created by Franky Lee on 2020/9/1.
//  Copyright © 2020 Franky Lee. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BUDMacros.h"
#import <BUAdSDK/BUAdSDKManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if (self.window == nil) {
        UIWindow *keyWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [keyWindow makeKeyAndVisible];
        self.window = keyWindow;
        self.window.rootViewController = [self rootViewController];
    }

    // initialize AD SDK
    [self setupBUAdSDK];
    
    return YES;
}

- (UIViewController *)rootViewController {
    ViewController *mainViewController = [[ViewController alloc] init];
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    return navigationVC;
}

// 初始化SDK
- (void)setupBUAdSDK {
    //optional
    //GDPR 0 close privacy protection, 1 open privacy protection
    [BUAdSDKManager setGDPR:0];
    //optional
    //Coppa 0 adult, 1 child
    [BUAdSDKManager setCoppa:0];
        
    #if DEBUG
    // Whether to open log. default is none.
    [BUAdSDKManager setLoglevel:BUAdSDKLogLevelDebug];
    #endif
    //BUAdSDK requires iOS 9 and up
    [BUAdSDKManager setAppID:@"5068842"];

    [BUAdSDKManager setIsPaidApp:NO];
    
    [self loadBUSplashAd];
}

- (void)loadBUSplashAd
{
    CGRect frame = [UIScreen mainScreen].bounds;
    BUSplashAdView *splashView = [[BUSplashAdView alloc] initWithSlotID:@"887365528" frame:frame];
    // tolerateTimeout = CGFLOAT_MAX , The conversion time to milliseconds will be equal to 0
    splashView.tolerateTimeout = 1;
    splashView.delegate = self;
  
    CGFloat bottomViewHeight = 110;
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - bottomViewHeight, frame.size.width, bottomViewHeight)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    imageView.frame = CGRectMake(frame.size.width/2-50/2, 5, 50, 50);

    [imageView setContentMode:UIViewContentModeScaleToFill];
    UILabel *l1 = [[UILabel alloc] init];
    [l1 setFont:[UIFont systemFontOfSize:16]];
    [l1 setTextColor:[UIColor blackColor]];
    [l1 setText:@"—   买什么都省   —"];
    // 根据文本计算size，这里需要传入attributes
    CGSize sizeNew = [l1.text sizeWithAttributes:@{NSFontAttributeName:l1.font}];
    l1.frame = CGRectMake(frame.size.width/2-sizeNew.width/2, imageView.frame.origin.y+imageView.frame.size.height+5, sizeNew.width, sizeNew.height);
  
    UILabel *l2 = [[UILabel alloc] init];
    [l2 setFont:[UIFont systemFontOfSize:14]];
    [l2 setTextColor:[UIColor blackColor]];
    [l2 setText:@"好的生活 可以更省"];
    // 根据文本计算size，这里需要传入attributes
    CGSize sizeNew1 = [l2.text sizeWithAttributes:@{NSFontAttributeName:l2.font}];
    l2.frame = CGRectMake(frame.size.width/2-sizeNew1.width/2, l1.frame.origin.y+l1.frame.size.height+5, sizeNew1.width, sizeNew1.height);
  
    [bottomView addSubview:imageView];
    [bottomView addSubview:l1];
    [bottomView addSubview:l2];
  
    UIWindow *keyWindow = self.window;
    [splashView loadAdData];
    [splashView addSubview:bottomView];
    [keyWindow.rootViewController.view addSubview:splashView];
    splashView.rootViewController = keyWindow.rootViewController;
}

#pragma mark 启动屏广告

- (void)splashAdDidLoad:(BUSplashAdView *)splashAd {
    [self pbu_logWithSEL:_cmd msg:@"splashAdDidLoad--------"];
}

- (void)splashAdDidClose:(BUSplashAdView *)splashAd {
    [splashAd removeFromSuperview];
    [self pbu_logWithSEL:_cmd msg:@"splashAdDidClose-------"];
}

- (void)splashAdDidClick:(BUSplashAdView *)splashAd {
    [splashAd removeFromSuperview];
    [self pbu_logWithSEL:_cmd msg:@"splashAdDidClick----"];
}

- (void)splashAdDidClickSkip:(BUSplashAdView *)splashAd {
    [splashAd removeFromSuperview];
    [self pbu_logWithSEL:_cmd msg:@"splashAdDidClickSkip-----"];
}

- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError *)error {
    [splashAd removeFromSuperview];
    [self pbu_logWithSEL:_cmd msg:@"didFailWithError-----"];
}

- (void)splashAdWillVisible:(BUSplashAdView *)splashAd {
    [self pbu_logWithSEL:_cmd msg:@"splashAdWillVisible-------"];
}

- (void)splashAdWillClose:(BUSplashAdView *)splashAd {
    [self pbu_logWithSEL:_cmd msg:@"splashAdWillClose----------"];
}

- (void)splashAdDidCloseOtherController:(BUSplashAdView *)splashAd interactionType:(BUInteractionType)interactionType {
    [self pbu_logWithSEL:_cmd msg:@"splashAdDidCloseOtherController--------"];
}



- (void)splashAdCountdownToZero:(BUSplashAdView *)splashAd {
    [self pbu_logWithSEL:_cmd msg:@"splashAdCountdownToZero-----"];
}

- (void)pbu_logWithSEL:(SEL)sel msg:(NSString *)msg {
    BUD_Log(@"SDKDemoDelegate BUSplashAdView In VC (%@) extraMsg:%@", NSStringFromSelector(sel), msg);
}

@end
