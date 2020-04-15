//
//  LineCorverageView.m
//  drawRectangle
//
//  Created by benjaminlmz@qq.com on 2020/3/11.
//  Copyright © 2020 Tony. All rights reserved.
//

#import "LineCorverageView.h"

#define kMiniDistance 30
#define kMaxPointsNum 8
#define gridValue 10
#define UIColorFromRGB(rgbValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

#define normalColor UIColorFromRGB(0x64b0e1)
#define illegalColor UIColorFromRGB(0xFF0000)
@interface LineCorverageView(){
    CGContextRef ctx;
}

@property (nonatomic ,strong) MNPoint *movePoint;
@property (nonatomic ,assign) BOOL isMove;
@property (nonatomic ,assign) CGPoint offset;
@end

@implementation LineCorverageView
- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        
    }
    
    return self;
}

- (void)initialize {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.pointsArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.color = normalColor;
    self.areaState = AreaStateLegal;
    self.pointState = PointStateEdit;
}

// 删除选中的点、或者是最近操作过的点
- (void)deleteSelectPoint {
    if (self.pointState == PointStateFinish) {
        return;
    }

    if (_movePoint == nil) {
        return;
    }
    _movePoint.tb.text = @"";
    [_movePoint.tb removeFromSuperview];
    if(_pointsArray.count > 0) {
        [_pointsArray removeObjectAtIndex:(_movePoint.tag - 1)];
    }
    _movePoint = nil;
    
    for (NSInteger i = 0; i < _pointsArray.count;i++) {
        _pointsArray[i].tag = i + 1;
    }
    [self setNeedsDisplay];
}

// 删除所有点
- (void)removeAllPointsFromSuperView {
    for (MNPoint *p in _pointsArray) {
        [p.tb removeFromSuperview];
    }
    
    [_pointsArray removeAllObjects];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self drawCoverageView];
}

- (void)drawCoverageView {
    if (self.areaState == AreaStateLegal) {
        _color = normalColor;
    }else {
        _color = illegalColor;
    }
    
    ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    CGContextSetLineWidth(ctx, 2);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    if (self.pointState == PointStateFinish) {
        
    }else {
        CGFloat lengths[] = {5, 5};
        CGContextSetLineDash(ctx, 0.0, lengths, 2);
    }

    CGContextSetStrokeColorWithColor(ctx, [_color CGColor]);
    
    [_pointsArray enumerateObjectsUsingBlock:^(MNPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint point = [[self.pointsArray objectAtIndex:idx] getPoint];
        if (idx == 0) {
            CGContextMoveToPoint(ctx, point.x, point.y);
        }
        else {
            CGContextAddLineToPoint(ctx, point.x, point.y);
        }
    }];
    CGContextClosePath(ctx);

    CGContextStrokePath(ctx);
    CGContextSetFillColorWithColor(ctx, _color.CGColor);
    CGContextSetStrokeColorWithColor(ctx, _color.CGColor);
    
    CGContextBeginPath(ctx);
    [self.pointsArray enumerateObjectsUsingBlock:^(MNPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint point = [[self.pointsArray objectAtIndex:idx] getPoint];
        if (idx == 0) {
            CGContextMoveToPoint(ctx, point.x, point.y);
        }
        else {
            CGContextAddLineToPoint(ctx, point.x, point.y);
        }
    }];
//    整个屏幕染色。圈中部分不染色
//    CGContextAddRect(ctx, self.bounds);
//    CGContextClosePath(ctx);
//    CGContextEOClip(ctx);
//    CGContextSetFillColorWithColor(ctx, [[UIColor clearColor] CGColor]);
//    CGContextFillRect(ctx, self.bounds);
    UIColor *aColor;
    if (self.areaState == AreaStateLegal) {
        aColor = [UIColor colorWithRed:100/255.0f green:176/255.0f blue:225/255.0f alpha:0.4];
    }else {
        aColor = [UIColor colorWithRed:250/255.0f green:0/255.0f blue:0/255.0f alpha:0.4];
    }
    CGContextSetFillColorWithColor(ctx, aColor.CGColor);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    CGContextStrokePath(ctx); //直接在图形上下文中渲染路径
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    
    //画圆
    for (MNPoint * point in _pointsArray) {
        UIColor *bColor = nil;
        if (point.isSelected == YES) {
            point.tb.textColor = [UIColor whiteColor];
            bColor = _color;
        }else {
            point.isSelected = NO;
            point.tb.textColor = _color;
            bColor = [UIColor whiteColor];
        }
        
        CGFloat lengths[] = {10, 10};
        CGContextSetFillColorWithColor(ctx, bColor.CGColor);
        CGContextSetLineDash(ctx, 0.0, lengths, 0);
        CGContextAddArc(ctx, point.x, point.y, 10, 0, 2 * M_PI, NO);
        CGContextDrawPath(ctx, kCGPathFillStroke);
        
        [self addSubview:point.tb];
    }
}

