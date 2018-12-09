//
//  LTScrollPageViewDelegate.h
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/7.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LTTitleView;
@class LTSegmentView;
@class LTCollectionView;

@protocol LTSegmentViewDelegate <NSObject>

- (void)LTSegmentView:(LTSegmentView *)segmentView oldTitleView:(LTTitleView *)oldTitleView currentTitleView:(LTTitleView *)currentTitleView oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex;

@end


@protocol LTScrollPageViewDelegate <NSObject>
/** 将要显示的子页面的总数 */
- (NSInteger)numberOfChildViewControllers;

/** 获取到将要显示的页面的控制器
 * -reuseViewController : 这个是返回给你的controller, 你应该首先判断这个是否为nil, 如果为nil 创建对应的控制器并返回, 如果不为nil直接使用并返回
 * -index : 对应的下标
 */
- (UIViewController *)childViewController:(UIViewController *)reuseViewController forIndex:(NSInteger)index;

@optional

- (BOOL)scrollPageController:(UIViewController *)scrollPageController contentScrollView:(LTCollectionView *)scrollView shouldBeginPanGesture:(UIPanGestureRecognizer *)panGesture;

- (void)contentViewDidMoveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;

- (void)adjustSegmentTitleOffsetToCurrentIndex:(NSInteger)index;

@end
