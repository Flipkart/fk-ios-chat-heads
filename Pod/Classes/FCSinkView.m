//
//  FCSinkView.m
//  Pods
//
//  Created by Rajat Kumar Gupta on 18/09/15.
//
//

#import "FCSinkView.h"

@implementation FCSinkView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGFloat width = CGRectGetWidth(rect);
    
    CGPoint c = CGPointMake(width/2, width);

    CGContextRef cx = UIGraphicsGetCurrentContext();
    
    [[UIColor clearColor] set];
    CGContextFillRect(cx, rect);
    
    CGContextSaveGState(cx);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGFloat comps[] = {0.2, 0.2, 0.2, 1.0,
                       0.0, 0.0, 0.0, 0.0};
    CGFloat locs[] = {0,1};
    CGGradientRef g = CGGradientCreateWithColorComponents(space, comps, locs, 2);
    
    CGContextDrawRadialGradient(cx, g, c, width/2, CGPointMake(c.x, c.y + width), 2*width, 0);
    
    CGContextRestoreGState(cx);
}

@end
