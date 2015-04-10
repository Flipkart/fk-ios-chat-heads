//
//  FCConstants.h
//  FCChatHead
//
//  Created by Rajat Gupta on 02/24/2015.
//  Copyright (c) 2014 Rajat Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define CHAT_HEAD_DIMENSION             40.0
#define CHAT_HEAD_IMAGE_INSET           0.0
#define CHAT_HEAD_SHADOW_RADIUS         2.0
#define CHAT_HEAD_DECELERATION_X        1200.0
#define CHAT_HEAD_DECELERATION_Y        1200.0
#define CHAT_HEAD_DECELERATION          {CHAT_HEAD_DECELERATION_X, CHAT_HEAD_DECELERATION_Y};
#define CHAT_HEAD_MARGIN_X              5.0
#define CHAT_HEAD_MARGIN_Y              20.0


typedef enum {
    kDirectionLeft     = -1,
    kDirectionRight    =  1
} HorizontalMotionDirection;

typedef enum {
    kDirectionUp     = -1,
    kDirectionDown   =  1
} VerticalMotionDirection;




#define ChatHeadsController         [FCChatHeadsController chatHeadsController]


#define SCREEN_BOUNDS                   ([[UIScreen mainScreen] bounds])
#define DEFAULT_CHAT_HEAD_FRAME         (CGRectMake(SCREEN_BOUNDS.size.width - CHAT_HEAD_DIMENSION - CHAT_HEAD_MARGIN_X,    \
                                                    SCREEN_BOUNDS.size.height - CHAT_HEAD_DIMENSION - CHAT_HEAD_MARGIN_Y,   \
                                                    CHAT_HEAD_DIMENSION,                                                    \
                                                    CHAT_HEAD_DIMENSION))
#define CHAT_HEAD_STACK_STEP_X          2.0
#define CHAT_HEAD_STACK_STEP_Y          2.0

#define SHOW_CHAT_HEAD_SINK_TIMEOUT     0.5


#define CHAT_HEAD_SINK_HEIGHT           (SCREEN_BOUNDS.size.height*0.2)
#define CHAT_HEAD_SINK_WIDTH            (SCREEN_BOUNDS.size.width*0.8)
#define CHAT_HEAD_SINK_ZONE             CGRectMake((SCREEN_BOUNDS.size.width - CHAT_HEAD_SINK_WIDTH)/2,                     \
                                                    (SCREEN_BOUNDS.size.height - CHAT_HEAD_SINK_HEIGHT),                    \
                                                    CHAT_HEAD_SINK_WIDTH,                                                   \
                                                    CHAT_HEAD_SINK_HEIGHT)
//#define <#macro#>

#define MAX_NUMBER_OF_CHAT_HEADS        3


#define CHAT_HEAD_EXPANDED_FRAME(indentation)   CGRectMake(SCREEN_BOUNDS.size.width -                                       \
                                                            (indentation)*(CHAT_HEAD_DIMENSION + CHAT_HEAD_MARGIN_X),       \
                                                            CHAT_HEAD_MARGIN_Y,                                             \
                                                            CHAT_HEAD_DIMENSION,                                            \
                                                            CHAT_HEAD_DIMENSION)


extern NSString *ChatHeadAdditionAnimationKey;
extern NSString *ChatHeadMotionEndAnimationKey;
extern NSString *ChatHeadRemovalAnimationKey;


typedef struct FCRay {
    CGPoint startPoint;
    CGPoint toPoint;
} FCRay;


FCRay FCRayCreate(CGPoint startPoint, CGPoint toPoint);
BOOL FCRayIntersectsWithRect(FCRay ray, CGRect rect);
CGPoint FCRayIntersectionPointWithRect(FCRay ray, CGRect rect);
BOOL FCPointsEqual(CGPoint point1, CGPoint point2);
BOOL FCPointIsInvalid(CGPoint point);


typedef enum PositionOnLine
{
    kPointPositionNone      = -2,
    kPointPositionPositive  = 0,
    kPointPositionNegative  = 1
} PointPositionOnLine;


extern CGPoint FCPointInvalid;