//添加点
- (void)addPointWithCGPoint:(CGPoint)point {
    
    __block CGFloat distance = kMiniDistance;
    __block BOOL jumpFlag = NO;
    
    [self.pointsArray enumerateObjectsUsingBlock:^(MNPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(CGRectContainsPoint([obj getRect], point)) {
            if ([self distanceFromPoint:[obj getPoint] ToPoint:point] < distance) {
                jumpFlag = YES;
            }
        }
    }];

    if (jumpFlag == YES) {
        return;
    }
    if (_pointsArray.count >= kMaxPointsNum) {
        return;
    }
    MNPoint *p = [[MNPoint alloc] initWithX:point.x andY:point.y];
    [_pointsArray addObject:p];
    p.isSelected = YES;
    for (NSInteger i = 0; i < _pointsArray.count;i++) {
        _pointsArray[i].tag = i + 1;
        if (i != (_pointsArray.count - 1)) {
            _pointsArray[i].isSelected = NO;
        }
    }
    self.movePoint = p;
    [self setNeedsDisplay];
}

//选中点处理
- (BOOL)selectPoint:(CGPoint)point {
    __block BOOL isSelect = NO;
    __block float distance = [self distanceFromPoint:[[_pointsArray firstObject] getPoint] ToPoint:point];
    [_pointsArray enumerateObjectsUsingBlock:^(MNPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(CGRectContainsPoint([obj getRect], point)) {
            float ds = [self distanceFromPoint:[obj getPoint] ToPoint:point];
            obj.isSelected = NO;
            if (ds < kMiniDistance) {
                //如果遍历的是在点的响应区域内
                if (isSelect == NO) {
                    if (distance >= ds) {
                        distance = ds;
                        _offset = CGPointMake([obj getPoint].x - point.x, [obj getPoint].y - point.y);
                        self.movePoint = obj;
                        NSLog(@"Select Point :%ld",(long)obj.tag);
                        isSelect = YES;
                        obj.isSelected = YES;
                    }else {
                        obj.isSelected = NO;
                    }
                }else {
                    if (distance > ds) {
                        distance = ds;
                        _offset = CGPointMake([obj getPoint].x - point.x, [obj getPoint].y - point.y);
                        self.movePoint = obj;
                        NSLog(@"Select Point :%ld",(long)obj.tag);
                        isSelect = YES;
                        obj.isSelected = YES;
                        
                    }else {
                        obj.isSelected = NO;
                    }
                }
            }else {
                obj.isSelected = NO;
            }
        }else {
            obj.isSelected = NO;
        }
    }];
    [_pointsArray enumerateObjectsUsingBlock:^(MNPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag != self.movePoint.tag) {
            obj.isSelected = NO;
        }else {
            obj.isSelected = YES;
        }
    }];
    return isSelect;
}
- (void)movePointTo:(CGPoint)position {
    position = [self gridPointAdjust:position];
    [_movePoint setPoint:CGPointMake(position.x, position.y)];
    
    /**
     添加判断四边形任意两边是否都不交叉（非端点），如果交叉则对点的数组重新排列
     */
    
    [self setNeedsDisplay];
}


- (void)moveShapeWithDeltaX:(float)x deltaY:(float)y {
    for (MNPoint *p in _pointsArray) {
        
        p.x = p.x + x;
        p.y = p.y + y;
        [p.tb setFrame:CGRectMake(p.tb.frame.origin.x + x, p.tb.frame.origin.y + y, CGRectGetWidth(p.tb.frame), CGRectGetHeight(p.tb.frame))];
    }
    [self setNeedsDisplay];

}
- (CGFloat)distanceFromPoint:(CGPoint)sou ToPoint:(CGPoint)des{
    return sqrt(pow(des.x-sou.x,2)+pow(des.y-sou.y,2));
}

- (CGPoint)gridPointAdjust:(CGPoint)point {
    int gridCheckX = (int)point.x % gridValue;
    int gridCheckY = (int)point.y % gridValue;
    if (gridCheckX != 0 && gridCheckX < 5) {
        point.x = ((int)point.x / gridValue) * gridValue;
    }else if (gridCheckX != 0 && gridCheckX >= 5) {
        point.x = ((int)point.x / gridValue + 1) * gridValue;
    }
    if (gridCheckY != 0 && gridCheckY < 5) {
        point.y = ((int)point.y / gridValue) * gridValue;
    }else if (gridCheckY != 0 && gridCheckY >= 5) {
        point.y = ((int)point.y / gridValue + 1) * gridValue;
    }
    return point;
}

@end
