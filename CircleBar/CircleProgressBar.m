//
//  CircleProgressBar.m
//  CircleProgressBar
//
//  Created by 袁平华 on 16/4/8.
//  Copyright © 2016年 袁平华. All rights reserved.
//

#import "CircleProgressBar.h"

#define DEGREES_TO_RADIANS(angle) ((angle)/180.0*M_PI)
#pragma mark - 进度条默认设置
#define DefaultProgressBarProgressColor [UIColor colorWithRed:0.71 green:0.099 blue:0.099 alpha:0.7]
#define DefaultProgressBarTrackColor [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]
const CGFloat DefaultProgressBarWidth = 33.0f;

#pragma mark - 提示视图设置
#define DefaultHintBackgroundColor [UIColor colorWithWhite:0 alpha:0.7]
#define DefaultHintTextFont [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:30.0f]
#define DefaultHintTextColor [UIColor whiteColor]
const CGFloat DefaultHintSpacing = 20.0f;

const StringGenerationBlock defaultHintTextGenerationBlock =^NSString*(CGFloat progress){
    return [NSString stringWithFormat:@"%.0f%%",progress*100];
};

// Animation Constants
const CGFloat AnimationChangeTimeDuration = 0.2f;
const CGFloat AnimationChangeTimeStep = 0.01f;

@interface CircleProgressBar (private)
-(CGFloat)progressAccordingToBounds:(CGFloat)progress;

-(void)drawBackGround:(CGContextRef)context;

#pragma mark progressbar
-(UIColor*)progressBarProgressColorForDrawing;
-(UIColor*)progressBarTrackColorForDrawing;
-(CGFloat)progressBarWidthForDrawing;
-(void)drawProgressBar:(CGContextRef)context progressAngle:(CGFloat)progressAngle center:(CGPoint)center radius:(CGFloat)radius;

#pragma mark hintView
-(CGFloat)hintViewSpacingForDrawing;
-(UIColor*)hintViewBackgroundColorForDrawing;
-(UIFont*)hintTextFontForDrawing;
-(UIColor*)hintTextColorForDrawing;
-(NSString*)stringRepresentationOfProgress:(CGFloat)progress;
-(void)drawSimpleHintTextAtCenter:(CGPoint)center;
-(void)drawAttributeHintTextCenter:(CGPoint)center;
-(void)drawHint:(CGContextRef)context center:(CGPoint)center radius:(CGFloat)radius;

#pragma mark - animation
-(void)aniationProgressBarChangeFrom:(CGFloat)startprogress to:(CGFloat)endProgress duration:(CGFloat)duration;
-(void)updateProgressBarForAnimation;
@end



@implementation CircleProgressBar
{
    NSTimer * _animationTimer;
    CGFloat _currentAnimationProgress,_startProgress,_endProgress,_animationProgressStep;
    StringGenerationBlock  _hintTextGenerationBlock;
    AttributeStringGenerationBlock _hintAttributeTextGenerationBlock;
}
#pragma mark - 私有方法


#pragma mark  - 接口方法
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated{
    //设置进度条
    [self setProgress:progress animated:animated duration:AnimationChangeTimeDuration];
}
-(void)setProgress:(CGFloat)progress animated:(BOOL)animated duration:(CGFloat)duration{
    //TODO::设置进度条
    progress  =[self progressAccordingToBounds:progress];
    if (_progress==progress) {
        return ;
    }
    [_animationTimer invalidate];
    _animationTimer = nil;
    if (animated) {
        [self aniationProgressBarChangeFrom:_progress to:progress duration:duration];
    }else{
        _progress = progress;
        [self setNeedsDisplay];
    }
    
    
}
-(BOOL)isAnimating{
    // TODO::是否在进行动画
    return _animationTimer!=nil;
}
-(void)stopAnimation{
    //TODO::停止动画
    if (!self.isAnimating) {
        return;
    }
    [_animationTimer invalidate];
    _animationTimer = nil;
    _progress = _endProgress;
    [self setNeedsDisplay];
}
-(void)setHintTextGenerationBlock:(StringGenerationBlock)genarationBlock{
    //TODO::设置提示语
    _hintTextGenerationBlock = genarationBlock;
    [self setNeedsDisplay];
}
-(void)setHintAttributedGenarationBlock:(AttributeStringGenerationBlock)genarationBlock{
    _hintAttributeTextGenerationBlock = genarationBlock;
    [self setNeedsDisplay];
    //TODO::设置属性提示语
}

