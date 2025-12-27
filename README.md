# DrawRectangle - iOS 图形绘制与裁剪工具

一个功能强大的 iOS 应用，支持多边形区域绘制和矩形裁剪功能。用户可以通过触摸交互创建、编辑和管理图形区域。

## 📱 功能特性

### 1. 多边形区域绘制
- **添加点**：点击屏幕任意位置添加控制点（最多8个点）
- **网格对齐**：点自动对齐到10x10像素网格，确保精确绘制
- **可视化反馈**：每个点显示编号，选中的点高亮显示
- **实时预览**：绘制过程中实时显示多边形轮廓和填充区域

### 2. 智能区域管理
- **区域验证**：
  - 自动检测多边形是否合法（至少3个点）
  - 实时检测线段交叉，非法区域显示红色警告
  - 合法区域显示蓝色填充
- **状态管理**：
  - `PointStateEdit`：编辑模式，可以添加/移动点
  - `PointStateFinish`：完成模式，区域已确定
  - `PointStateShapeMove`：形状移动模式

### 3. 交互式拖动功能
- **单点拖动**：选中点后拖动调整位置，自动网格对齐
- **整体拖动**：在多边形内部拖动可移动整个形状
- **边界检测**：智能边界限制，防止图形移出视图范围
- **流畅体验**：优化的增量计算，确保拖动流畅自然

### 4. 矩形裁剪工具
- **四象限调整**：支持从四个象限拖动调整矩形大小
- **中心移动**：在矩形中心区域拖动可移动整个裁剪框
- **边界限制**：自动限制在图片范围内
- **最小尺寸**：支持设置最小裁剪尺寸

### 5. 操作控制
- **清除所有点**：一键清除所有已添加的点
- **删除选中点**：删除当前选中的点
- **生成区域**：验证并生成最终区域，返回坐标数组
- **坐标显示**：实时显示所有点的坐标信息

## 🏗️ 项目结构

```
drawRectangle/
├── ManNiuPointSpreadView/          # 多边形绘制模块
│   ├── PointsSpreadView.h/m        # 主视图控制器
│   ├── LineCorverageView.h/m       # 线条和覆盖层绘制
│   └── MNPoint.h/m                 # 点数据模型
├── ManNiuRectangleView/            # 矩形裁剪模块
│   ├── ManNiuRectangleView.h/m    # 矩形视图控制器
│   └── ManNiuClipGridView.h/m     # 裁剪网格视图
├── TestViewController.h/m          # 测试视图控制器
└── drawRectangle/                  # 应用主文件
```

## 🔧 核心类说明

### PointsSpreadView
多边形绘制的主视图类，负责：
- 触摸事件处理
- 点的添加、删除、移动
- 区域验证和状态管理
- 网格绘制和点对齐

**主要方法：**
- `- (void)drawMaskAreaWith:(NSArray *)pointArray` - 根据点数组绘制区域
- `- (void)createMaskArea` - 生成并验证区域
- `- (void)deletePoint` - 删除选中的点
- `- (void)clearAllPoints` - 清除所有点

### LineCorverageView
负责绘制多边形轮廓和填充：
- 绘制虚线/实线轮廓
- 填充区域（合法/非法状态不同颜色）
- 绘制控制点圆圈
- 显示点编号标签

### ManNiuRectangleView
矩形裁剪视图，支持：
- 四象限拖动调整
- 中心区域整体移动
- 边界限制和最小尺寸控制

### MNPoint
点数据模型：
- 存储坐标信息（x, y）
- 管理选中状态
- 提供标签显示

## 📊 技术实现

### 算法特性

1. **射线法判断点在多边形内**
   - 使用经典的射线法算法判断触摸点是否在多边形内部
   - 用于实现整体拖动功能

2. **线段交叉检测**
   - 使用向量叉积判断两条线段是否相交
   - 实时检测多边形是否自相交
   - 支持处理垂直线段的特殊情况

3. **网格对齐算法**
   - 自动将点对齐到最近的网格交叉点
   - 提供5像素的容差范围

### 性能优化

- **智能重绘**：只在状态改变时更新UI
- **增量计算**：拖动时使用增量而非绝对位置，提升流畅度
- **边界检测优化**：简化边界检测逻辑，提高响应速度
- **条件渲染**：只在必要时检查线段交叉

## 🎨 UI/UX 特性

- **视觉反馈**：
  - 合法区域：蓝色填充（透明度40%）
  - 非法区域：红色填充（透明度40%）
  - 选中点：蓝色圆圈，白色文字
  - 未选中点：白色圆圈，蓝色文字

- **网格辅助线**：
  - 10x10像素网格
  - 半透明灰色线条
  - 帮助精确对齐

- **交互体验**：
  - 流畅的拖动动画
  - 实时状态反馈
  - 清晰的错误提示

## 📝 使用示例

### 基本使用

```objc
// 创建视图
PointsSpreadView *spreadView = [[PointsSpreadView alloc] initWithFrame:frame];
spreadView.delegate = self;
[self.view addSubview:spreadView];

// 实现代理方法
- (void)spreadView:(PointsSpreadView *)pointSpreadView 
SelectRectPointsArray:(NSArray *)array 
        errorState:(SpreadState)errorState {
    if (errorState == SpreadStateNormal) {
        // 处理合法的点数组
        for (NSArray *point in array) {
            CGFloat x = [point[0] floatValue];
            CGFloat y = [point[1] floatValue];
            // 使用坐标...
        }
    } else if (errorState == SpreadStatePointsLess) {
        // 点数不足
    } else if (errorState == SpreadStateAreaCross) {
        // 区域交叉
    }
}
```

### 操作流程

1. **添加点**：点击屏幕添加控制点
2. **调整点**：拖动点调整位置
3. **移动形状**：在多边形内部拖动移动整个形状
4. **生成区域**：点击"生成区域"按钮验证并获取坐标
5. **删除点**：选中点后点击"删除点"按钮
6. **清除所有**：点击"清除"按钮重置

## 🔍 错误状态

应用定义了三种状态：

- `SpreadStateNormal` (0)：正常状态，区域合法
- `SpreadStatePointsLess` (1)：点数少于3个，无法构成平面
- `SpreadStateAreaCross` (2)：线段交叉，产生多块区域

## 🛠️ 系统要求

- iOS 9.0+
- Xcode 11.0+
- Objective-C

## 📄 许可证

Copyright © 2020 Tony. All rights reserved.

## 🔗 相关链接

- GitHub: https://github.com/liangmingzhe/drawRectangle.git

## 📝 更新日志

### 最新优化

- ✅ 优化拖动效果，修复增量计算问题
- ✅ 改进边界检测逻辑，提升准确性
- ✅ 优化性能，减少不必要的重绘
- ✅ 修复坐标显示bug
- ✅ 改进代码质量和可维护性

---

**开发者**: benjaminlmz@qq.com  
**创建时间**: 2020/3/9
