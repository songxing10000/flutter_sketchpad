//
//  MWSSketchpadView.m
//
//  Created by 马文帅 on 2018/12/15.
//  Copyright © 2018年 mawenshuai. All rights reserved.
//

#import "MWSSketchpadView.h"
#import "MWSSketchpadScrollView.h"
#import "MyBezierPath.h"
#define MWSSketchpadPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"MWSSketchpadView.data"]
#define MWSSketchpadImagePath(imgName) [@"MWSSketchpadView.bundle" stringByAppendingPathComponent:imgName]

static NSString *const allPathsArray = @"allPathsArray";

static const CGFloat animationDuration = 0.25;

@interface MWSSketchpadView()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeBtnTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clearBtnTop;
/// 画笔或橡皮擦
@property (weak, nonatomic) IBOutlet UIButton *m_brushOrEraserBtn;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic, strong) MWSSketchpadScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

/** 导航视图的高度 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
/** 存储原来的StatusBarStyle */
@property (nonatomic, assign) UIStatusBarStyle originalStatusBarStyle;

@end

@implementation MWSSketchpadView

+ (instancetype)shareInstance {
    static MWSSketchpadView *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [MWSSketchpadView sketchpadView];
        obj.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    });
    return obj;
}

+ (instancetype)sketchpadView {
    NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
    NSString *classBundlePath = [classBundle pathForResource:@"flutter_sketchpad" ofType:@"bundle"];
    NSBundle *desBundle = [NSBundle bundleWithPath:classBundlePath];
    
    return [[desBundle loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
}

- (void)setLineWidth:(CGFloat)lineWidth lineStrokeColor:(UIColor *)lineStrokeColor autoChangeStatusBarStyle:(BOOL)autoChangeStatusBarStyle {
    self.lineWidth = lineWidth;
    self.lineStrokeColor = lineStrokeColor;
    self.autoChangeStatusBarStyle = autoChangeStatusBarStyle;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    self.scrollView.lineWidth = lineWidth;
}

- (void)setLineStrokeColor:(UIColor *)lineStrokeColor {
    _lineStrokeColor = lineStrokeColor;
    self.scrollView.lineStrokeColor = lineStrokeColor;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}
- (UIImage *)loadImgNamed:(NSString *)imgName {
    NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
    NSString *classBundlePath = [classBundle pathForResource:@"flutter_sketchpad" ofType:@"bundle"];
    NSBundle *desBundle = [NSBundle bundleWithPath:classBundlePath];
    
    if (@available(iOS 13.0, *)) {
        return [UIImage imageNamed:imgName inBundle:desBundle withConfiguration:NULL];
    }
    NSString *imagePath = [desBundle pathForResource:imgName ofType:@"png" inDirectory:nil];
    return [[UIImage alloc] initWithContentsOfFile:imagePath];
    
}
- (void)setupUI {
    
    
    [self.closeButton setImage:[self loadImgNamed:@"x"]
                      forState:UIControlStateNormal];
    
    [self.clearButton setImage: [self loadImgNamed:@"垃圾桶"]
                      forState:UIControlStateNormal];
    
    [self.m_brushOrEraserBtn setImage:[self loadImgNamed:@"橡皮擦"]
                             forState:(UIControlStateNormal)];
    
    self.topViewHeight.constant = [UIApplication sharedApplication].statusBarFrame.size.height + 44;
    [self addSubview:self.scrollView];
    
    self.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.backgroundColor = self.topView.backgroundColor;
    self.closeBtnTop.constant = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.clearBtnTop.constant = [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), self.bounds.size.width, self.bounds.size.height-CGRectGetHeight(self.topView.frame));
    _horizontalPage = _horizontalPage > 0 ? _horizontalPage : 3;
    _verticalPage = _verticalPage > 0 ? _verticalPage : 3;
    
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width*_horizontalPage, self.bounds.size.height*_verticalPage);
}

- (IBAction)toolButtonClick:(UIButton *)sender {
    if (sender == self.m_brushOrEraserBtn) {
        //反撤销
        if(self.scrollView.m_padType == PadTypeBrush){
            self.scrollView.m_padType = PadTypeEraser;
            [self.m_brushOrEraserBtn setImage:[self loadImgNamed:@"画笔"] forState:(UIControlStateNormal)];
        } else if (self.scrollView.m_padType == PadTypeEraser){
            self.scrollView.m_padType = PadTypeBrush;
            [self.m_brushOrEraserBtn setImage:[self loadImgNamed:@"橡皮擦"] forState:(UIControlStateNormal)];
            
        }
    } else if (sender == self.clearButton) {
        //清空
        [self.scrollView clear];
    } else {
        //关闭
        [self disappear];
    }
}
 
