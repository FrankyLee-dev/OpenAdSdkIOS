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
    [self setupNavigationItem];
    
    // Do any additional setup after loading the view.
    UIButton * splashButton = [UIButton buttonWithType:UIButtonTypeSystem];
    splashButton.frame=CGRectMake((UIScreen.mainScreen.bounds.size.width-140)/2, 100, 140, 30);
    splashButton.backgroundColor=[UIColor darkGrayColor];
    [splashButton setTitle:@"打开开屏广告"
            forState:UIControlStateNormal];
    [splashButton addTarget:self
            action:@selector(openIntegral)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:splashButton];
    
    
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

// 按钮点击响应事件
-(void)openIntegral{
    MsmWebViewController *msmWebController = [[MsmWebViewController alloc] init];
    [self.navigationController pushViewController:msmWebController animated:NO];
    
}

- (void)setupNavigationItem{
    self.title = @"demo test";
    self.view.backgroundColor = [UIColor whiteColor];
}


@end
