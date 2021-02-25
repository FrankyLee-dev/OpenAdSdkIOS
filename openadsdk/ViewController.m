//
//  ViewController.m
//  openadsdk
//
//  Created by Franky Lee on 2020/9/1.
//  Copyright © 2020 Franky Lee. All rights reserved.
//

#import "ViewController.h"
#import "MsmWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setView];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame=CGRectMake((UIScreen.mainScreen.bounds.size.width-140)/2, 200, 140, 30);
    button.backgroundColor=[UIColor darkGrayColor];
    [button setTitle:@"打开签到页"
            forState:UIControlStateNormal];
    [button addTarget:self
            action:@selector(openIntegral)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

// 打开签到页
-(void)openIntegral{
    // http://192.168.31.222:8080/newSign
    // https://wxapp.msmds.cn/h5/react_web/newSign
    MsmWebViewController *msmWebController = [MsmWebViewController new];
    msmWebController.url = @"https://test.msmds.cn/h5/react_web/channel/newSign";
    msmWebController.showToolbar = YES;
    [self.navigationController pushViewController:msmWebController animated:YES];
    
}

- (void)setView {
    [self.navigationController.navigationBar setTranslucent:YES];
    self.view.backgroundColor = [UIColor whiteColor];
}


@end
