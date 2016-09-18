//
//  ViewController.m
//  KVODemo
//
//  Created by kevin on 16/9/18.
//  Copyright © 2016年 kevin. All rights reserved.
//

#import "ViewController.h"

#import "NSObject+KVO.h"

@interface ViewController ()
@property (nonatomic,strong) UIScrollView *scroll;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.scroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scroll.contentSize   = CGSizeMake(self.view.frame.size.width, 1000);
    [self.view addSubview:self.scroll];
    
    [self.scroll addObserverBlockForKeyPath:@"contentOffset" block:^(__weak id obj, id oldValue, id newValue) {
        
        NSLog(@" %@   %@ ",oldValue, newValue);
        
    }];
    
}

- (void)dealloc {
    [self.scroll removeObserverBlockForKeyPath:@"contentOffset"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
