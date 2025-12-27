//
//  ManNiuRectangleView.m
//  drawRectangle
//
//  Created by benjaminlmz@qq.com on 2020/3/9.
//  Copyright © 2020 Tony. All rights reserved.
//

#import "ManNiuRectangleView.h"


@implementation ManNiuRectangleView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        [self initialize];

    }
    return self;
}

-(void)initialize
{
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:_imageView];
    _imageView.image = [UIImage imageNamed:@"hot"];
    _clipGridView = [[ManNiuClipGridView alloc] initWithFrame:self.bounds];
    [self addSubview:_clipGridView];
    _clipGridView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor lightGrayColor];
    self.autoresizesSubviews = NO;
}

//开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _touchMoveCount = 0;
    _touchBeganPoint = point;
    _clipGridOriginFrame = _clipGridView.clipRect;
    _needResetClipGrid = NO;

    //判断点击的的位置是否已在
    if (CGRectContainsPoint(CGRectMake(_clipGridView.frame.origin.x - 80, _clipGridView.frame.origin.y - 80, _clipGridView.frame.size.width + 100, _clipGridView.frame.size.height + 100), point)) {
        _isMoving = YES;
        CGPoint gridCenter = _clipGridView.center;
    
        if (ABS(gridCenter.x - point.x) < _clipGridView.frame.size.width / 4.0 && ABS(gridCenter.y - point.y) < _clipGridView.frame.size.height / 4.0) {
            _currentImageQuadrant = ImgClipOriginArea;
            return;
        }
        
        if (point.x > gridCenter.x) {
            if (point.y > gridCenter.y) {
                _currentImageQuadrant = ImgClipQuadrant4;
            }
            else
            {
                _currentImageQuadrant = ImgClipQuadrant1;
            }
        }
        else {
            if (point.y > gridCenter.y) {
                _currentImageQuadrant = ImgClipQuadrant3;
            }
            else {
                _currentImageQuadrant = ImgClipQuadrant2;
            }
        }
    }
}
//触摸结束
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (!_isMoving) {
        return;
    }
    
    ImgClipQuadrant blockCurrentImageQuadrant = _currentImageQuadrant;
    CGRect blockClipGridOriginFrame = _clipGridOriginFrame;
    CGRect imageViewFrame = _imageView.frame;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    //求出当前选择矩形，四个选择框的位置
    if (CGPointEqualToPoint(self->_touchBeganPoint,CGPointZero)) {
        self->_touchBeganPoint = point;
        return;
    }
    
    if (self->_minSize.width > 0 && self->_minSize.height > 0) {
        if (blockClipGridOriginFrame.size.height <= self->_minSize.height || blockClipGridOriginFrame.size.width <= self->_minSize.width) {
            return;
        }
    }
    
    CGFloat top = blockClipGridOriginFrame.origin.y;
    CGFloat bottom = top + blockClipGridOriginFrame.size.height;
    CGFloat left = blockClipGridOriginFrame.origin.x;
    CGFloat right = left + blockClipGridOriginFrame.size.width;
    CGFloat height = ABS(bottom - top);
    CGFloat width = ABS(right - left);
    
    CGFloat imageViewRight = imageViewFrame.size.width + imageViewFrame.origin.x;
    CGFloat imageViewLeft = imageViewFrame.origin.x;
    CGFloat imageViewTop = imageViewFrame.origin.y;
    CGFloat imageViewBottom = imageViewFrame.size.height + imageViewFrame.origin.y;
    
    CGFloat moveOffsetY = point.y - self->_touchBeganPoint.y;
    CGFloat moveOffsetX = point.x - self->_touchBeganPoint.x;
    
    CGRect clipRect = self->_clipGridView.clipRect;
    
    switch (blockCurrentImageQuadrant) {
        case ImgClipQuadrant1:
        {
            //从第一象限开始
            right += moveOffsetX;
            top += moveOffsetY;
            
        }
            break;
        case ImgClipQuadrant2:
        {
            //从第二象限开始
            left += moveOffsetX;
            top += moveOffsetY;
        }
            break;
        case ImgClipQuadrant3:
        {
            //从第三象限开始
            left += moveOffsetX;
            bottom += moveOffsetY;
        }
            break;
        case ImgClipQuadrant4:
        {
            //从第四象限开始
            right += moveOffsetX;
            bottom += moveOffsetY;
        }
            break;
        case ImgClipOriginArea:
        {
            CGFloat newTop = top + moveOffsetY;
            CGFloat newBottom = bottom + moveOffsetY;
            CGFloat newLeft = left + moveOffsetX;
            CGFloat newRight = right + moveOffsetX;
            
            if (newTop < imageViewTop) {
                newTop = imageViewTop;
                newBottom = newTop + self->_clipGridOriginFrame.size.height;
            }
            
            if (newLeft < imageViewLeft) {
                newLeft = imageViewLeft;
                newRight = newLeft + self->_clipGridOriginFrame.size.width;
            }
            
            if (newBottom > imageViewBottom) {
                newBottom = imageViewBottom;
                newTop = newBottom - self->_clipGridOriginFrame.size.height;
            }
            
            if (newRight > imageViewRight) {
                newRight = imageViewRight;
                newLeft = newRight - self->_clipGridOriginFrame.size.width;
            }
            
            top = newTop;
            bottom = newBottom;
            left = newLeft;
            right = newRight;
            // 直接更新center，无需异步调用，因为已经在主线程
            self->_clipGridView.center = CGPointMake((left + right) / 2, (top + bottom) / 2);
//            CGFloat ratio = self->_image.size.width / self->_imageView.frame.size.width;
//            self->_imageClipRect = CGRectMake((clipRect.origin.x - self->_imageView.frame.origin.x) * ratio, (clipRect.origin.y - self->_imageView.frame.origin.y) * ratio, clipRect.size.width * ratio, clipRect.size.height * ratio);
            return;
        default:
            return;
    }
    
    //根据新的 top bottom left right 设置
    //确保不超过 _imageView的范围
    CGFloat x = MIN(left, right);
    CGFloat y = MIN(top, bottom);
    width = ABS(right - left);
    height = ABS(bottom - top);
    
    // 边界限制，确保裁剪区域在imageView内
    if (x < imageViewFrame.origin.x) {
        width = width - (imageViewFrame.origin.x - x);
        x = imageViewFrame.origin.x;
    }
    if (y < imageViewFrame.origin.y) {
        height = height - (imageViewFrame.origin.y - y);
        y = imageViewFrame.origin.y;
    }
    if (x + width > imageViewFrame.origin.x + imageViewFrame.size.width) {
        width = imageViewFrame.origin.x + imageViewFrame.size.width - x;
    }
    if (y + height > imageViewFrame.origin.y + imageViewFrame.size.height) {
        height = imageViewFrame.origin.y + imageViewFrame.size.height - y;
    }
    
    // 确保最小尺寸
    if (width < 0) width = 0;
    if (height < 0) height = 0;
    
    clipRect = CGRectMake(x, y, width, height);
    _clipGridView.clipRect = clipRect;
//
//    CGFloat ratio = self->_image.size.width / self->_imageView.frame.size.width;
//    self->_imageClipRect = CGRectMake((clipRect.origin.x - self->_imageView.frame.origin.x) * ratio, (clipRect.origin.y - self->_imageView.frame.origin.y) * ratio, clipRect.size.width * ratio, clipRect.size.height * ratio);
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    _isMoving = NO;
    _touchBeganPoint = CGPointZero;
    _touchMoveCount = 0;
}

@end
