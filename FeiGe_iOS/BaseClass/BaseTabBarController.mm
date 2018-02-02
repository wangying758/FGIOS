//
//  BaseTabBarController.m
//  FeiGe_iOS
//
//  Created by lensit on 2017/7/27.
//  Copyright © 2017年 lensit. All rights reserved.
//

#import "BaseTabBarController.h"
#import "MessageListViewController.h"
#import "ContactViewController.h"
#import "WorkCenterViewController.h"
#import "SelfCenterViewController.h"
#import "SettingViewController.h"
#import <WZLBadge/WZLBadgeImport.h>


#define BXDangerousAreaH 34

#define kTabbarHeight ([UIScreen mainScreen].bounds.size.height == 812 ? (BXDangerousAreaH + 49) : 49)

@interface BaseTabBarController ()<UITabBarControllerDelegate, UINavigationControllerDelegate, BXTabBarDelegate>

@property (nonatomic, assign) NSInteger lastSelectIndex;
@property (nonatomic, strong) UIView *redPoint;
/** view */


@property (nonatomic, strong) id popDelegate;
/** 保存所有控制器对应按钮的内容（UITabBarItem）*/
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation BaseTabBarController

#pragma mark view life style

+ (void)initialize {
    // 设置tabbarItem的普通文字
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = RGB(113, 109, 104);
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:10];

    //设置tabBarItem的选中文字颜色
    NSMutableDictionary *selectedTextAttrs = [NSMutableDictionary dictionary];
    selectedTextAttrs[NSForegroundColorAttributeName] = RGB(51, 135, 255);
    
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [item setTitleTextAttributes:selectedTextAttrs forState:UIControlStateSelected];
    
}

- (NSMutableArray *)items {
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBar.hidden = NO;
    self.tabBar.hidden = YES;
    // 把系统的tabBar上的按钮干掉
    [self.tabBar removeFromSuperview];
    // 把系统的tabBar上的按钮干掉
    for (UIView *childView in self.tabBar.subviews) {
        if (![childView isKindOfClass:[LSTabBar class]]) {
            [childView removeFromSuperview];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    
    // 添加所有子控制器
    [self addAllChildVc];
    
    // 自定义tabBar
    [self setUpTabBar];
    
}

#pragma mark - 自定义tabBar
- (void)setUpTabBar {
    LSTabBar *tabBar = [[LSTabBar alloc] init];
    // 存储UITabBarItem
    tabBar.items = self.items;
    
    tabBar.delegate = self;
    
    if (iPhoneX) {
        tabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tab_backgroundX"]];
    } else {
        tabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tab_background"]];
    }
    //    tabBar.frame = self.tabBar.frame;
    tabBar.frame = CGRectMake(0, KDeviceHeight - kTabbarHeight, KDeviceWidth, kTabbarHeight);
    [self.view addSubview:tabBar];
    self.mytabbar = tabBar;
}

/**
 *  添加所有的子控制器
 */
- (void)addAllChildVc {
    
    // 添加初始化子控制器 BXHomeViewController
    MessageListViewController *home = [MessageListViewController customInit];
    [self addOneChildVC:home title:@"消息" imageName:@"tabbar_message_normal" selectedImageName:@"tabbar_message_select"];
    
    ContactViewController *customer = [ContactViewController customInit];
    [self addOneChildVC:customer title:@"通讯录" imageName:@"tabbar_contact_normal" selectedImageName:@"tabbar_contact_select"];
    
    WorkCenterViewController *insurance = [WorkCenterViewController customInit];
    [self addOneChildVC:insurance title:@"工作中心" imageName:@"tab_camera" selectedImageName:@"tab_camera"];
    
    SelfCenterViewController *compare = [SelfCenterViewController customInit];
    [self addOneChildVC:compare title:@"个人中心" imageName:@"tabbar_selfcenter_normal" selectedImageName:@"tabbar_selfcenter_select"];
    
    SettingViewController *profile = [SettingViewController customInit];
    [self addOneChildVC:profile title:@"设置" imageName:@"tabbar_set_normal" selectedImageName:@"tabbar_set_select"];
}


/**
 *  添加一个自控制器
 *
 *  @param childVc           子控制器对象
 *  @param title             标题
 *  @param imageName         图标
 *  @param selectedImageName 选中时的图标
 */

- (void)addOneChildVC:(UIViewController *)childVc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName {
    // 设置标题
    childVc.tabBarItem.title = title;
    
    // 设置图标
    childVc.tabBarItem.image = [UIImage imageNamed:imageName];
    
    // 设置选中的图标
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    // 不要渲染
    selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.selectedImage = selectedImage;
    
    // 记录所有控制器对应按钮的内容
    [self.items addObject:childVc.tabBarItem];
    
    // 添加为tabbar控制器的子控制器
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:childVc];
    
    nav.delegate = self;
    [self addChildViewController:nav];
}

#pragma mark - BXTabBarDelegate方法
// 监听tabBar上按钮的点击
- (void)tabBar:(LSTabBar *)tabBar didClickBtn:(NSInteger)index
{
    [super setSelectedIndex:index];
}

/**
 *  让myTabBar选中对应的按钮
 */
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    // 通过mytabbar的通知处理页面切换
    self.mytabbar.seletedIndex = selectedIndex;
}


#pragma mark navVC代理
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    UIViewController *root = navigationController.viewControllers.firstObject;
    self.tabBar.hidden = YES;
    if (viewController != root) {
        //从HomeViewController移除
        [self.mytabbar removeFromSuperview];
        // 调整tabbar的Y值
        CGRect dockFrame = self.mytabbar.frame;
        dockFrame.origin.y = root.view.frame.size.height - kTabbarHeight;
        
        if ([root.view isKindOfClass:[UIScrollView class]]) { // 根控制器的view是能滚动
            UIScrollView *scrollview = (UIScrollView *)root.view;
            dockFrame.origin.y += scrollview.contentOffset.y;
        }
        self.mytabbar.frame = dockFrame;
        // 添加dock到根控制器界面
        [root.view addSubview:self.mytabbar];
    }
}

// 完全展示完调用
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    UIViewController *root = navigationController.viewControllers.firstObject;
    BaseNavigationController *nav = (BaseNavigationController *)navigationController;
    if (viewController == root) {
        navigationController.interactivePopGestureRecognizer.delegate = nav.popDelegate;
        // 让Dock从root上移除
        [_mytabbar removeFromSuperview];
        //_mytabbar添加dock到HomeViewController
        _mytabbar.frame = CGRectMake(0, KDeviceHeight - kTabbarHeight, KDeviceWidth, kTabbarHeight);
        [self.view addSubview:_mytabbar];
    }
}

@end
