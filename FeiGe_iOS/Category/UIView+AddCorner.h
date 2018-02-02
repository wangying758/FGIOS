//
//  UIView+AddCorner.h
//  FeiGe_iOS
//
//  Created by lensit on 2017/8/4.
//  Copyright © 2017年 lensit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CornerRadiusImageView : UIImageView



@end

@interface UIView (AddCorner)

/**
 *高效的添加圆角，防止离屏渲染，会自动将之前的view的背景色设置成clearColor。
 */
-(void)addCornerWithRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor size:(CGSize)size;



@end
