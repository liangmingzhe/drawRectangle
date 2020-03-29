//
//  MNPoint.h
//  drawRectangle
//
//  Created by benjaminlmz@qq.com on 2020/3/10.
//  Copyright © 2020 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface MNPoint : NSObject
//初始化
- (instancetype)initWithX:(CGFloat)x andY:(CGFloat)y;

@property (nonatomic,assign) CGFloat x;

@property (nonatomic,assign) CGFloat y;

@property (nonatomic,assign) NSInteger tag;
@property (nonatomic,strong) UILabel *tb;
@property (nonatomic,strong) UIColor *color;
@property (nonatomic,assign) BOOL isSelected;
//设置点的坐标
- (void)setPoint:(CGPoint)point;
//获取点
- (CGPoint)getPoint;;

//获取相应区域
- (CGRect)getRect;
@end

NS_ASSUME_NONNULL_END
