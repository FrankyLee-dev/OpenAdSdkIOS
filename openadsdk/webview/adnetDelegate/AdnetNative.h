//
//  AdnetNative.h
//  MsmdsApp
//
//  Created by Franky Lee on 2021/2/1.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GDTNativeExpressAd.h>
#import <GDTNativeExpressAdView.h>

NS_ASSUME_NONNULL_BEGIN
@protocol AdnetNativeDelegate <NSObject>

@optional
/**
 * 拉取原生模板广告成功
 */
- (void)adNetNativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views;

/**
 * 拉取原生模板广告失败
 */
- (void)adNetNativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error;

/**
 * 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
 */
- (void)adNetNativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView;

/**
 * 原生模板广告渲染失败
 */
- (void)adNetNativeExpressAdViewRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView;

/**
 * 原生模板广告曝光回调
 */
- (void)adNetNativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView;

/**
 * 原生模板广告点击回调
 */
- (void)adNetNativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView;

/**
 * 原生模板广告被关闭
 */
- (void)adNetNativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView;

/**
 * 点击原生模板广告以后即将弹出全屏广告页
 */
- (void)adNetNativeExpressAdViewWillPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView;

/**
 * 点击原生模板广告以后弹出全屏广告页
 */
- (void)adNetNativeExpressAdViewDidPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView;

/**
 * 全屏广告页将要关闭
 */
- (void)adNetNativeExpressAdViewWillDismissScreen:(GDTNativeExpressAdView *)nativeExpressAdView;

/**
 * 全屏广告页将要关闭
 */
- (void)adNetNativeExpressAdViewDidDismissScreen:(GDTNativeExpressAdView *)nativeExpressAdView;

/**
 * 详解:当点击应用下载或者广告调用系统程序打开时调用
 */
- (void)adNetNativeExpressAdViewApplicationWillEnterBackground:(GDTNativeExpressAdView *)nativeExpressAdView;

/**
 * 原生模板视频广告 player 播放状态更新回调
 */
- (void)adNetNativeExpressAdView:(GDTNativeExpressAdView *)nativeExpressAdView playerStatusChanged:(GDTMediaPlayerStatus)status;

/**
 * 原生视频模板详情页 WillPresent 回调
 */
- (void)adNetNativeExpressAdViewWillPresentVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView;

/**
 * 原生视频模板详情页 DidPresent 回调
 */
- (void)adNetNativeExpressAdViewDidPresentVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView;

/**
 * 原生视频模板详情页 WillDismiss 回调
 */
- (void)adNetNativeExpressAdViewWillDismissVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView;

/**
 * 原生视频模板详情页 DidDismiss 回调
 */
- (void)adNetNativeExpressAdViewDidDismissVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView;

@end

@interface AdnetNative : NSObject<GDTNativeExpressAdDelegete>

@property (nonatomic, weak) id<AdnetNativeDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
