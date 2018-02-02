//
//  NSString+Extension.h
//  WeChat
//
//  Created by zhengwenming on 2017/9/21.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IMTimeType) {
    IMTimeTypeMessageUI  = 0,
    IMTimeTypeChatUI  = 1
};

@interface NSString (Extension)
/**
 * 计算文字高度，可以处理计算带行间距的等属性
 */
- (CGSize)boundingRectWithSize:(CGSize)size paragraphStyle:(NSMutableParagraphStyle *)paragraphStyle font:(UIFont*)font;
/**
 * 计算文字高度，可以处理计算带行间距的
 */
- (CGSize)boundingRectWithSize:(CGSize)size font:(UIFont*)font  lineSpacing:(CGFloat)lineSpacing;
/**
 * 计算最大行数文字高度，可以处理计算带行间距的
 */
- (CGFloat)boundingRectWithSize:(CGSize)size font:(UIFont*)font  lineSpacing:(CGFloat)lineSpacing maxLines:(NSInteger)maxLines;

/**
 *  计算是否超过一行
 */
- (BOOL)isMoreThanOneLineWithSize:(CGSize)size font:(UIFont *)font lineSpaceing:(CGFloat)lineSpacing;


/**
 *  1970年以来的毫秒数转化成聊天时间
 *
 *  @param type IMTimeTypeMessageUI 消息界面时间,
 IMTimeTypeChatUI    聊天界面时间
 *
 *  @return 时间字符串
 */
- (NSString *)translateToIMTimeWithType:(IMTimeType)type;

@end
