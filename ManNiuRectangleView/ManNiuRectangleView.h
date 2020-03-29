//
//  ManNiuRectangleView.h
//  drawRectangle
//
//  Created by benjaminlmz@qq.com on 2020/3/9.
//  Copyright © 2020 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManNiuClipGridView.h"
NS_ASSUME_NONNULL_BEGIN
@protocol ManNiuClipGridViewProtocol<NSObject>

@end

typedef NS_ENUM(NSUInteger, ImgClipQuadrant) {
    ImgClipQuadrantNone = 0,
    ImgClipQuadrant1 = 100,
    ImgClipQuadrant2,
    ImgClipQuadrant3,
    ImgClipQuadrant4,
    ImgClipOriginArea,
};
@interface ManNiuRectangleView : UIView {

    CGPoint _touchBeganPoint;
    
    ImgClipQuadrant _currentImageQuadrant;
    
    CGRect _clipGridOriginFrame;
        
    BOOL _isMoving;
    
    BOOL _needResetClipGrid;
    
    int _touchMoveCount;
    
    CGFloat _bevelEdgeRatio;
}
//选区网格视图
@property (nonatomic ,strong) ManNiuClipGridView *clipGridView;
@property (nonatomic ,strong) UIImageView *imageView;
/*最小尺寸*/
@property (nonatomic) CGSize minSize;

@end

NS_ASSUME_NONNULL_END
