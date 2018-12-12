//
//  ViewController.m
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/6.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "ViewController.h"
#import "LTTitleView.h"
#import "LTScrollPageView.h"

@interface ViewController ()
<
    LTScrollPageViewDelegate,
    LTSegmentViewDelegate
>

@property(strong, nonatomic)NSArray<NSString *> *titles;
@property(strong, nonatomic)NSMutableArray<UIViewController *> *vcs;
@property (nonatomic, strong) LTSegmentView *segmentView;
@property (nonatomic, strong) LTPageContentView *contentView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LTSegmentStyle *style = [[LTSegmentStyle alloc] init];
    style.showLine = YES;
    style.scaleTitle = YES;
//    style.autoAdjustTitlesWidth = YES;
    style.adjustTitleWhenBeginDrag = YES;
    style.gradualChangeTitleColor = YES;
    
    self.titles = @[@"新闻头条",
                    @"国际要闻",
                    @"体育",
                    @"中国足球",
                    @"汽车",
                    @"囧途旅游",
                    @"幽默搞笑",
                    @"新闻头条",
                    @"国际要闻",
                    @"体育",
                    @"中国足球",
                    @"汽车",
                    @"囧途旅游",
                    @"幽默搞笑"
                    ];
    
    for (NSString *title in self.titles) {
        UIViewController *controller = [[UIViewController alloc] init];
        controller.title = title;
        CGFloat red = (arc4random() % 255)/255.0;
        CGFloat blue = (arc4random() % 255)/255.0;
        CGFloat green = (arc4random() % 255)/255.0;
        controller.view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
        [self.vcs addObject:controller];
    }
    
    
    LTSegmentView *segView = [[LTSegmentView alloc] initWithFrame:CGRectMake(0, 88, self.view.frame.size.width, 40) segmentStyle:style delegate:self titles:self.titles];
    [segView setSelectedIndex:3 animated:YES];
    self.segmentView = segView;
    [self.view addSubview:segView];
    
    
    LTPageContentView *contentView = [[LTPageContentView alloc] initWithFrame:CGRectMake(0, 128, self.view.lt_width, self.view.lt_height - 128) childVCs:self.vcs parentVC:self segmentStyle:style delegate:self];
    [contentView adjustPageContentViewCurrentIndex:3 animated:YES];
    self.contentView = contentView;
    [self.view addSubview:contentView];
    

}

- (void)LTSegmentView:(LTSegmentView *)segmentView oldTitleView:(LTTitleView *)oldTitleView currentTitleView:(LTTitleView *)currentTitleView oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex {
    [self.contentView adjustPageContentViewCurrentIndex:currentIndex animated:YES];
}

- (void)LTContenViewDidEndDecelerating:(LTPageContentView *)contentView oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex {
    [self.segmentView adjustTitleOffsetToCurrentIndex:currentIndex];
}

- (void)LTContentViewDidScroll:(LTPageContentView *)contentView oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex progress:(CGFloat)progress {
    [self.segmentView adjustUIWithProgress:progress oldIndex:oldIndex currentIndex:currentIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray <UIViewController *> *)vcs {
    if (!_vcs) {
        _vcs = [NSMutableArray array];
    }
    return _vcs;
}


@end
