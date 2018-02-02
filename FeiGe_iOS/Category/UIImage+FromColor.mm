//
//  UIImage+FromColor.m
//  ElectronicCar
//
//  Created by 曾照成 on 17/5/6.
//  Copyright © 2017年 易通星云. All rights reserved.
//

#import "UIImage+FromColor.h"

@implementation UIImage (FromColor)

//颜色生成图片
+(UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
