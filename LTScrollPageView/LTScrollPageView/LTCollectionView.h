//
//  LTCollectionView.h
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/9.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTCollectionView : UICollectionView

typedef BOOL(^LTScrollViewShouldBeginPanGestureHandler)(LTCollectionView *collectionView, UIPanGestureRecognizer *panGesture);

- (void)setupScrollViewShouldBeginPanGestureHandler:(LTScrollViewShouldBeginPanGestureHandler)gestureBeginHandler;

@end