#pragma mark - 重写属性设置方法
-(void)setProgressBarWidth:(CGFloat)progressBarWidth{
    //TODO::设置进度条的宽度
    _progressBarWidth = progressBarWidth;
    [self setNeedsDisplay];
}
-(void)setProgressBarProgressColor:(UIColor *)progressBarProgressColor{
    //TODO::设置进度条的颜色
    _progressBarProgressColor = progressBarProgressColor;
    [self setNeedsDisplay];
}
-(void)setProgressBarTrackColor:(UIColor *)progressBarTrackColor{
    //TODO::设置进度条
    _progressBarTrackColor  = progressBarTrackColor;
    [self setNeedsDisplay];
}
-(void)setHintHidden:(BOOL)hintHidden{
    //TODO:: 设置是否显示提示
    _hintHidden = hintHidden;
    [self setNeedsDisplay];
}
-(void)setHintViewSpace:(CGFloat)hintViewSpace{
    //TODO:: 设置是提示与进度条的间距
    _hintViewSpace = hintViewSpace;
    [self setNeedsDisplay];
}
-(void)setHintViewBackgroundColor:(UIColor *)hintViewBackgroundColor{
    //TODO:: 设置提示的背景色
    _hintViewBackgroundColor = hintViewBackgroundColor;
    [self setNeedsDisplay];
}
-(void)setHintTextFont:(UIFont *)hintTextFont{
    //TODO:: 设置提示的字体大小
    _hintTextFont = hintTextFont;
    [self setNeedsDisplay];
}
-(void)setHintTextColor:(UIColor *)hintTextColor{
    //TODO:: 设置提示的字体颜色
    _hintTextColor =hintTextColor;
    [self setNeedsDisplay];
}
-(void)setStartAngle:(CGFloat)startAngle{
    //TODO:: 设置进度条的开始角度
    _startAngle = startAngle;
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGPoint innercenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(innercenter.x, innercenter.y);
    CGFloat currentProgressAngle = (_progress*360)+_startAngle;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    [self drawBackGround:context];
    [self drawProgressBar:context progressAngle:currentProgressAngle center:innercenter radius:radius];
    if (!_hintHidden) {
        [self drawHint:context center:innercenter radius:radius];
    }
}
@end

@implementation CircleProgressBar (private)

-(CGFloat)progressAccordingToBounds:(CGFloat)progress{
    //TODO::计算出当前进度
    progress = MIN(progress, 1);
    progress = MAX(progress, 0);
    
    return progress;
}
-(void)drawBackGround:(CGContextRef)context{
    //TODO::绘制背景
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, self.bounds);
}
#pragma mark - 进度条绘制相关函数
-(UIColor *)progressBarProgressColorForDrawing{
    //TODO:: 返回进度条的背景色
    return (_progressBarProgressColor!=nil?_progressBarProgressColor:DefaultProgressBarProgressColor);
}
-(UIColor *)progressBarTrackColorForDrawing{
    //TODO:: 返回进度条轨道的背景色
    return (_progressBarTrackColor!=nil?_progressBarTrackColor:DefaultProgressBarTrackColor);
}
-(CGFloat)progressBarWidthForDrawing{
    //TODO:: 返回进度条的宽度
    
    return (_progressBarWidth>0?_progressBarWidth:DefaultProgressBarWidth);
}
-(void)drawProgressBar:(CGContextRef)context progressAngle:(CGFloat)progressAngle center:(CGPoint)center radius:(CGFloat)radius{
    //TODO::绘制进度条
    //控制进度条的宽度不能大于半径
    CGFloat barWidth = self.progressBarWidthForDrawing;
    if (barWidth> radius) {
        barWidth = radius;
    }
//    绘制进度条
    CGContextSetFillColorWithColor(context, self.progressBarProgressColorForDrawing.CGColor);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(_startAngle), DEGREES_TO_RADIANS(progressAngle), 0);

    CGContextAddArc(context, center.x, center.y, radius- barWidth, DEGREES_TO_RADIANS(progressAngle), DEGREES_TO_RADIANS(_startAngle), 1);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
