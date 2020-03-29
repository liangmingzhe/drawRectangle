//
//  LineCorverageView.h
//  drawRectangle
//
//  Created by benjaminlmz@qq.com on 2020/3/11.
//  Copyright © 2020 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNPoint.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,PointState) {
    PointStateEdit,
    PointStateAdjust,
    PointStateShapeMove,
    PointStateFinish,
};

typedef NS_ENUM(NSInteger,AreaState) {
    AreaStateLegal,
    AreaStateIllegal
};

@interface LineCorverageView : UIView
@property (nonatomic ,strong) NSMutableArray<MNPoint *> *pointsArray;
@property (nonatomic ,assign) PointState pointState;

@property (nonatomic ,assign) AreaState areaState;

@property (nonatomic ,strong) UIColor *color;
- (void)addPointWithCGPoint:(CGPoint)point;
- (void)movePointTo:(CGPoint)position;
- (void)moveShapeWithDeltaX:(float)x deltaY:(float)y;
- (BOOL)selectPoint:(CGPoint)point;
- (void)deleteSelectPoint;
- (void)removeAllPointsFromSuperView;
@end

NS_ASSUME_NONNULL_END
