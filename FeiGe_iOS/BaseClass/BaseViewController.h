//
//  BaseViewController.h
//  FeiGe_iOS
//
//  Created by lensit on 2017/7/27.
//  Copyright © 2017年 lensit. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BaseViewController : UIViewController

//自定义初始化方法
+(id)customInit;

//设置导航栏标题(默认白色)
-(void)setVCTitle:(NSString *)title;

//设置导航栏标题(指定颜色)
-(void)setVCTitle:(NSString *)title textColor:(UIColor *)textColor;

//字体大小发生改变
-(void)fontChange;

/**
 获取storyboard中的控制器
 
 @param storyboardName storyboard的名字
 @param vcId 控制器storyboardID
 @return 控制器
 */
+ (UIViewController *)getVCWithStoryboard:(NSString *)storyboardName viewControllerId:(NSString *)vcId;

@end
