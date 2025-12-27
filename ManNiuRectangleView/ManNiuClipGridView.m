//
//  ManNiuClipGridView.m
//  drawRectangle
//
//  Created by benjaminlmz@qq.com on 2020/3/9.
//  Copyright © 2020 Tony. All rights reserved.
//

#import "ManNiuClipGridView.h"
#define ROUND_RADIUS 5

@implementation ManNiuClipGridView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initialize];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)initialize
{
    super.clipsToBounds = NO;
    self.color = [UIColor colorWithRed:1 green:0.2 blue:0.2 alpha:1]; //边框颜色
    self.columnLinesNumber = 0;
    self.rowLinesNumber = 0;
    self.minSize = 50;
    _needRoundedLabels = NO;
    _needCornerRounds = YES;
    _contentInsect = ROUND_RADIUS;
    self.backgroundColor = [UIColor grayColor];
}
- (CGRect)clipRect {
    return CGRectMake(self.frame.origin.x + _contentInsect,self.frame.origin.y + _contentInsect, self.frame.size.width - _contentInsect * 2, self.frame.size.height - _contentInsect * 2);
}

- (void)setClipRect:(CGRect)clipRect {
    if (CGRectEqualToRect(clipRect, self.clipRect)) {
        return;
    }
    CGRect realRect = CGRectMake(clipRect.origin.x - _contentInsect, clipRect.origin.y - _contentInsect, clipRect.size.width + _contentInsect * 2, clipRect.size.height + _contentInsect * 2);
    
    // 优化：只在尺寸改变时才重绘，位置改变时直接更新frame即可
    BOOL sizeChanged = (ABS(self.bounds.size.width - clipRect.size.width) > 0.1 || ABS(self.bounds.size.height - clipRect.size.height) > 0.1);
    self.frame = realRect;
    
    if (sizeChanged) {
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _color.CGColor);
    CGContextSetStrokeColorWithColor(context, _color.CGColor);
    CGContextSetLineWidth(context, 2);
    CGRect frame = self.frame;
    CGPoint upRight = CGPointMake(frame.size.width - _contentInsect, _contentInsect);
    CGPoint downRight = CGPointMake(frame.size.width - _contentInsect, frame.size.height - _contentInsect);
    CGPoint downLeft = CGPointMake(_contentInsect, frame.size.height - _contentInsect);
    CGPoint upLeft = CGPointMake(_contentInsect, _contentInsect);

    frame = CGRectMake(_contentInsect, _contentInsect, frame.size.width - _contentInsect * 2, frame.size.height - _contentInsect * 2);

    //画边框
    CGContextMoveToPoint(context, upRight.x, upRight.y);
    CGContextAddLineToPoint(context,downRight.x , downRight.y);
    
    CGContextMoveToPoint(context, downRight.x, downRight.y);
    CGContextAddLineToPoint(context, downLeft.x ,downLeft.y);
    
    CGContextMoveToPoint(context,downLeft.x,downLeft.y);
    CGContextAddLineToPoint(context, upLeft.x , upLeft.y);
    CGContextStrokePath(context);

    CGContextMoveToPoint(context, upLeft.x, upLeft.y);
    CGContextAddLineToPoint(context, upRight.x ,upRight.y);
    
    CGContextClosePath(context);
    
    CGContextStrokePath(context);
    
    //画网格横线
    if (_rowLinesNumber) {
        CGFloat rowGap = frame.size.height / (_rowLinesNumber + 1);
        int8_t maxIndex = _rowLinesNumber + 1;
        for (int8_t i = 1; i != maxIndex ; i++) {
            CGFloat lineY = rowGap * i + upLeft.y;
            CGContextMoveToPoint(context, frame.origin.x, lineY);
            CGContextAddLineToPoint(context, upRight.x , lineY);
            CGContextClosePath(context);
            CGContextStrokePath(context);
        }
    }
    //画网格竖线
    if (_columnLinesNumber) {
        CGFloat columnGap = frame.size.width / (_columnLinesNumber + 1);
        int8_t maxIndex = _columnLinesNumber + 1;
        for (int8_t i = 0; i != maxIndex; i++) {
            CGFloat lineX = columnGap * i + upLeft.x;
            CGContextMoveToPoint(context, lineX, upRight.y);
            CGContextAddLineToPoint(context, lineX , downRight.y);
            CGContextClosePath(context);
            CGContextStrokePath(context);
        }
    }
    if (_needRoundedLabels) {
#define CORNER_RADIUS 5
#define LABEL_WIDTH 8
        //画四个角上的圆角矩形条
        DrawRoundCornerRectAtRect(context, CGRectMake(upLeft.x + (frame.size.width - _minSize) / 2,upLeft.y   -(LABEL_WIDTH) / 2, _minSize, LABEL_WIDTH),LABEL_WIDTH / 2);
        DrawRoundCornerRectAtRect(context, CGRectMake(upLeft.x +(frame.size.width - _minSize) / 2,upLeft.y + frame.size.height - (LABEL_WIDTH / 2), _minSize, LABEL_WIDTH),CORNER_RADIUS);
        DrawRoundCornerRectAtRect(context, CGRectMake(upLeft.x -(LABEL_WIDTH / 2),upLeft.y + (frame.size.height - _minSize) / 2,LABEL_WIDTH, _minSize),CORNER_RADIUS);
        DrawRoundCornerRectAtRect(context, CGRectMake(upLeft.x + frame.size.width -(LABEL_WIDTH / 2),upLeft.y + (frame.size.height - _minSize) / 2,LABEL_WIDTH, _minSize),CORNER_RADIUS);
    }

    if (_needCornerRounds) {
        CGContextAddArc(context, upRight.x, upRight.y, ROUND_RADIUS, 0, 2 * M_PI, NO);
        CGContextDrawPath(context, kCGPathFill);
        CGContextAddArc(context, downRight.x, downRight.y, ROUND_RADIUS, 0, 2 * M_PI, NO);
        CGContextDrawPath(context, kCGPathFill);
        CGContextAddArc(context, downLeft.x, downLeft.y, ROUND_RADIUS, 0, 2 * M_PI, NO);
        CGContextDrawPath(context, kCGPathFill);
        CGContextAddArc(context, upLeft.x, upLeft.y, ROUND_RADIUS, 0, 2 * M_PI, NO);
        CGContextDrawPath(context, kCGPathFill);
    }
}

static inline void DrawRoundCornerRectAtRect(CGContextRef context,CGRect rect,CGFloat radius)
{
    CGPoint upRight = CGPointMake(rect.origin.x + rect.size.width,rect.origin.y);
    CGPoint downRight = CGPointMake(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height);
    CGPoint downLeft = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    CGPoint upLeft = CGPointMake(rect.origin.x, rect.origin.y);
    CGContextMoveToPoint(context, upRight.x - radius, upRight.y);  // 开始坐标右边开始
    CGContextAddArcToPoint(context,upRight.x, upRight.y , downRight.x, downRight.y, radius);
    CGContextAddArcToPoint(context,downRight.x, downRight.y , downLeft.x, downLeft.y, radius);
    CGContextAddArcToPoint(context,downLeft.x, downLeft.y , upLeft.x, upLeft.y, radius);
    CGContextAddArcToPoint(context,upLeft.x, upLeft.y , upRight.x - radius, upRight.y, radius);
    CGContextDrawPath(context, kCGPathFill);
}

@end
