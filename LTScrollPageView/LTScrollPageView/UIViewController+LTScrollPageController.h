//
//  UIViewController+LTScrollPageController.h
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/9.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (LTScrollPageController)

/**
 *  所有子控制的父控制器, 方便在每个子控制页面直接获取到父控制器进行其他操作
 */
@property (nonatomic, weak, readonly) UIViewController *lt_scrollViewController;

@property (nonatomic, assign) NSInteger lt_currentIndex;



@end
