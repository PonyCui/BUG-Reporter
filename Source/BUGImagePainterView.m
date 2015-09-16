//
//  BUGImagePainterView.m
//  BUG Reporter
//
//  Created by 崔 明辉 on 15/9/16.
//  Copyright © 2015年 PonyCui. All rights reserved.
//

#import "BUGImagePainterView.h"

@interface BUGImagePainterView ()

@property (nonatomic, strong) UIBezierPath *bezierPath;

@property (nonatomic, assign) CGPoint lastPoint;

@end

@implementation BUGImagePainterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.bezierPath = [[UIBezierPath alloc] init];
        self.bezierPath.lineWidth = 4.0f;
    }
    return self;
}

- (UIImage *)mergeWithImage:(UIImage *)image {
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext( context );
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIGraphicsPopContext();
    CGFloat ratio = image.size.width / CGRectGetWidth(self.frame);
    UIBezierPath *bezierPath = [self.bezierPath copy];
    [bezierPath applyTransform:CGAffineTransformMakeScale(ratio, ratio)];
    [bezierPath setLineWidth:4.0f * [UIScreen mainScreen].scale];
    [[UIColor redColor] setStroke];
    [bezierPath stroke];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}

- (void)reset {
    self.bezierPath = [[UIBezierPath alloc] init];
    self.bezierPath.lineWidth = 4.0f;
    [self setNeedsDisplay];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.bezierPath moveToPoint:[[touches anyObject] locationInView:self]];
    self.lastPoint = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.bezierPath addLineToPoint:[[touches anyObject] locationInView:self]];
    self.lastPoint = [[touches anyObject] locationInView:self];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [[UIColor redColor] setStroke];
    [self.bezierPath stroke];
}

@end
