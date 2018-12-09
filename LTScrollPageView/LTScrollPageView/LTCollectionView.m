//
//  LTCollectionView.m
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/9.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "LTCollectionView.h"

@interface LTCollectionView ()
@property (copy, nonatomic) LTScrollViewShouldBeginPanGestureHandler gestureBeginHandler;
@end

@implementation LTCollectionView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (_gestureBeginHandler && gestureRecognizer == self.panGestureRecognizer) {
        return _gestureBeginHandler(self, (UIPanGestureRecognizer *)gestureRecognizer);
    }
    else {
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
}

- (void)setupScrollViewShouldBeginPanGestureHandler:(LTScrollViewShouldBeginPanGestureHandler)gestureBeginHandler {
    _gestureBeginHandler = [gestureBeginHandler copy];
}

@end
