//
//  UIViewController+LTScrollPageController.m
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/9.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "UIViewController+LTScrollPageController.h"
#import "LTScrollPageViewDelegate.h"
#import <objc/runtime.h>
char LTIndexKey;
@implementation UIViewController (LTScrollPageController)

//@dynamic zj_scrollViewController;

- (UIViewController *)lt_scrollViewController {
    UIViewController *controller = self;
    while (controller) {
        if ([controller conformsToProtocol:@protocol(LTScrollPageViewDelegate)]) {
            break;
        }
        controller = controller.parentViewController;
    }
    return controller;
}

- (void)setLt_currentIndex:(NSInteger)lt_currentIndex {
    objc_setAssociatedObject(self, &LTIndexKey, [NSNumber numberWithInteger:lt_currentIndex], OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)lt_currentIndex {
    return [objc_getAssociatedObject(self, &LTIndexKey) integerValue];
}

@end
