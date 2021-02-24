//
//  AdnetNative.m
//  MsmdsApp
//
//  Created by Franky Lee on 2021/2/1.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "AdnetNative.h"

@implementation AdnetNative

/**
 * 拉取广告成功的回调
 */
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(adNetNativeExpressAdSuccessToLoad:views:)]) {
      [self.delegate adNetNativeExpressAdSuccessToLoad:nativeExpressAd views:views];
  }
}

/**
 * 拉取广告失败的回调
 */
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(adNetNativeExpressAdFailToLoad:error:)]) {
      [self.delegate adNetNativeExpressAdFailToLoad:nativeExpressAd error:error];
  }
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(adNetNativeExpressAdViewRenderSuccess:)]) {
      [self.delegate adNetNativeExpressAdViewRenderSuccess:nativeExpressAdView];
  }
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(adNetNativeExpressAdViewClicked:)]) {
      [self.delegate adNetNativeExpressAdViewClicked:nativeExpressAdView];
  }
}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(adNetNativeExpressAdViewClosed:)]) {
      [self.delegate adNetNativeExpressAdViewClosed:nativeExpressAdView];
  }
}

- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(adNetNativeExpressAdViewExposure:)]) {
      [self.delegate adNetNativeExpressAdViewExposure:nativeExpressAdView];
  }
}

- (void)nativeExpressAdViewWillPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(adNetNativeExpressAdViewWillPresentScreen:)]) {
      [self.delegate adNetNativeExpressAdViewWillPresentScreen:nativeExpressAdView];
  }
}

- (void)nativeExpressAdViewDidPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(adNetNativeExpressAdViewDidPresentScreen:)]) {
      [self.delegate adNetNativeExpressAdViewDidPresentScreen:nativeExpressAdView];
  }
}

- (void)nativeExpressAdViewWillDismissScreen:(GDTNativeExpressAdView *)nativeExpressAdView
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(adNetNativeExpressAdViewWillDismissScreen:)]) {
      [self.delegate adNetNativeExpressAdViewWillDismissScreen:nativeExpressAdView];
  }
}

- (void)nativeExpressAdViewDidDismissScreen:(GDTNativeExpressAdView *)nativeExpressAdView
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(adNetNativeExpressAdViewDidDismissScreen:)]) {
      [self.delegate adNetNativeExpressAdViewDidDismissScreen:nativeExpressAdView];
  }
}

/**
 * 详解:当点击应用下载或者广告调用系统程序打开时调用
 */
- (void)nativeExpressAdViewApplicationWillEnterBackground:(GDTNativeExpressAdView *)nativeExpressAdView
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(adNetNativeExpressAdViewApplicationWillEnterBackground:)]) {
      [self.delegate adNetNativeExpressAdViewApplicationWillEnterBackground:nativeExpressAdView];
  }
}

@end
