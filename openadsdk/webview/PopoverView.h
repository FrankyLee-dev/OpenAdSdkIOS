//
//  PopoverView.h
//  openadsdk
//
//  Created by Franky Lee on 2020/9/7.
//  Copyright © 2020 Franky Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopoverViewDelegate;

@interface PopoverView : UIView

// 一般使用以下两个方法即可
-(id)initWithPoint:(CGPoint)point titles:(NSArray *)titles imageNames:(NSArray *)images;
-(void)show;

// 如下两个方法一般不会用到
-(void)dismiss;
-(void)dismiss:(BOOL)animated;

@property (nonatomic, assign) id<PopoverViewDelegate> delegate;

@end

@protocol PopoverViewDelegate <NSObject>

- (void)didSelectedRowAtIndex:(NSInteger)index;

@end