- (MyBezierPath *)convertPointsArrayToBezierPath:(NSArray *)pointsArray {
    MyBezierPath *path = [MyBezierPath bezierPath];
    
    for (NSDictionary *pointDict in pointsArray) {
        CGFloat x = [pointDict[@"x"] floatValue];
        CGFloat y = [pointDict[@"y"] floatValue];
        path.lineWidth = [pointDict[@"width"] intValue];
        path.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:[pointDict[@"alpha"] floatValue]];
        CGPoint point = CGPointMake(x, y);
        
        if ([path isEmpty]) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }
    
    return path;
}

- (void)showWithJsonString:(NSString *)jsonString dispearHandler:(MWSSketchpadViewDispearHandler)dispearHandler {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    if (error) {
        // 解析失败，处理错误
        NSLog(@"JSON数据解析失败：%@", error.localizedDescription);
        
        return;
    }
    if (!jsonArray || ![jsonArray isKindOfClass:[NSArray class]]) {
        NSLog(@"JSON数据解析失败：%@", error);
        return;
    }
    
    
    self.dispearHandler = dispearHandler;
    
    NSArray<NSArray<NSDictionary *> *> *all = jsonArray;
    NSMutableArray *a = [NSMutableArray array];
    NSMutableArray *b = [NSMutableArray array];
    
    for (NSArray<NSDictionary *> *aaa in all) {
        MyBezierPath *bbb = [self convertPointsArrayToBezierPath:aaa];
        [a addObject:bbb];
        
    }
    
    
    self.scrollView.m_padType = PadTypeBrush;
    [self.scrollView showAllPaths:a undoPaths:b];
    [self.m_brushOrEraserBtn setImage:[self loadImgNamed:@"橡皮擦"] forState:(UIControlStateNormal)];

    
    self.alpha = 0;
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [rootView addSubview:self];
    self.frame = rootView.bounds;
    
    [UIView transitionWithView:self duration:animationDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    if (self.autoChangeStatusBarStyle) {
        self.originalStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        if (self.originalStatusBarStyle == UIStatusBarStyleLightContent) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        }
    }
}

- (void)disappear {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self convert:self.scrollView.allPathsArray] options:0 error:&error];
    
    if (!jsonData) {
        NSLog(@"转换为JSON数据时出错：%@", error);
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
     
    
    [UIView transitionWithView:self duration:animationDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    if (self.autoChangeStatusBarStyle) {
        if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault && self.originalStatusBarStyle == UIStatusBarStyleLightContent) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }
    }
    
    if (self.dispearHandler) {
        self.dispearHandler(jsonString);
    }
}
- (NSArray *)convert:(NSArray<MyBezierPath *> *)paths {
    NSMutableArray<NSArray<MyBezierPath *> *> *desPathss = [NSMutableArray array];
    for (MyBezierPath *path in paths) {
        [desPathss addObject: [self convertBezierPathToPointsArray:path]];
    }
    return [NSArray arrayWithArray:desPathss];
}
- (NSArray *)convertBezierPathToPointsArray:(MyBezierPath *)path {
    NSMutableArray *pointsArray = [NSMutableArray array];
    
    CGPathApply(path.CGPath, (__bridge void *)(pointsArray), convertPathElementToPointArray);
    [pointsArray enumerateObjectsUsingBlock:^(NSMutableDictionary *muDict, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        muDict[@"width"] = @(path.lineWidth);
        // 定义变量存储RGBA值
        CGFloat red, green, blue, alpha;
        
        // 获取RGBA值
        BOOL success = [path.color getRed:&red green:&green blue:&blue alpha:&alpha];
        
        if (success) {
            muDict[@"red"] = @(red);
            muDict[@"green"] = @(green);
            muDict[@"blue"] = @(blue);
            muDict[@"alpha"] = @(alpha);
         } else {
            NSLog(@"获取颜色值失败");
        }
        
    }];
    return pointsArray;
}

void convertPathElementToPointArray(void *info, const CGPathElement *element) {
    NSMutableArray *pointsArray = (__bridge NSMutableArray *)info;
    
    CGPoint point = element->points[0];
    NSMutableDictionary *pointDictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"x": @(point.x),
        @"y": @(point.y)
        
    }];
    
    [pointsArray addObject:pointDictionary];
}
#pragma mark - lazy loading
- (MWSSketchpadScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[MWSSketchpadScrollView alloc] init];
        __weak typeof(self) wself = self;
        _scrollView.pathsChangeHandle = ^(BOOL isUndo, BOOL isForward) { 
            
        };
    }
    return _scrollView;
}

@end
