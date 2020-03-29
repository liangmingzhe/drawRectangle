//
//  PointsSpreadView.m
//  drawRectangle
//
//  Created by benjaminlmz@qq.com on 2020/3/10.
//  Copyright © 2020 Tony. All rights reserved.
//

#import "PointsSpreadView.h"
#import "LineCorverageView.h"
#import "MNPoint.h"
#define gridValue 10

@interface PointsSpreadView() {
    CGContextRef ctx;
}
@property (nonatomic ,strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic ,strong) UILongPressGestureRecognizer *longTapGestureRecognizer;
@property (nonatomic ,strong) LineCorverageView *coverageView;
@property (nonatomic ,assign) CGPoint touchBeganPoint;
@property (nonatomic ,assign) BOOL isMove;
@property (nonatomic ,assign) BOOL isInPloygon;
@property (nonatomic ,assign) CGPoint offset;
@property (nonatomic ,assign) CGPoint lastTouchPoint;   //记录多动过程中上个一个位置，用来判断手势方向，不让图形拖动到区域外
@property (nonatomic ,assign) CGPoint direction;
@property (nonatomic,strong) CAShapeLayer *netLayer;
@end
@implementation PointsSpreadView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initObserver];
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self drawNetLayer];    //  绘制网格线
    self.coverageView = [[LineCorverageView alloc] initWithFrame:self.bounds];
    [self addSubview:self.coverageView];
//    self.pointsArray = [[NSMutableArray alloc] initWithCapacity:0];



}

- (void)startEdit {

    self.coverageView.pointState = PointStateEdit;
    [self.coverageView setNeedsDisplay];
}

- (void)clearAllPoints {
    [self.coverageView removeAllPointsFromSuperView];
    _coverageView.pointState = PointStateEdit;
}
- (void)drawMaskAreaWith:(NSArray *)pointArray {
    _coverageView.pointState = PointStateEdit;
    [_coverageView.pointsArray removeAllObjects];
    for (NSInteger i = 0; i < pointArray.count; i ++) {
        NSDictionary *dict = pointArray[i];
        MNPoint *p = [[MNPoint alloc] initWithX:[dict[@"x"] floatValue] andY:[dict[@"y"] floatValue]];
        p.tag = i + 1;

        [_coverageView.pointsArray addObject:p];
    }
    [_coverageView setNeedsDisplay];
    NSLog(@"");
}

- (void)createMaskArea {
    if (_coverageView.pointsArray.count < 3 || _coverageView.pointsArray == nil) {
        if ([self.delegate respondsToSelector:@selector(spreadView:SelectRectPointsArray:errorState:)]) {
            [self.delegate spreadView:self SelectRectPointsArray:@[] errorState:SpreadStatePointsLess];
        }
        return;
    }else {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (NSInteger i = 0; i < _coverageView.pointsArray.count; i ++) {
            NSArray *a = @[@(_coverageView.pointsArray[i].x),@(self.coverageView.pointsArray[i].y)];
            _coverageView.pointsArray[i].isSelected = NO;
            [array addObject:a];
        }
        BOOL isCross = [self checkCrossArea:_coverageView.pointsArray];
        if (isCross == YES) {
            NSLog(@"isCross = YES");
            if ([self.delegate respondsToSelector:@selector(spreadView:SelectRectPointsArray:errorState:)]) {
                [self.delegate spreadView:self SelectRectPointsArray:@[] errorState:SpreadStateAreaCross];
            }
            
            self.coverageView.pointState = PointStateEdit;
            self.coverageView.areaState = AreaStateIllegal;
        }else {
            NSLog(@"isCross = NO");
            if ([self.delegate respondsToSelector:@selector(spreadView:SelectRectPointsArray:errorState:)]) {
                [self.delegate spreadView:self SelectRectPointsArray:array errorState:SpreadStateNormal];
            }
            self.coverageView.areaState = AreaStateLegal;
            self.coverageView.pointState = PointStateFinish;
        }
        [self.coverageView setNeedsDisplay];
    }
}

