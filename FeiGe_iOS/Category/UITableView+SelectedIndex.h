//
//  UITableView+SelectedIndex.h
//  MeiyeCommon
//
//  Created by Lisai on 2017/10/23.
//  Copyright © 2017年 yunhuachen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (SelectedIndex)

//select indexpath
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;  ///< 选中的indexpath

//preselect indexpath
@property (nonatomic, strong) NSIndexPath *preSelectIndexPath; ///< 之前选中的indexpath

/*
 * 检测当前是否是选中的indexPath
 */
- (BOOL)isSelectedIndexPath:(NSIndexPath *)indexPath;


- (BOOL)isSelectedZeroIndexPath;

@end
