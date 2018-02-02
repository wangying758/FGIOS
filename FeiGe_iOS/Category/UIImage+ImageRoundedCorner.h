//
//  UIImage+ImageRoundedCorner.h
//  CornerRadius
//
//  Created by 张星宇 on 16/3/3.
//  Copyright © 2016年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageRoundedCorner)

-(UIImage*)imageWithRoundedCornerRadius:(CGFloat)radius andSize:(CGSize)size;

+(UIImage *)imageWithRoundedCornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth backgroundColor:(UIColor*)backgroundColor borderColor:(UIColor*)borderColor size:(CGSize)size;

-(UIImage*)imageWithRoundedCornerRadius:(CGFloat)radius andSize:(CGSize)size andBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;

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
+ (UIImage *)imageWithImage:(UIImage *)image
                  imageSize:(CGSize)imageSize
                borderWidth:(CGFloat)borderWidth
                borderColor:(UIColor *)borderColor;

@end
