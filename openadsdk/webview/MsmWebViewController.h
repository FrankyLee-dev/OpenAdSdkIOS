//
//  MsmWebViewController.h
//  openadsdk
//
//  Created by Franky Lee on 2020/9/1.
//  Copyright © 2020 Franky Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MsmWebViewController : UIViewController

@property (copy,nonatomic) NSString *url;

@property (nonatomic, assign) BOOL showToolbar;

@property (copy,nonatomic) NSString *bannerCodeId;

@property (copy,nonatomic) NSString *nativeCodeId;

@property (copy,nonatomic) NSString *rewardVideoCodeId;

@end

NS_ASSUME_NONNULL_END
