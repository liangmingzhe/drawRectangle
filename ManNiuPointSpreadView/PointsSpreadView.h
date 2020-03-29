//
//  PointsSpreadView.h
//  drawRectangle
//
//  Created by benjaminlmz@qq.com on 2020/3/10.
//  Copyright © 2020 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,SpreadState) {
    SpreadStateNormal = 0,                  //正常
    SpreadStatePointsLess = 1,              //少于三个点未能构成平面
    SpreadStateAreaCross = 2,               //线段交叉产生多块区域
};
@class PointsSpreadView;
@protocol PointSpreadViewProtocol<NSObject>

@optional
- (void)spreadView:(PointsSpreadView *)pointSpreadView SelectRectPointsArray:(NSArray *)array errorState:(SpreadState)errorState;

@end

@interface PointsSpreadView : UIView
@property(nonatomic,weak) id<PointSpreadViewProtocol>delegate;

- (void)drawMaskAreaWith:(NSArray *)pointArray;
- (void)createMaskArea;//生成区域 回调返回坐标数组
- (void)deletePoint;
- (void)clearAllPoints;
@end

NS_ASSUME_NONNULL_END
