//
//  UIView+Extension.h
//  01-黑酷
//
//  Created by apple on 14-6-27.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (Extension)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@property (nullable, nonatomic, readonly) UIViewController *viewController;


/**
 *  9.上 < Shortcut for frame.origin.y
 */
@property (nonatomic) CGFloat top;

/**
 *  10.下 < Shortcut for frame.origin.y + frame.size.height
 */
@property (nonatomic) CGFloat bottom;

/**
 *  11.左 < Shortcut for frame.origin.x.
 */
@property (nonatomic) CGFloat left;

/**
 *  12.右 < Shortcut for frame.origin.x + frame.size.width
 */
@property (nonatomic) CGFloat right;

- (void)addTarget:(id _Nullable)target action:(SEL _Nullable )action;

- (UIImage * _Nullable )snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

- (UIImage * _Nullable )snapshotImage;

- (UITapGestureRecognizer * _Nullable)addTapGestureRecognizer:(SEL _Nullable)action;

- (UITapGestureRecognizer * _Nullable)addTapGestureRecognizer:(SEL _Nullable)action target:(id _Nullable)target;

- (UILongPressGestureRecognizer * _Nullable)addLongPressGestureRecognizer:(SEL _Nullable)action duration:(CGFloat)duration;

- (UILongPressGestureRecognizer * _Nullable)addLongPressGestureRecognizer:(SEL _Nullable)action target:(id _Nullable)target duration:(CGFloat)duration;
@end
