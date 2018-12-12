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
@class LTPageContentView;

@protocol LTSegmentViewDelegate <NSObject>

- (void)LTSegmentView:(LTSegmentView *)segmentView oldTitleView:(LTTitleView *)oldTitleView currentTitleView:(LTTitleView *)currentTitleView oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex;

@end


@protocol LTScrollPageViewDelegate <NSObject>

@optional

/**
 LTPageContentView开始滑动
 
 @param contentView LTPageContentView
 */
- (void)LTContentViewWillBeginDragging:(LTPageContentView *)contentView;

/**
 LTPageContentView滑动调用
 
 @param contentView LTPageContentView
 @param oldIndex 开始滑动页面索引
 @param currentIndex 结束滑动页面索引
 @param progress 滑动进度
 */
- (void)LTContentViewDidScroll:(LTPageContentView *)contentView oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex progress:(CGFloat)progress;

/**
 LTPageContentView结束滑动
 
 @param contentView LTPageContentView
 @param oldIndex 开始滑动索引
 @param currentIndex 结束滑动索引
 */
- (void)LTContenViewDidEndDecelerating:(LTPageContentView *)contentView oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex;

@end