- (void)deletePoint {
    [self.coverageView deleteSelectPoint];
    
    BOOL isCross = [self checkCrossArea:_coverageView.pointsArray];
    if (isCross == YES) {
//        NSLog(@"isCross = YES");
//        if ([self.delegate respondsToSelector:@selector(spreadView:SelectRectPointsArray:)]) {
//            [self.delegate spreadView:self SelectRectPointsArray:@[] errorState:SpreadStateAreaCross];
//        }
        self.coverageView.areaState = AreaStateIllegal;
    }else {
//        NSLog(@"isCross = NO");
//        if ([self.delegate respondsToSelector:@selector(spreadView:SelectRectPointsArray:)]) {
//            [self.delegate spreadView:self SelectRectPointsArray:_coverageView.pointsArray errorState:SpreadStateNormal];
//        }
        self.coverageView.areaState = AreaStateLegal;
    }
    [_coverageView setNeedsDisplay];
}

- (void)initObserver {
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//    self.longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    [self addGestureRecognizer:self.tapGestureRecognizer];
//    [self addGestureRecognizer:self.longTapGestureRecognizer];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (_coverageView.pointState == PointStateEdit || _coverageView.pointState == PointStateShapeMove) {
        UITouch *touch = [touches anyObject];
        CGPoint p = [touch locationInView:self];
        
        _isInPloygon = [self inPolygon:_coverageView.pointsArray testPoint:p];
        BOOL isSelectThePoint = [self.coverageView selectPoint:p];
        if(_isInPloygon == YES && isSelectThePoint == NO) {
            self.coverageView.pointState = PointStateShapeMove;
            self.touchBeganPoint = p;
            _lastTouchPoint = p;
        }else if(isSelectThePoint == YES){
            UITouch *touch = [touches anyObject];
            CGPoint point = [touch locationInView:self];
            _lastTouchPoint = point;
            _isMove = [self.coverageView selectPoint:point];
        }
    }else {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        _lastTouchPoint = point;
        _isMove = [self.coverageView selectPoint:point];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    _direction = CGPointMake(p.x - _lastTouchPoint.x,p.y - _lastTouchPoint.y);
    [self moveWithTouch:touches withEvent:event];
    BOOL isCross = [self checkCrossArea:_coverageView.pointsArray];
    
    if (isCross == YES) {
        self.coverageView.areaState = AreaStateIllegal;
    }else {
        self.coverageView.areaState = AreaStateLegal;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    _direction = CGPointMake(p.x - _lastTouchPoint.x,p.y - _lastTouchPoint.y);

    [self moveWithTouch:touches withEvent:event];
    _isMove = NO;
    BOOL isCross = [self checkCrossArea:_coverageView.pointsArray];
    
    if (isCross == YES) {
        self.coverageView.areaState = AreaStateIllegal;
    }else {
        self.coverageView.areaState = AreaStateLegal;
    }

}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    _direction = CGPointMake(p.x - _lastTouchPoint.x,p.y - _lastTouchPoint.y);

    [self moveWithTouch:touches withEvent:event];
    _isMove = NO;
    BOOL isCross = [self checkCrossArea:_coverageView.pointsArray];
    
    if (isCross == YES) {
        self.coverageView.areaState = AreaStateIllegal;
    }else {
        self.coverageView.areaState = AreaStateLegal;
    }
    
}

