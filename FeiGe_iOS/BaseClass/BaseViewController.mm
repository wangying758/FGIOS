//
//  BaseViewController.m
//  FeiGe_iOS
//
//  Created by lensit on 2017/7/27.
//  Copyright © 2017年 lensit. All rights reserved.
//

#import "BaseViewController.h"
#import "UIImage+FromColor.h"


@interface BaseViewController ()

@end

@implementation BaseViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = WhiteColor;;
    [self.navigationController.navigationBar lt_setBackgroundColor:NavBarColor];
    if (@available(iOS 11.0, *)) {
//   [self.navigationItem.searchController.searchBar setBackgroundImage:[UIImage createImageWithColor:NavBarColor] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefaultPrompt];
        
    } else {
        // Fallback on earlier versions
    }
    //状态栏设置成白色(info.plist文件中需要添加UIViewControllerBasedStatusBarAppearance = NO)
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //隐藏（去除）导航栏底部横线
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
//    // bg.png为自己ps出来的想要的背景颜色。
//    [navigationBar setBackgroundImage:[UIImage createImageWithColor:NavBarColor]
//                       forBarPosition:UIBarPositionTop
//                           barMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];

}

-(void)dealloc
{
    NSLog(@"%@销毁啦~~~~~~",[self class]);
}

#pragma mark - Public Method

/**
 * 自定义初始化方法
 */
+(id)customInit
{
    Class VClass = [self class];
    id viewCtr = nil;
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@", NSStringFromClass(VClass)] ofType:@"nib"];
    if([file_manager fileExistsAtPath:path]) //
    {
        viewCtr = [[VClass alloc] initWithNibName:[NSString stringWithFormat:@"%@", NSStringFromClass(VClass)] bundle:nil];
    }
    else
    {
        viewCtr = [[VClass alloc] init];
    }
    return viewCtr;
}



/**
 获取storyboard中的控制器

 @param storyboardName storyboard的名字
 @param vcId 控制器storyboardID
 @return 控制器
 */
+ (UIViewController *)getVCWithStoryboard:(NSString *)storyboardName viewControllerId:(NSString *)vcId {
    UIStoryboard *SB = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *targetVC = [SB instantiateViewControllerWithIdentifier:vcId];
    
    return targetVC;
}

/**
 * 设置导航栏标题
 */
-(void)setVCTitle:(NSString *)title{
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 166, 24)];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:WhiteColor];
    [label setFont:[UIFont systemFontOfSize:17]];
    self.navigationItem.titleView = label;
    
}

/**
 * 设置导航栏标题、文字颜色
 */
-(void)setVCTitle:(NSString *)title textColor:(UIColor *)textColor{
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 166, 24)];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:textColor];
    [label setFont:[UIFont systemFontOfSize:17]];
    self.navigationItem.titleView = label;
}

/**
 * 字体大小发生改变
 */
-(void)fontChange
{
    
}

#pragma mark - 控制屏幕旋转方法
//是否自动旋转,返回YES可以自动旋转,返回NO禁止旋转
- (BOOL)shouldAutorotate{
    
    return NO;
}

//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}

//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationPortrait;
}


@end
