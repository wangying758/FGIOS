//
//  UIView+AddCorner.m
//  FeiGe_iOS
//
//  Created by lensit on 2017/8/4.
//  Copyright © 2017年 lensit. All rights reserved.
//

#import "UIView+AddCorner.h"
#import "UIImage+ImageRoundedCorner.h"

@implementation CornerRadiusImageView

-(instancetype)initWithImage:(UIImage *)image
{
    if (self = [super initWithImage:image]) {
        
    }
    return self;
}

@end

@implementation UIView (AddCorner)

/**
 *高效的添加圆角，防止离屏渲染，会自动将之前的view的背景色设置成clearColor。
 */
-(void)addCornerWithRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor size:(CGSize)size
{
    self.backgroundColor = ClearColor;
    UIImage * image = [UIImage imageWithRoundedCornerRadius:radius borderWidth:borderWidth backgroundColor:backgroundColor borderColor:borderColor size:size];
    CornerRadiusImageView * imageView = [[CornerRadiusImageView alloc]initWithImage:image];
    UIView * topView = [self.subviews objectAtIndex:0];
    if ([topView isKindOfClass:[CornerRadiusImageView class]]) {
        [topView removeFromSuperview];
    }
    [self insertSubview:imageView atIndex:0];
}



@end
