//
//  ICMessageBackgroundView.m
//  Intercambio
//
//  Created by Tobias Kräntzer on 15.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICMessageBackgroundView.h"

@interface ICMessageBackgroundView () {
    CAShapeLayer *_borderLayer;
    UIColor *_backgroundColor;
}

@end

@implementation ICMessageBackgroundView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [super setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGRect borderRect = CGRectInset(self.bounds, 1, 1);

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:borderRect
                                               byRoundingCorners:self.roundedCorners
                                                     cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)];

    path.lineCapStyle = kCGLineCapRound;
    path.lineWidth = 2;

    CGFloat pattern[] = {4, 5};

    switch (self.borderStyle) {
    case ICMessageBackgroundViewBorderStyleDashed:
        [path setLineDash:pattern count:2 phase:0];

    case ICMessageBackgroundViewBorderStyleSolid:
        [self.borderColor setStroke];
        [path stroke];
        break;

    case ICMessageBackgroundViewBorderStyleNone:
    default:
        [_backgroundColor setStroke];
        [path stroke];
        break;
    }

    [_backgroundColor setFill];
    [path fill];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor
{
    return _backgroundColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (_cornerRadius != cornerRadius) {
        _cornerRadius = cornerRadius;
        [self setNeedsDisplay];
    }
}

- (void)setRoundedCorners:(UIRectCorner)roundedCorners
{
    if (_roundedCorners != roundedCorners) {
        _roundedCorners = roundedCorners;
        [self setNeedsDisplay];
    }
}

@end