- (void)moveWithTouch:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    __block CGPoint p = [touch locationInView:self];
    __block BOOL xTouchZero = NO;
    __block BOOL xTouchWith = NO;
    __block BOOL yTouchZero = NO;
    __block BOOL yTouchWith = NO;
    //增加一个判断 如果拖动到达边界
    __block BOOL isTouchEdged = NO;
    [_coverageView.pointsArray enumerateObjectsUsingBlock:^(MNPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.x < 0 && _direction.x < 0) {
            if (obj.y < 0 && _direction.y < 0 && obj.y > self.frame.size.height && _direction.y > 0) {
                isTouchEdged = YES;
                *stop = YES;
            }else {
                xTouchZero = YES;
            }
        }
        else if (obj.x > self.frame.size.width && _direction.x > 0) {
            if ( obj.y > self.frame.size.height && _direction.y > 0 && obj.y < 0 && _direction.y < 0 ) {
                isTouchEdged = YES;
                *stop = YES;
            }else {
                xTouchWith = YES;
            }

        }
        
        if (obj.y < 0 && _direction.y < 0) {
            if (obj.x < 0 && _direction.x < 0 && obj.x > self.frame.size.width && _direction.x > 0) {
                isTouchEdged = YES;
                *stop = YES;
            }else {
                yTouchZero = YES;
            }
        }
        else if (obj.y > self.frame.size.height && _direction.y > 0) {
            if ( obj.x > self.frame.size.width && _direction.x > 0 && obj.x < 0 && _direction.x < 0 ) {
                isTouchEdged = YES;
                *stop = YES;
            }else {
                yTouchWith = YES;
            }

        }

    }];
    
    if (isTouchEdged == YES) {
        return;
    }
    
    if (_isMove) {
        UITouch *touch = [touches anyObject];
        CGFloat x = MIN(MAX([touch locationInView:self].x+_offset.x, 0), CGRectGetWidth(self.bounds));
        CGFloat y = MIN(MAX([touch locationInView:self].y+_offset.y, 0), CGRectGetHeight(self.bounds));
        [self.coverageView movePointTo:CGPointMake(x, y)];
        _coverageView.pointState = PointStateEdit;
        
    }
    
    if (_coverageView.pointState == PointStateShapeMove) {
        if(_isInPloygon == YES) {
            UITouch *touch = [touches anyObject];
            CGPoint p = [touch locationInView:self];
            
            
            float deltaX = p.x - self.touchBeganPoint.x;
            float deltaY = p.y - self.touchBeganPoint.y;
            self.touchBeganPoint = p;
            
            if (((_direction.x > 0) && (xTouchWith == YES)) || ((_direction.x < 0) && (xTouchZero == YES))) {
                deltaX = 0;
            }
            if (((_direction.y > 0) && (yTouchWith == YES)) || ((_direction.y < 0) && (yTouchZero == YES))) {
                deltaY = 0;
            }
            NSLog(@"delta --- deltaX:%0.2f deltaY:%0.2f",deltaX,deltaY);
            [self.coverageView moveShapeWithDeltaX:deltaX deltaY:deltaY];

        }
    }
    _lastTouchPoint = p;    //  处理完数据将当前点保存为上一个点以便能及时判断下一次手势的方向
}

- (void)tap:(UIGestureRecognizer *)sender {
    if (self.coverageView.pointState == PointStateFinish) {
        
    }else if (self.coverageView.pointState == PointStateShapeMove) {
        
    }else {
        CGPoint point = [sender locationInView:self];
        //保证添加的点都在网格交叉线上
        point = [self gridPointAdjust:point];
        [self.coverageView addPointWithCGPoint:point];
    }
}
- (void)longTap:(UILongPressGestureRecognizer *)sender {
    NSLog(@"");
}



//绘制网格线
- (void)drawNetLayer {
    self.netLayer = [CAShapeLayer layer];
    self.netLayer.frame = self.bounds;
    
    self.netLayer.strokeColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5].CGColor;
    self.netLayer.fillColor = [UIColor clearColor].CGColor;
    self.netLayer.lineWidth = 1;
    
    int hGridNum = self.frame.size.height / gridValue + 1;
    int wGridNum = self.frame.size.width / gridValue + 1;
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    
    for (int i = 0; i < hGridNum; i++) {
        UIBezierPath *hPath = [UIBezierPath bezierPath];
        [hPath moveToPoint:CGPointMake(0,i * gridValue)];
        [hPath addLineToPoint:CGPointMake(self.frame.size.width,i * gridValue)];
        [linePath appendPath:hPath];
    }
    for (int i = 0 ; i < wGridNum; i ++) {
        UIBezierPath *vPath = [UIBezierPath bezierPath];
        [vPath moveToPoint:CGPointMake(i * gridValue,0)];
        [vPath addLineToPoint:CGPointMake(i * gridValue,self.frame.size.height)];
        [linePath appendPath:vPath];
    }

    self.netLayer.path = [linePath CGPath];
    [self.layer addSublayer:self.netLayer];
}

