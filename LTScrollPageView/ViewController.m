//
//  ViewController.m
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/6.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "ViewController.h"
#import "LTTitleView.h"
#import "LTSegmentView.h"
#import "LTPageContentView.h"

@interface ViewController ()
<
    LTSegmentViewDelegate,
    LTScrollPageViewDelegate
>

@property(strong, nonatomic)NSArray<NSString *> *titles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LTSegmentStyle *style = [[LTSegmentStyle alloc] init];
    style.scrollTitle = YES;
    style.titleMargin = 10;
    style.segmentViewBounces = YES;
    style.selectedTitleColor = [UIColor grayColor];
    style.showLine = YES;
    style.scrollLineColor = [UIColor redColor];
    style.scrollLineHeight = 2;
    
    self.titles = @[@"新闻头条",
                    @"国际要闻",
                    @"体育",
                    @"中国足球",
                    @"汽车",
                    @"囧途旅游",
                    @"幽默搞笑",
                    @"视频",
                    @"无厘头",
                    @"美女图片",
                    @"今日房价",
                    @"头像",
                    ];
    
    LTSegmentView *segView = [[LTSegmentView alloc] initWithFrame:CGRectMake(0, 88, self.view.frame.size.width, 40) segmentStyle:style delegate:self titles:self.titles];
    [self.view addSubview:segView];
    
    LTPageContentView *contentView = [[LTPageContentView alloc] initWithFrame:CGRectMake(0, 88 + 40, self.view.frame.size.width, 400) segmentStyle:style parentViewController:self delegate:self];
    contentView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:contentView];
    
    [segView setSelectedIndex:3 animated:YES];
    
}

- (void)LTSegmentView:(LTSegmentView *)segmentView oldTitleView:(LTTitleView *)oldTitleView currentTitleView:(LTTitleView *)currentTitleView oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex {
    NSLog(@"-----%@-----%@-----%@-----%ld-----%ld",segmentView,oldTitleView,currentTitleView,oldIndex,currentIndex);
}

- (NSInteger)numberOfChildViewControllers {
    return self.titles.count;
}

- (UIViewController *)childViewController:(UIViewController *)reuseViewController forIndex:(NSInteger)index {
    UIViewController *childVc = reuseViewController;
    
    if (!childVc) {
        childVc = [[UIViewController alloc] init];
        childVc.view.backgroundColor = [UIColor redColor];
    }
    
    //    NSLog(@"%ld-----%@",(long)index, childVc);
    
    return childVc;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
