//
//  BaseNavigationController.m
//  FeiGe_iOS
//
//  Created by lensit on 2017/7/27.
//  Copyright © 2017年 lensit. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()<UINavigationControllerDelegate>

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //修改返回键的颜色
    self.navigationBar.tintColor = WhiteColor;
    self.popDelegate = self.interactivePopGestureRecognizer.delegate;
    self.delegate = self;
    
}

- (CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}


#pragma mark - 控制屏幕旋转方法
//是否支持旋转
- (BOOL)shouldAutorotate{
    
    return [[self.viewControllers lastObject]shouldAutorotate];
}

//支持屏幕旋转种类
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return [[self.viewControllers lastObject]supportedInterfaceOrientations];
}


-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    if (self.viewControllers.count) {
        viewController.hidesBottomBarWhenPushed = YES;
        self.tabBarController.tabBar.hidden = YES;
    }
    [super pushViewController:viewController animated:animated];
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated{
    
    if (self.viewControllers.count == 2) {
        self.hidesBottomBarWhenPushed = NO;
        self.tabBarController.tabBar.hidden = NO;
    }
    return [super popViewControllerAnimated:animated];
}

-(void)backAction
{
    [self popViewControllerAnimated:YES];
}

@end