//    绘制轨道
    CGContextSetFillColorWithColor(context, self.progressBarTrackColorForDrawing.CGColor);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(progressAngle), DEGREES_TO_RADIANS(_startAngle+360), 0);
    CGContextAddArc(context, center.x, center.y, radius-barWidth, DEGREES_TO_RADIANS(_startAngle+360), DEGREES_TO_RADIANS(progressAngle), 1);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
}
#pragma mark - 提示视图相关函数
-(CGFloat)hintViewSpacingForDrawing{
    //TODO::提示视图的间距
    return (_hintViewSpace!=0?_hintViewSpace:DefaultHintSpacing);
}
-(UIColor *)hintViewBackgroundColorForDrawing{
    //TODO::提示视图的背景色
    return (_hintViewBackgroundColor!=nil?_hintViewBackgroundColor:DefaultHintBackgroundColor);
}
-(UIFont *)hintTextFontForDrawing{
    //    TODO::提示文本的字体大小
    return (_hintTextFont?_hintTextFont:DefaultHintTextFont);
}
-(UIColor *)hintTextColorForDrawing{
    //    TODO::提示文本的颜色
    return (_hintTextColor?_hintTextColor:DefaultHintTextColor);
}
-(NSString *)stringRepresentationOfProgress:(CGFloat)progress{
    //    TODO::将进度转成文本显示
    return (_hintTextGenerationBlock?_hintTextGenerationBlock(progress):defaultHintTextGenerationBlock(progress));
}
-(void)drawSimpleHintTextAtCenter:(CGPoint)center{
    //    TODO::绘制简单的文本
    NSString * progressString = [self stringRepresentationOfProgress:_progress];
    CGSize hintTextSize =[progressString boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.hintTextFontForDrawing} context:nil].size;
    [progressString drawAtPoint:CGPointMake(center.x- hintTextSize.width/2, center.y-hintTextSize.height/2) withAttributes:@{NSFontAttributeName:self.hintTextFontForDrawing,NSForegroundColorAttributeName:self.hintTextColorForDrawing}];
    
}
-(void)drawAttributeHintTextCenter:(CGPoint)center{
    //TODO::绘制属性文本
    NSAttributedString * progressString = _hintAttributeTextGenerationBlock(_progress);
    CGSize hintTextSize =[progressString boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesFontLeading context:nil].size;
    [progressString drawAtPoint:CGPointMake(center.x - hintTextSize.width / 2, center.y - hintTextSize.height / 2)];
    
}
-(void)drawHint:(CGContextRef)context center:(CGPoint)center radius:(CGFloat)radius{
    //    TODO::绘制提示视图
    
    CGFloat barWidth = self.progressBarWidthForDrawing;
    if (barWidth+ self.hintViewSpacingForDrawing> radius) {
        return;
    }
    CGContextSetFillColorWithColor(context, self.hintViewBackgroundColorForDrawing.CGColor);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius-barWidth-self.hintViewSpacingForDrawing, DEGREES_TO_RADIANS(0), DEGREES_TO_RADIANS(360), 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    if (_hintAttributeTextGenerationBlock) {
        [self drawAttributeHintTextCenter:center];
    }else{
        [self drawSimpleHintTextAtCenter:center];
    }
}


#pragma mark - ANIMATION
-(void)aniationProgressBarChangeFrom:(CGFloat)startprogress to:(CGFloat)endProgress duration:(CGFloat)duration{
    //    TODO::动画显示进度
    _currentAnimationProgress = _startProgress=  startprogress;
    _endProgress = endProgress;
    _animationProgressStep =(_endProgress -  _startProgress)* AnimationChangeTimeStep/duration;
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:AnimationChangeTimeStep target:self selector:@selector(updateProgressBarForAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_animationTimer forMode:NSRunLoopCommonModes];
}
-(void)updateProgressBarForAnimation{
    //TODO::更新进度
    _currentAnimationProgress+= _animationProgressStep;
    _progress = _currentAnimationProgress;
    if ((_animationProgressStep>0&&_currentAnimationProgress>= _endProgress)||(_animationProgressStep<0 && _currentAnimationProgress<= _endProgress)) {
        [_animationTimer invalidate];
        _animationTimer = nil;
        _progress = _endProgress;
    }
    [self setNeedsDisplay];
}





































@end
