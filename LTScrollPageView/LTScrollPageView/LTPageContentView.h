//
//  LTPageContentView.h
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/6.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTSegmentStyle.h"
#import "LTScrollPageViewDelegate.h"
#import "LTSegmentView.h"

@interface LTPageContentView : UIView


/**
 实例化方法

 @param frame frame
 @param childVCs 子控制器的数组
 @param parentVC 父类
 @param segmentStyle 基础设置
 @param delegate LTScrollPageViewDelegate
 @return 实例
 */
- (instancetype)initWithFrame:(CGRect)frame
                     childVCs:(NSArray *)childVCs
                     parentVC:(UIViewController *)parentVC
                 segmentStyle:(LTSegmentStyle *)segmentStyle
                     delegate:(id<LTScrollPageViewDelegate>)delegate;
/** 给外界设置显示第几个页面 */
- (void)adjustPageContentViewCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated;

@property (nonatomic, weak) id<LTScrollPageViewDelegate>delegate;

@end
