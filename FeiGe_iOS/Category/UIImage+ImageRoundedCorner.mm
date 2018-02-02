//
//  UIImage+ImageRoundedCorner.m
//  CornerRadius
//
//  Created by 张星宇 on 16/3/3.
//  Copyright © 2016年 zxy. All rights reserved.
//

#import "UIImage+ImageRoundedCorner.h"

@implementation UIImage (ImageRoundedCorner)

/**
 * 给图片添加圆角
 */
-(UIImage*)imageWithRoundedCornerRadius:(CGFloat)radius andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextAddPath(UIGraphicsGetCurrentContext(),
                     [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    
    [self drawInRect:rect];
    CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage*)imageWithRoundedCornerRadius:(CGFloat)radius andSize:(CGSize)size andBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextSetLineWidth(ctx, borderWidth);
    CGContextSetStrokeColorWithColor(ctx, borderColor.CGColor);
    CGContextAddPath(ctx,path.CGPath);
    CGContextClip(ctx);
    [self drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 * 根据参数获得一张图片
 */
+(UIImage *)imageWithRoundedCornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth backgroundColor:(UIColor*)backgroundColor borderColor:(UIColor*)borderColor size:(CGSize)size
{
    CGFloat halfBorderWidth = (borderWidth / 2.0);
    
    UIGraphicsBeginImageContextWithOptions(size, false, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, borderWidth);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    
    CGFloat width = size.width, height = size.height;
    CGContextMoveToPoint(context, width - halfBorderWidth, radius + halfBorderWidth);  // 开始坐标右边开始
    CGContextAddArcToPoint(context, width - halfBorderWidth, height - halfBorderWidth, width - radius - halfBorderWidth, height - halfBorderWidth, radius);  // 右下角角度
    CGContextAddArcToPoint(context, halfBorderWidth, height - halfBorderWidth, halfBorderWidth, height - radius - halfBorderWidth, radius); // 左下角角度
    CGContextAddArcToPoint(context, halfBorderWidth, halfBorderWidth, width - halfBorderWidth, halfBorderWidth, radius); // 左上角
    CGContextAddArcToPoint(context, width - halfBorderWidth, halfBorderWidth, width - halfBorderWidth, radius + halfBorderWidth, radius); // 右上角
    CGContextDrawPath(context, kCGPathFillStroke);
    //CGContextDrawPath(UIGraphicsGetCurrentContext(), .FillStroke);
    UIImage *  output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

/**
 *  带边框的图片
 *
 *  @param image   图片名
 *  @param imageSize  图片size
 *  @param borderWidth 边框宽度
 *  @param borderColor 边框颜色
 *
 *  @return 带边框的图片
 */
+ (UIImage *)imageWithImage:(UIImage *)image imageSize:(CGSize)imageSize borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    CGSize size = CGSizeMake(imageSize.width + 2 * borderWidth, imageSize.height + 2 * borderWidth);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:borderWidth];
    [borderColor set];
    [path fill];
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(borderWidth, borderWidth, imageSize.width, imageSize.height) cornerRadius:borderWidth];
    [path addClip];
    [path stroke];
    [image drawInRect:CGRectMake(borderWidth, borderWidth, imageSize.width, imageSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
