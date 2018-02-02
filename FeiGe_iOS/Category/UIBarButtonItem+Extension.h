//
//  UIBarButtonItem+Extension.h
//  美团
//
//  Created by apple on 15/8/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Extension)

//图片转UIBarButtonItem
+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(UIImage *)image highImage:(UIImage *)highImage;

@end
