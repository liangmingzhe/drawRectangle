//
//  TestViewController.m
//  drawRectangle
//
//  Created by benjaminlmz@qq.com on 2020/3/9.
//  Copyright © 2020 Tony. All rights reserved.
//

#import "TestViewController.h"
#import "PointsSpreadView.h"
@interface TestViewController ()
@property (nonatomic, strong) UIWindow* window;
@property (nonatomic, strong) PointsSpreadView *rectView;
@property (nonatomic, strong) UIButton *clearAllPointsBtn;
@property (nonatomic, strong) UIButton *createAreaBtn;
@property (nonatomic, strong) UIButton *removeSelectPointBtn;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.clearAllPointsBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 400, 100, 30)];
    [self.clearAllPointsBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.clearAllPointsBtn setTitle:@"清除" forState:UIControlStateNormal];
    [self.clearAllPointsBtn addTarget:self action:@selector(clearAllPointsHandle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clearAllPointsBtn];
    
    self.removeSelectPointBtn = [[UIButton alloc] initWithFrame:CGRectMake(150, 400, 100, 30)];
    [self.removeSelectPointBtn setTitle:@"删除点" forState:UIControlStateNormal];
    [self.removeSelectPointBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.removeSelectPointBtn addTarget:self action:@selector(removeSelectPointHandle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.removeSelectPointBtn];
    
    
    self.createAreaBtn = [[UIButton alloc] initWithFrame:CGRectMake(250, 400, 100, 30)];
    [self.createAreaBtn setTitle:@"生成区域" forState:UIControlStateNormal];
    [self.createAreaBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.createAreaBtn addTarget:self action:@selector(createAreaHandle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.createAreaBtn];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    self.rectView = [[PointsSpreadView alloc] initWithFrame:CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width/16*9)];
    self.rectView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.rectView];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.rectView createMaskArea];
}

- (void)clearAllPointsHandle {
    [self.rectView clearAllPoints];
}

- (void)createAreaHandle {
    [self.rectView createMaskArea];
}

- (void)removeSelectPointHandle {
    [self.rectView deletePoint];
}
@end
