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

@interface LTPageContentView : UIView

/** 必须设置代理和实现相关的方法*/
@property(weak, nonatomic)id<LTScrollPageViewDelegate> delegate;

// 当前控制器
@property (strong, nonatomic, readonly) UIViewController *currentChildVc;

- (instancetype)initWithFrame:(CGRect)frame segmentStyle:(LTSegmentStyle *)segmentStyle parentViewController:(UIViewController *)parentViewController delegate:(id<LTScrollPageViewDelegate>) delegate;

@end
