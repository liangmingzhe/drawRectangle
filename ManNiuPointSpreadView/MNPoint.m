//
//  MNPoint.m
//  drawRectangle
//
//  Created by benjaminlmz@qq.com on 2020/3/10.
//  Copyright © 2020 Tony. All rights reserved.
//

#import "MNPoint.h"
#define UIColorFromRGB(rgbValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])
@implementation MNPoint

- (id)initWithX:(CGFloat)x andY:(CGFloat)y{
    if (self = [super init]) {
        self.x = x;
        self.y = y;
    }
    return self;
}

- (void)setPoint:(CGPoint)point {
    self.x = point.x;
    self.y = point.y;
    _tb.center = CGPointMake(self.x, self.y);
}

- (UILabel *)tb {
    if (_tb == nil) {
        _tb = [[UILabel alloc] initWithFrame:CGRectMake(self.x, self.y, 30, 30)];
        _tb.textAlignment = NSTextAlignmentCenter;
        _tb.center = CGPointMake(self.x, self.y);
        _tb.textColor = UIColorFromRGB(0x64b0e1);
        _tb.text = [NSString stringWithFormat:@"%ld",(long)_tag];
    }
    return _tb;
}
- (void)setTag:(NSInteger)tag {
    _tb.text = [NSString stringWithFormat:@"%ld",(long)tag];
    _tag = tag;
}
- (CGPoint)getPoint {
    return CGPointMake(self.x, self.y);
}

- (CGRect)getRect {
    return CGRectMake(MAX(self.x-40, 0), MAX(self.y-40, 0), self.x+40, self.y+40);
}
@end
