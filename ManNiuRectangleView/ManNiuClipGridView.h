//
//  ManNiuClipGridView.h
//  drawRectangle
//
//  Created by benjaminlmz@qq.com on 2020/3/9.
//  Copyright © 2020 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ManNiuClipGridView : UIView
//是否需要四个角上的圆角矩形条
@property (nonatomic) BOOL needRoundedLabels;
/*是否需要四个角上的圆片*/
@property (nonatomic) BOOL needCornerRounds;
/*线框的颜色*/
@property (nonatomic,strong) UIColor *color;
/*竖直条数量,极限255条*/
@property (nonatomic) int8_t columnLinesNumber;
/*横直条数量,极限255条*/
@property (nonatomic) int8_t rowLinesNumber;
/*最小尺寸*/
@property (nonatomic) CGFloat minSize;

@property (nonatomic) CGFloat contentInsect;

@property(nonatomic) CGRect clipRect;
@end

NS_ASSUME_NONNULL_END
