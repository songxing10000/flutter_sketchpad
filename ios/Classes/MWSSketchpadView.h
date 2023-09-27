//
//  MWSSketchpadView.h
//
//  Created by 马文帅 on 2018/12/15.
//  Copyright © 2018年 mawenshuai. All rights reserved.
//  https://github.com/mws100/MWSSketchpadView

#import <UIKit/UIKit.h>

typedef void(^MWSSketchpadViewDispearHandler)(NSString *jsonString);
 
@interface MWSSketchpadView : UIView

/** 单例 */
+ (instancetype)shareInstance;

/** 横向滚动页数 默认3页 */
@property (nonatomic, assign) NSUInteger horizontalPage;
/** 纵向滚动页数 默认3页 */
@property (nonatomic, assign) NSUInteger verticalPage;
 
- (void)showWithJsonString:(NSString *)jsonString dispearHandler:(MWSSketchpadViewDispearHandler)dispearHandler;
 

- (void)setLineWidth:(CGFloat)lineWidth lineStrokeColor:(UIColor *)lineStrokeColor autoChangeStatusBarStyle:(BOOL)autoChangeStatusBarStyle;
/** 线的宽度, 默认:3point */
@property (nonatomic, assign) CGFloat lineWidth;
/** 线的颜色, 默认:#000000*/
@property (nonatomic, strong) UIColor *lineStrokeColor;
/** 是否自动改变StatusBarStyle, 默认:NO */
@property (nonatomic, assign) BOOL autoChangeStatusBarStyle;

/** 视图消失的回调 */
@property (nonatomic, copy) MWSSketchpadViewDispearHandler dispearHandler;

@end
