//
//  FCConstants.m
//  FCChatHead
//
//  Created by Rajat Gupta on 02/24/2015.
//  Copyright (c) 2014 Rajat Gupta. All rights reserved.
//

#import "FCCHConstants.h"


NSString *ChatHeadAdditionAnimationKey = @"fc.chathead.addition";
NSString *ChatHeadMotionEndAnimationKey = @"fc.chathead.motionEnd";
NSString *ChatHeadRemovalAnimationKey = @"fc.chathead.removal";

CGPoint FCPointInvalid = {-10000, -10000};


BOOL FCPointsEqual(CGPoint point1, CGPoint point2)
{
    BOOL result = (point1.x == point2.x) && (point1.y == point2.y);
    
    return result;
}


BOOL FCPointIsInvalid(CGPoint point)
{
    return FCPointsEqual(point, FCPointInvalid);
}



FCRay FCRayCreate(CGPoint startPoint, CGPoint toPoint)
{
    FCRay aRay = {startPoint, toPoint};
    
    return aRay;
}

BOOL FCRayIntersectsWithRect(FCRay ray, CGRect rect)
{
    BOOL result = NO;
    
    CGPoint topLeft = rect.origin;
    CGPoint topRight = CGPointMake(topLeft.x + CGRectGetWidth(rect), topLeft.y);
    CGPoint bottomLeft = CGPointMake(topLeft.x, topLeft.y + CGRectGetHeight(rect));
    CGPoint bottomRight = CGPointMake(topLeft.x + CGRectGetWidth(rect), topLeft.y + CGRectGetHeight(rect));
    
    NSArray *points = @[[NSValue valueWithCGPoint:topLeft],
                        [NSValue valueWithCGPoint:topRight],
                        [NSValue valueWithCGPoint:bottomLeft],
                        [NSValue valueWithCGPoint:bottomRight]];
    
    PointPositionOnLine previousPosition = kPointPositionNone;
    for (NSValue *pointValue in points)
    {
        CGPoint point = [pointValue CGPointValue];
        int sign = signbit((ray.toPoint.x - ray.startPoint.x)*(point.y - ray.startPoint.y) - (ray.toPoint.y - ray.startPoint.y)*(point.x - ray.startPoint.x));
        PointPositionOnLine position = (sign == 0) ? kPointPositionPositive : kPointPositionNegative;
        
        if (previousPosition == kPointPositionNone)
            previousPosition = position;
        else if (previousPosition != position)
        {
            result = YES;
            break;
        }
    }
    
    return result;
}

CGPoint FCRayIntersectionPointWithRect(FCRay ray, CGRect rect)
{
    CGPoint point = FCPointInvalid;
    
    if (FCRayIntersectsWithRect(ray, rect))
    {
        
    }
    
    return point;
}































