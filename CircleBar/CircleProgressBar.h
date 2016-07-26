//
//  CircleProgressBar.h
//  CircleProgressBar
//
//  Created by 袁平华 on 16/4/8.
//  Copyright © 2016年 袁平华. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSString * (^StringGenerationBlock)(CGFloat progress);
typedef NSMutableAttributedString*(^AttributeStringGenerationBlock)(CGFloat progress);


IB_DESIGNABLE
@interface CircleProgressBar : UIView
#pragma mark 可视属性
@property(nonatomic)IBInspectable CGFloat progressBarWidth;
@property(nonatomic)IBInspectable UIColor * progressBarProgressColor;
@property(nonatomic)IBInspectable UIColor * progressBarTrackColor;
@property(nonatomic)IBInspectable CGFloat startAngle;
@property(nonatomic)IBInspectable BOOL hintHidden;
@property(nonatomic)IBInspectable CGFloat hintViewSpace;
@property(nonatomic)IBInspectable  UIColor* hintViewBackgroundColor;
@property(nonatomic)IBInspectable UIFont * hintTextFont;
@property(nonatomic)IBInspectable UIColor * hintTextColor;

@property(nonatomic,readonly)IBInspectable CGFloat progress;

@property(nonatomic,readonly)BOOL isAnimating;


#pragma mark 设置提示内容
-(void)setHintTextGenerationBlock:(StringGenerationBlock)genarationBlock;
-(void)setHintAttributedGenarationBlock:(AttributeStringGenerationBlock)genarationBlock;
-(void)setProgress:(CGFloat)progress animated:(BOOL)animated;
-(void)setProgress:(CGFloat)progress animated:(BOOL)animated duration:(CGFloat)duration;
-(void)stopAnimation;

@end