//射线法检查一个点是否在一个平面内
- (BOOL)inPolygon:(NSArray <MNPoint *>*)pointArray testPoint:(CGPoint)testPoint {
    int i, j;
    BOOL isCrossed = NO;
    for (i = 0 , j = (int)pointArray.count - 1; i < pointArray.count; j = i++) {
        // 点在两个x之间 且以点垂直y轴向上做射线
        if ( ( (pointArray[i].y > testPoint.y) != (pointArray[j].y > testPoint.y) ) && (testPoint.x < (pointArray[j].x - pointArray[i].x) * (testPoint.y - pointArray[i].y) / (pointArray[j].y - pointArray[i].y) + pointArray[i].x) ){
            isCrossed = !isCrossed;
        }
    }
    return isCrossed;
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


- (BOOL)checkCrossArea:(NSArray<MNPoint *> *)array {
    if(array.count <= 3){
        return NO;
    }
    for (int i = 0; i < array.count - 3; i ++) {
        for (int j = i + 2; j < array.count - 1; j ++) {
            NSLog(@"Check Cross Line:%d Line:%d",i+1,i+3);
            BOOL result = [self checkCross:array[i] p2:array[i + 1] q1:array[j] q2:array[j + 1]];
            if(result == YES) {
                return YES;
            }
        }
    }
    
    for (int j = 1; j < array.count - 2; j ++) {
        BOOL result = [self checkCross:array[array.count - 1] p2:array[0] q1:array[j] q2:array[j + 1]];
        if(result == YES) {
            return YES;
        }
    }
    return NO;
}

//向量夹积判断线段是否相交 p1p2为一条向量线段 q1q2为另一条向量线段
- (BOOL)checkCross:(MNPoint *)p1 p2:(MNPoint *)p2 q1:(MNPoint *)q1 q2:(MNPoint *)q2 {
    return [self detectIntersect:p1 p2:p2 p3:q1 p4:q2];
}


- (double)crossProduct:(MNPoint *)p1 b:(MNPoint *)p2 c:(MNPoint *)p3 {
    double x1,y1,x2,y2;
    x1=p1.x-p2.x;
    y1=p1.y-p2.y;
    x2=p3.x-p2.x;
    y2=p3.y-p2.y;
    return x1*y2-x2*y1;
}


bool between(double a, double X0, double X1)
{
    double temp1= a-X0;
    double temp2= a-X1;
    if ( ( temp1<1e-8 && temp2>-1e-8 ) || ( temp2<1e-6 && temp1>-1e-8 ) )
    {
        return true;
    }
    else
    {
        return false;
    }
}
  
  
// 判断两条直线段是否有交点，有则计算交点的坐标
// p1,p2是直线一的端点坐标
// p3,p4是直线二的端点坐标
- (BOOL)detectIntersect:(MNPoint *)p1 p2:(MNPoint *)p2 p3:(MNPoint *)p3 p4:(MNPoint *)p4 {
    double line_x,line_y; //交点
    if ( (fabs(p1.x-p2.x)<1e-6) && (fabs(p3.x-p4.x)<1e-6) )
    {
        return false;
    }
    else if ( (fabs(p1.x-p2.x)<1e-6) ) //如果直线段p1p2垂直与y轴
    {
        if (between(p1.x,p3.x,p4.x))
        {
            double k = (p4.y-p3.y)/(p4.x-p3.x);
            line_x = p1.x;
            line_y = k*(line_x-p3.x)+p3.y;
  
            if (between(line_y,p1.y,p2.y))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        else
        {
            return false;
        }
    }
    else if ( (fabs(p3.x-p4.x)<1e-6) ) //如果直线段p3p4垂直与y轴
    {
        if (between(p3.x,p1.x,p2.x))
        {
            double k = (p2.y-p1.y)/(p2.x-p1.x);
            line_x = p3.x;
            line_y = k*(line_x-p2.x)+p2.y;
  
            if (between(line_y,p3.y,p4.y))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        else
        {
            return false;
        }
    }
    else
    {
        double k1 = (p2.y-p1.y)/(p2.x-p1.x);
        double k2 = (p4.y-p3.y)/(p4.x-p3.x);
  
        if (fabs(k1-k2)<1e-6)
        {
            return false;
        }
        else
        {
            line_x = ((p3.y - p1.y) - (k2*p3.x - k1*p1.x)) / (k1-k2);
            line_y = k1*(line_x-p1.x)+p1.y;
        }
  
        if (between(line_x,p1.x,p2.x)&&between(line_x,p3.x,p4.x))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}
@end
