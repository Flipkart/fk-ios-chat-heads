//
//  FCChatHeadsController.m
//  FCChatHead
//
//  Created by Rajat Gupta on 02/24/2015.
//  Copyright (c) 2014 Rajat Gupta. All rights reserved.
//

#import "FCChatHeadsController.h"
#import "FCChatHead.h"
#import "CMPopTipView.h"
#import <pop/POP.h>


static FCChatHeadsController *_chatHeadsController;

@interface FCChatHeadsController() <CMPopTipViewDelegate>
{
    CGRect _activeChatHeadFrameInStack;
    CGRect _sinkCrossPeriphery;
//    NSInteger _draggingChatHeadOriginalSubviewIndex;
}

@property (nonatomic, assign) BOOL isExpanded;

@property (nonatomic, weak) FCChatHead *activeChatHead;

@property (nonatomic, strong) NSMutableArray *chatHeads;
@property (nonatomic, strong) NSTimer *showChatHeadSinkTimer;

@property (nonatomic, strong) UIView *sinkView;

@property (nonatomic, strong) CMPopTipView *popoverView;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIImageView *sinkCross;

@end






@implementation FCChatHeadsController


+ (instancetype)chatHeadsController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            _chatHeadsController = [FCChatHeadsController new];
    });
    
    return _chatHeadsController;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.activeChatHead = nil;
    self.isExpanded = NO;
    self.chatHeads = [NSMutableArray array];
    _activeChatHeadFrameInStack = CGRectZero;
}

#pragma mark -
#pragma mark - Chatheads manipulation

- (void)presentChatHeadWithView:(UIView *)view chatID:(NSString *)chatID
{
    if ([self bringChatHeadToFrontIfAlreadyPresent:chatID])
        return;
    
    FCChatHead *aChatHead = [FCChatHead chatHeadWithView:view chatID:chatID delegate:self];
    aChatHead.frame = [self frameForNewChatHead];
    aChatHead.chatID = chatID;
    
    [self presentChatHead:aChatHead];
}

- (void)presentChatHeadWithImage:(UIImage *)image chatID:(NSString *)chatID
{
    if ([self bringChatHeadToFrontIfAlreadyPresent:chatID])
        return;
    
    FCChatHead *aChatHead = [FCChatHead chatHeadWithImage:image chatID:chatID delegate:self];
    aChatHead.frame = [self frameForNewChatHead];
    aChatHead.chatID = chatID;
    
    [self presentChatHead:aChatHead];
}

- (void)presentChatHead:(FCChatHead *)aChatHead
{
    if (!self.headSuperView)
    {
        UIView *rootView = [[[UIApplication sharedApplication] delegate] window];//[[[[UIApplication sharedApplication] delegate] window] rootViewController].view;
        self.headSuperView = rootView;
    }
    
    [self setIndentationLevelsForNewChatHead:aChatHead];
    
    if (self.chatHeads.count == MAX_NUMBER_OF_CHAT_HEADS)
    {
        [self addRemovalAnimationForChatHead:[self chatHeadToBeRemoved]];
    }
    
    if (!self.isExpanded)
    {
        [self.chatHeads addObject:aChatHead];
        [self layoutChatHeads:YES];
        
        aChatHead.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        [self.headSuperView addSubview:aChatHead];
        [self.headSuperView bringSubviewToFront:aChatHead];
        
        self.activeChatHead = aChatHead;
    }
    else
    {
        BOOL firstChatHead = self.chatHeads.count == 0;
        
        [self.chatHeads insertObject:aChatHead atIndex:firstChatHead ? 0 : self.chatHeads.count - 1];
        [self layoutChatHeads:YES];
        
        aChatHead.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        [self.headSuperView addSubview:aChatHead];
        [self.headSuperView bringSubviewToFront:self.activeChatHead];
        
        if (firstChatHead)
            self.activeChatHead = aChatHead;
    }
    
    [self logChatHeadsStack];
    
    [self animateChatHeadPresentation:aChatHead];
}

- (void)logChatHeadsStack
{
    NSLog(@"=====================================================================================\n\n");
    for (int count = 0; count < self.chatHeads.count; count++)
    {
        NSLog(@"index = %d, chat head ID = %@", count, [self.chatHeads[count] chatID]);
    }
    NSLog(@"\n=====================================================================================\n\n");
}

- (void)setIndentationLevelsForNewChatHead:(FCChatHead *)chatHead
{
    if (self.isExpanded)
    {
        if (self.chatHeads.count < MAX_NUMBER_OF_CHAT_HEADS)
        {
            chatHead.indentationLevel = [self maxIndentationLevel] + (self.chatHeads.count > 0)*1;
        }
        else
        {
            FCChatHead *chatHeadToBeRemoved = [self chatHeadToBeRemoved];
            
                if (chatHeadToBeRemoved.indentationLevel > self.activeChatHead.indentationLevel)
                {
                    chatHead.indentationLevel = self.activeChatHead.indentationLevel + 1;
                    for (FCChatHead *aChatHead in self.chatHeads)
                    {
                        if ((chatHead == aChatHead) || (self.activeChatHead == aChatHead) || (chatHeadToBeRemoved == aChatHead)) continue;
                        
                        if ((aChatHead.indentationLevel < chatHeadToBeRemoved.indentationLevel) && (aChatHead.indentationLevel > self.activeChatHead.indentationLevel))
                            aChatHead.indentationLevel = aChatHead.indentationLevel + 1;
                    }
                }
                else
                {
                    chatHead.indentationLevel = self.activeChatHead.indentationLevel - 1;
                    for (FCChatHead *aChatHead in self.chatHeads)
                    {
                        if ((chatHead == aChatHead) || (self.activeChatHead == aChatHead) || (chatHeadToBeRemoved == aChatHead)) continue;
                        
                        if ((aChatHead.indentationLevel > chatHeadToBeRemoved.indentationLevel) && (aChatHead.indentationLevel < self.activeChatHead.indentationLevel))
                            aChatHead.indentationLevel = aChatHead.indentationLevel - 1;
                    }
                }
        }
    }
}

- (NSUInteger)maxIndentationLevel
{
    NSUInteger indentationLevel = 1;
    
    FCChatHead *chatHeadWithMaxIndentation = [self chatHeadWithMaxIndentation];
    if (chatHeadWithMaxIndentation)
    {
        indentationLevel = chatHeadWithMaxIndentation.indentationLevel;
    }
    
    return indentationLevel;
}

- (FCChatHead *)chatHeadToBeRemoved
{
    return self.chatHeads.count >= MAX_NUMBER_OF_CHAT_HEADS ? self.chatHeads[0] : nil;
}

- (FCChatHead *)chatHeadWithMaxIndentation
{
    FCChatHead *chatHead = nil;
    
    NSPredicate *maxIndentationPredicate = [NSPredicate predicateWithFormat:@"SELF.indentationLevel == %@.@max.indentationLevel", self.chatHeads];
    NSArray *resutArray = [self.chatHeads filteredArrayUsingPredicate:maxIndentationPredicate];
    if (resutArray.count)
    {
        chatHead = (FCChatHead *)resutArray[0];
    }
    
    return chatHead;
}

- (FCChatHead *)chatHeadWithIndentation:(NSUInteger)indentationLevel
{
    FCChatHead *chatHead = nil;
    
    NSPredicate *indentationPredicate = [NSPredicate predicateWithFormat:@"SELF.indentationLevel == %d", indentationLevel];
    NSArray *resutArray = [self.chatHeads filteredArrayUsingPredicate:indentationPredicate];
    if (resutArray.count)
    {
        chatHead = (FCChatHead *)resutArray[0];
    }
    
    return chatHead;
}

- (CGRect)frameForNewChatHead
{
    CGRect frame = DEFAULT_CHAT_HEAD_FRAME;
    
    if (!self.isExpanded)
    {
        if (self.chatHeads.count)
        {
            frame = [(FCChatHead *)[self.chatHeads lastObject] frame];
        }
    }
    else
    {
        if (self.chatHeads.count < MAX_NUMBER_OF_CHAT_HEADS)
        {
            frame.origin.x = self.headSuperView.bounds.size.width - ((self.chatHeads.count + 1)*(CHAT_HEAD_DIMENSION + CHAT_HEAD_MARGIN_X));
            frame.origin.y = CHAT_HEAD_MARGIN_Y;
        }
        else
        {
            FCChatHead *chatHeadToBeRemoved = [self chatHeadToBeRemoved];
            frame = chatHeadToBeRemoved.frame;
                if (chatHeadToBeRemoved.indentationLevel > self.activeChatHead.indentationLevel)
                {
                    frame.origin.x = self.headSuperView.bounds.size.width - ((self.activeChatHead.indentationLevel + 1)*(CHAT_HEAD_DIMENSION + CHAT_HEAD_MARGIN_X));
                    frame.origin.y = CHAT_HEAD_MARGIN_Y;
                }
                else
                {
                    frame.origin.x = self.headSuperView.bounds.size.width - ((self.activeChatHead.indentationLevel - 1)*(CHAT_HEAD_DIMENSION + CHAT_HEAD_MARGIN_X));
                    frame.origin.y = CHAT_HEAD_MARGIN_Y;
                }
        }
    }
    return frame;
}

- (BOOL)bringChatHeadToFrontIfAlreadyPresent:(NSString *)chatID
{
    BOOL success = NO;
    FCChatHead *chatHead = [self chatHeadWithID:chatID];
    if (chatHead)
    {
        success = YES;
        [self bringChatHeadToTop:chatHead];
    }
    return success;
}


- (void)bringChatHeadToTop:(FCChatHead *)chatHead
{
    if (!self.isExpanded)
    {
        self.activeChatHead = chatHead;
        chatHead.frame = [(FCChatHead *)[self.chatHeads lastObject] frame];
        [self.chatHeads removeObject:chatHead];
        [self.chatHeads addObject:chatHead];
    }
    else
    {
        if (chatHead != self.activeChatHead)
        {
            NSUInteger index = self.chatHeads.count == 0 ? 0 : [self.chatHeads indexOfObject:self.activeChatHead] - 1;
            [self.chatHeads removeObject:chatHead];
            [self.chatHeads insertObject:chatHead atIndex:index];
        }
    }
    
    [self layoutChatHeads:YES];
    
    chatHead.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [self.headSuperView bringSubviewToFront:chatHead];
    
    [self animateChatHeadPresentation:chatHead];

    [self logChatHeadsStack];
}


- (BOOL)chatHeadAlreadyPresent:(NSString *)chatID
{
    FCChatHead *chatHead = [self chatHeadWithID:chatID];
    return chatHead != nil;
}


- (FCChatHead *)chatHeadWithID:(NSString *)chatID
{
    FCChatHead *result = nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.chatID LIKE[c] %@", chatID];
    NSArray *resultArray = [self.chatHeads filteredArrayUsingPredicate:predicate];
    if (resultArray.count)
    {
        result = [resultArray firstObject];
    }
    return result;
}


- (void)layoutChatHeads:(BOOL)animated
{
    if (!self.isExpanded)
    {
        CGRect frame;

        if (CGRectEqualToRect(_activeChatHeadFrameInStack, CGRectZero))
        {
            frame = [(FCChatHead *)[self.chatHeads lastObject] frame];
        }
        else
        {
            frame = _activeChatHeadFrameInStack;
            _activeChatHeadFrameInStack = CGRectZero;
        }
        
        NSUInteger indentationLevel = 1;
        for (NSInteger count = self.chatHeads.count - 1; count >= 0; count--)
        {
            FCChatHead *chatHead = (FCChatHead *)self.chatHeads[count];
            
            chatHead.hierarchyLevel = self.chatHeads.count - 1 - count;
            chatHead.indentationLevel = indentationLevel++;
            
            if (animated)
            {
                [UIView animateWithDuration:0.357f
                                 animations:^{
                                     [chatHead setFrame:frame];
                                 }];
            }
            else
                [chatHead setFrame:frame];
            
            frame.origin.x += CHAT_HEAD_STACK_STEP_X;
            frame.origin.y += CHAT_HEAD_STACK_STEP_Y;
        }
    }
    else
    {
        CGRect frame = DEFAULT_CHAT_HEAD_FRAME;
        frame.origin.y = CHAT_HEAD_MARGIN_Y;
        
        for (FCChatHead *chatHead in self.chatHeads)
        {
            chatHead.hierarchyLevel = 0;
            
            frame.origin.x = self.headSuperView.bounds.size.width - (chatHead.indentationLevel*(CHAT_HEAD_MARGIN_X + CHAT_HEAD_DIMENSION));
            
            if (animated)
            {
                [UIView animateWithDuration:0.357f
                                 animations:^{
                                     [chatHead setFrame:frame];
                                 }
                                 completion:^(BOOL finished) {
                                     if (!self.popoverView)
                                     {
                                         [self presentPopover];
                                     }
                                 }];
            }
            else
                [chatHead setFrame:frame];
        }
    }
}


- (void)animateChatHeadPresentation:(FCChatHead *)aChatHead
{
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(20.0, 20.0)];
    scaleAnimation.name = ChatHeadAdditionAnimationKey;
    scaleAnimation.dynamicsTension = 100.0;
    scaleAnimation.dynamicsFriction = 50.0f;
    scaleAnimation.springBounciness = 12.5f;
    scaleAnimation.springSpeed = 20.0;
    scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    [aChatHead.layer pop_addAnimation:scaleAnimation forKey:ChatHeadAdditionAnimationKey];
}

- (void)finishPanEndMotionWithVelocity:(CGPoint)panEndVelocity forChatHead:(FCChatHead *)chatHead
{
    NSArray *chatHeadsToAnimate = self.isExpanded ? @[chatHead] : self.chatHeads;
    
    BOOL removeChatHead;
    CGPoint proposedEndPoint = [self proposedPanMotionEndPointForChatHead:chatHead
                                                             withVelocity:panEndVelocity
                                                              shoudRemove:&removeChatHead];
    if (self.isExpanded)
    {
        if (removeChatHead)
        {
            NSUInteger activeIndentation = chatHead.indentationLevel;
            for (FCChatHead *aChatHead in self.chatHeads)
            {
                if (aChatHead.indentationLevel > activeIndentation)
                {
                    aChatHead.indentationLevel--;
                }
            }
            if (self.chatHeads.count == 1)
            {
                [self removeBackgroundView:YES];
            }
        }
        else
        {
            NSUInteger finalIndentation = (SCREEN_BOUNDS.size.width - chatHead.center.x)/(CHAT_HEAD_DIMENSION + CHAT_HEAD_MARGIN_X) + 1;
            finalIndentation = MIN(self.chatHeads.count, finalIndentation);
            finalIndentation = MAX(finalIndentation, 1);
            proposedEndPoint.x = SCREEN_BOUNDS.size.width - finalIndentation*(CHAT_HEAD_DIMENSION + CHAT_HEAD_MARGIN_X) + CHAT_HEAD_DIMENSION/2;
            proposedEndPoint.y = CHAT_HEAD_MARGIN_Y + CHAT_HEAD_DIMENSION/2;
        }
    }
    
    for (NSInteger count = chatHeadsToAnimate.count - 1; count >= 0; count--)
    {
        POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
        positionAnimation.velocity = [NSValue valueWithCGPoint:panEndVelocity];
        positionAnimation.dynamicsTension = 10000.0;
        positionAnimation.name = ChatHeadMotionEndAnimationKey;
        positionAnimation.dynamicsFriction = 1.0f;
        positionAnimation.springBounciness = 12.5f;
        positionAnimation.springSpeed = 20.0;
        positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(proposedEndPoint.x, proposedEndPoint.y)];
        
        proposedEndPoint.x += (!removeChatHead)*CHAT_HEAD_STACK_STEP_X;
        proposedEndPoint.y += (!removeChatHead)*CHAT_HEAD_STACK_STEP_Y;
        
        FCChatHead *aChatHead = (FCChatHead *)chatHeadsToAnimate[count];
        
        if (removeChatHead)
        {
            positionAnimation.springBounciness = 5.0;
            positionAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
                [self addRemovalAnimationForChatHead:aChatHead];
                
                [self removeSink:YES];
            };
        }
        else
        {
            positionAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
                if (self.isExpanded)
                {
//                    [aChatHead removeFromSuperview];
//                    [self.headSuperView insertSubview:aChatHead atIndex:_draggingChatHeadOriginalSubviewIndex];
                    if (!self.popoverView)
                    {
                        [self presentPopover];
                    }
                }
            };
            
            [self removeSink:YES];
        }
        
        [[aChatHead layer] pop_addAnimation:positionAnimation forKey:ChatHeadMotionEndAnimationKey];
    }
}

- (CGPoint)proposedPanMotionEndPointForChatHead:(FCChatHead *)chatHead
                                   withVelocity:(CGPoint)panEndVelocity
                                    shoudRemove:(BOOL *)removeChatHead
{
    HorizontalMotionDirection horizontalDirection = panEndVelocity.x < 0 ? kDirectionLeft : kDirectionRight;
    VerticalMotionDirection verticalDirection = panEndVelocity.y < 0 ? kDirectionUp : kDirectionDown;
    
    CGPoint initialPosition = chatHead.center;
    CGRect superBounds = chatHead.superview.bounds;
    
    double minX = CHAT_HEAD_DIMENSION/2 + CHAT_HEAD_MARGIN_X;
    double maxX = superBounds.size.width - CHAT_HEAD_MARGIN_X - CHAT_HEAD_DIMENSION/2;
    double minY = CHAT_HEAD_DIMENSION/2 + CHAT_HEAD_MARGIN_Y;
    double maxY = superBounds.size.height - CHAT_HEAD_MARGIN_Y - CHAT_HEAD_DIMENSION/2;
    
    double proposedTimeForCompletion = fabs(panEndVelocity.x)/CHAT_HEAD_DECELERATION_X;
    
    double proposedFinalX = panEndVelocity.x*proposedTimeForCompletion - 0.5*horizontalDirection*CHAT_HEAD_DECELERATION_X*pow(proposedTimeForCompletion, 2.0) + initialPosition.x;
    double proposedFinalY = panEndVelocity.y*proposedTimeForCompletion - 0.5*verticalDirection*CHAT_HEAD_DECELERATION_Y*pow(proposedTimeForCompletion, 2.0) + initialPosition.y;
    
    
    BOOL shouldRemoveChatHead = NO;
    if (self.sinkView.superview)
    {
        if ((proposedFinalY > (SCREEN_BOUNDS.size.height - CHAT_HEAD_SINK_HEIGHT)) && FCRayIntersectsWithRect(FCRayCreate(initialPosition, CGPointMake(proposedFinalX, proposedFinalY)), CHAT_HEAD_SINK_ZONE))
        {
            shouldRemoveChatHead = YES;
            proposedFinalY = self.sinkView.center.y;
            proposedFinalX = self.sinkView.center.x;
            *removeChatHead = shouldRemoveChatHead;
            
            CGPoint proposedEndPoint = CGPointMake(proposedFinalX, proposedFinalY);
            
            return proposedEndPoint;
        }
    }
    
    if (proposedFinalX < superBounds.size.width/2)
    {
        if (proposedFinalX <= minX)
        {
            double velocityAtMinX = -pow(pow(panEndVelocity.x, 2.0) - 2*CHAT_HEAD_DECELERATION_X*(initialPosition.x - minX), 0.5);
            
            double timeTakenToMinX = fabs(velocityAtMinX - panEndVelocity.x)/CHAT_HEAD_DECELERATION_X;
            double yAtMinX = panEndVelocity.y*timeTakenToMinX - 0.5*(CHAT_HEAD_DECELERATION_Y*pow(timeTakenToMinX, 2.0)) + initialPosition.y;
            proposedFinalY = yAtMinX;
        }
        proposedFinalX = minX;
    }
    else
    {
        if (proposedFinalX >= maxX)
        {
            double velocityAtMaxX = pow(pow(panEndVelocity.x, 2.0) - 2*CHAT_HEAD_DECELERATION_X*(maxX - initialPosition.x), 0.5);
            double timeTakenToMaxX = fabs(velocityAtMaxX - panEndVelocity.x)/CHAT_HEAD_DECELERATION_X;
            double yAtMaxX = panEndVelocity.y*timeTakenToMaxX - 0.5*(CHAT_HEAD_DECELERATION_Y*pow(timeTakenToMaxX, 2.0)) + initialPosition.y;
            proposedFinalY = yAtMaxX;
        }
        proposedFinalX = maxX;
    }
    
    if (proposedFinalY < minY)
        proposedFinalY = minY;
    
    if (proposedFinalY > maxY)
        proposedFinalY = maxY;

    *removeChatHead = shouldRemoveChatHead;
    
    CGPoint proposedEndPoint = CGPointMake(proposedFinalX, proposedFinalY);
    
    return proposedEndPoint;
}

- (void)addRemovalAnimationForChatHead:(FCChatHead *)chatHead
{
    chatHead.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.246
                     animations:^{
                         chatHead.transform = CGAffineTransformMakeScale(0.1, 0.1);
                     }
                     completion:^(BOOL finished) {
                         [self removeChatHead:chatHead];
                     }];
    
    [self.chatHeads removeObject:chatHead];
}

- (void)removeChatHead:(FCChatHead *)chatHead
{
    BOOL wasActive = self.activeChatHead == chatHead;
    [chatHead removeFromSuperview];
    if (self.isExpanded)
    {
        [self layoutChatHeads:YES];
        
        if (wasActive)
        {
            self.activeChatHead = nil;
            FCChatHead *chatHead = [self.chatHeads lastObject];
            if (chatHead)
            {
                self.activeChatHead = chatHead;
            }
        }
        if (self.chatHeads.count == 0)
        {
            self.isExpanded = NO;
            _activeChatHeadFrameInStack = CGRectZero;
        }
    }
    else
    {
        self.activeChatHead = nil;
    }
    
    [self logChatHeadsStack];
}

- (void)handleTapOnChatHead:(FCChatHead *)chatHead
{
    if (!self.isExpanded)
    {
        [self insertBackgroundView:YES];
        
        self.isExpanded = YES;
        _activeChatHeadFrameInStack = self.activeChatHead.frame;
        
        [self layoutChatHeads:YES];
    }
    else
    {
        if (chatHead == self.activeChatHead)
        {
            [self removeBackgroundView:YES];
            
            self.isExpanded = NO;
            
            [self layoutChatHeads:YES];
            
            [self dismissPopover];
        }
        else
        {
            self.activeChatHead = chatHead;
            
            [self.headSuperView bringSubviewToFront:self.activeChatHead];
            [self.chatHeads removeObject:chatHead];
            [self.chatHeads addObject:chatHead];
            
            [self presentPopover];
        }
    }
    [self logChatHeadsStack];
}

- (void)insertBackgroundView:(BOOL)animated
{
    if (!self.headSuperView.subviews.count)
        return;
    
    if (!self.backgroundView)
    {
        self.backgroundView = [[UIView alloc] initWithFrame:self.headSuperView.bounds];
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        
        if (animated)
        {
            self.backgroundView.alpha = 0.0;
        }
        
        FCChatHead *lowestChatHead = nil;
        for (NSInteger count = self.headSuperView.subviews.count - 1; count >= 0; count--)
        {
            UIView *subview = self.headSuperView.subviews[count];
            if ([subview isKindOfClass:[FCChatHead class]])
            {
                lowestChatHead = (FCChatHead *)subview;
            }
        }
        
        [self.headSuperView insertSubview:self.backgroundView belowSubview:lowestChatHead];
        
        if (animated)
        {
            [UIView animateWithDuration:0.257
                             animations:^{
                                 self.backgroundView.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
    }
}

- (void)removeBackgroundView:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.257
                         animations:^{
                             self.backgroundView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [self.backgroundView removeFromSuperview];
                             self.backgroundView = nil;
                         }];
    }
    else
    {
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
}

- (void)presentPopover
{
    [self dismissPopover];
    
    UIView *contentView = nil;
    if (self.datasource && [self.datasource respondsToSelector:@selector(chatHeadsController:viewForPopoverForChatHeadWithChatID:)]) {
        contentView = [self.datasource chatHeadsController:self viewForPopoverForChatHeadWithChatID:self.activeChatHead.chatID];
        CGRect frame = [[[[[UIApplication sharedApplication] delegate] window] screen] applicationFrame];
        frame.size.height -= CGRectGetMaxY(self.activeChatHead.frame);
        contentView.frame = frame;
    }
    
    if (contentView)
    {
        self.popoverView = [[CMPopTipView alloc] initWithCustomView:contentView];
    }
    else
    {
        self.popoverView = [[CMPopTipView alloc] initWithTitle:self.activeChatHead.chatID message:@"Your detail view goes here."];
        self.popoverView.titleColor = [UIColor blackColor];
        self.popoverView.textColor = [UIColor blackColor];
    }
    
    self.popoverView.sidePadding = 0.0;
    self.popoverView.topMargin = 0.0;
    self.popoverView.cornerRadius = 0.0;
    self.popoverView.bubblePaddingX = -self.popoverView.cornerRadius;
    self.popoverView.bubblePaddingY = 0.0;
    self.popoverView.delegate = self;
    self.popoverView.backgroundColor = [UIColor whiteColor];
    self.popoverView.has3DStyle = NO;
    self.popoverView.animation = CMPopTipAnimationSlide;
    self.popoverView.hasGradientBackground = NO;
    self.popoverView.disableTapToDismiss = YES;
    self.popoverView.borderColor = [UIColor clearColor];
    self.popoverView.borderWidth = 0.0f;
    self.popoverView.preferredPointDirection = PointDirectionUp;
    [self.popoverView presentPointingAtView:self.activeChatHead inView:self.headSuperView animated:YES];
}

- (void)dismissPopover
{
    if (self.popoverView) {
        [self.popoverView dismissAnimated:YES];
        self.popoverView = nil;
    }
}

#pragma mark -
#pragma mark - FCChatHeadsDelegate


- (void)chatHeadSelected:(FCChatHead *)chatHead
{
    [self handleTapOnChatHead:chatHead];
}

- (void)chatHead:(FCChatHead *)chatHead didObservePan:(UIPanGestureRecognizer *)panGesture
{
    if (!self.isExpanded && chatHead != self.activeChatHead)
        return;
    
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
            [self startSinkTimer];
            
        case UIGestureRecognizerStateChanged:
        {
            NSArray *chatHeadsToMove = nil;
            if (self.isExpanded)
            {
//                _draggingChatHeadOriginalSubviewIndex = [self.chatHeads indexOfObject:chatHead];
                [self.headSuperView bringSubviewToFront:chatHead];
                chatHeadsToMove = @[chatHead];
                [self updateChatHeadsLayoutForDraggingChatHead:chatHead toPosition:[panGesture locationInView:chatHead.superview]];
            }
            else
            {
                chatHeadsToMove = self.chatHeads;
            }
            [self moveChatHeadStack:chatHeadsToMove
                         toLocation:[panGesture locationInView:chatHead.superview]
                           animated:YES];
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            [self stopSinkTimer];
            
            CGPoint velocity = [panGesture velocityInView:chatHead.superview];
            [self finishPanEndMotionWithVelocity:velocity forChatHead:chatHead];
        }
            break;
            
        default:
            break;
    }
}


- (void)updateChatHeadsLayoutForDraggingChatHead:(FCChatHead *)chatHead toPosition:(CGPoint)panPosition
{
    if (chatHead == self.activeChatHead)
    {
        [self dismissPopover];
    }
    
    NSUInteger currentIndentation = (SCREEN_BOUNDS.size.width - panPosition.x)/(CHAT_HEAD_DIMENSION + CHAT_HEAD_MARGIN_X) + 1;
    currentIndentation = MIN(self.chatHeads.count, currentIndentation);
    currentIndentation = MAX(currentIndentation, 1);
    
    if (currentIndentation > chatHead.indentationLevel)
    {
        FCChatHead *chatHeadToMove = [self chatHeadWithIndentation:currentIndentation];
        if (chatHeadToMove && (chatHeadToMove != chatHead))
        {
            if (chatHeadToMove == self.activeChatHead)
            {
                [self dismissPopover];
            }
            
            chatHead.indentationLevel = currentIndentation;
            
            chatHeadToMove.indentationLevel = currentIndentation - 1;
            CGRect frame = CHAT_HEAD_EXPANDED_FRAME(currentIndentation - 1);
            [UIView animateWithDuration:0.2f
                             animations:^{
                                 chatHeadToMove.frame = frame;
                             }];
        }
    }
    if (currentIndentation < chatHead.indentationLevel)
    {
        FCChatHead *chatHeadToMove = [self chatHeadWithIndentation:currentIndentation];
        if (chatHeadToMove && (chatHeadToMove != chatHead))
        {
            if (chatHeadToMove == self.activeChatHead)
            {
                [self dismissPopover];
            }
            
            chatHead.indentationLevel = currentIndentation;
            
            chatHeadToMove.indentationLevel = currentIndentation + 1;
            CGRect frame = CHAT_HEAD_EXPANDED_FRAME(currentIndentation + 1);
            [UIView animateWithDuration:0.2f
                             animations:^{
                                 chatHeadToMove.frame = frame;
                             }];
        }
    }
}

- (void)moveChatHeadStack:(NSArray *)chatHeadsToMove toLocation:(CGPoint)location animated:(BOOL)animated
{
    NSUInteger chatHeads = chatHeadsToMove.count;
    double minDelay = 0.1;
    double delayStep = 0.05;
    double duration = minDelay + chatHeads*delayStep;
    
    CGPoint center = CGPointMake(location.x + (chatHeads - 1)*CHAT_HEAD_STACK_STEP_X, location.y + (chatHeads - 1)*CHAT_HEAD_STACK_STEP_Y);
    
    if (self.sinkView.superview && CGRectContainsPoint(CHAT_HEAD_SINK_ZONE, center))
    {
        center = CGPointMake(CGRectGetMidX(CHAT_HEAD_SINK_ZONE), CGRectGetMidY(CHAT_HEAD_SINK_ZONE));
    }
    for (FCChatHead *chatHead in chatHeadsToMove)
    {
        [UIView animateWithDuration:duration animations:^{
            chatHead.center = center;
        }];
        
        center.x -= CHAT_HEAD_STACK_STEP_X;
        center.y -= CHAT_HEAD_STACK_STEP_Y;
        duration -= delayStep;
    }
}


#pragma mark -
#pragma mark - Timer Methods

- (void)stopSinkTimer
{
    if (self.showChatHeadSinkTimer)
    {
        [self.showChatHeadSinkTimer invalidate];
        self.showChatHeadSinkTimer = nil;
    }
}

- (void)startSinkTimer
{
    [self stopSinkTimer];
    
    self.showChatHeadSinkTimer = [NSTimer scheduledTimerWithTimeInterval:SHOW_CHAT_HEAD_SINK_TIMEOUT
                                                                  target:self
                                                                selector:@selector(showChatHeadSink:)
                                                                userInfo:nil
                                                                 repeats:NO];
}

- (void)showChatHeadSink:(NSTimer *)timer
{
    [self stopSinkTimer];
    [self showSink:YES];
}


#pragma mark -
#pragma mark - Sink methods

- (void)showSink:(BOOL)animated
{
    [self removeSink:NO];
    
    self.sinkView = [UIView new];
    self.sinkView.frame = CGRectMake(self.headSuperView.bounds.origin.x,
                                     self.headSuperView.bounds.size.height - CHAT_HEAD_SINK_HEIGHT,
                                     self.headSuperView.bounds.size.width,
                                     CHAT_HEAD_SINK_HEIGHT);
    self.sinkView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];

    UIImage *sinkCrossImage = [UIImage imageNamed:@"FCChatHeads.bundle/ChatHeadSinkCross"];
    self.sinkCross = [[UIImageView alloc] initWithImage:sinkCrossImage];
    CGRect sinkCrossFrame = CGRectMake(CGRectGetMinX(self.sinkView.frame) + (self.sinkView.frame.size.width - sinkCrossImage.size.width)/2,
                                       CGRectGetMinY(self.sinkView.frame) + (self.sinkView.frame.size.height - sinkCrossImage.size.height)/2,
                                       sinkCrossImage.size.width,
                                       sinkCrossImage.size.height);
    
    self.sinkCross.frame = sinkCrossFrame;
    
    _sinkCrossPeriphery = CGRectInset(sinkCrossFrame, -CGRectGetHeight(sinkCrossFrame)/2, -CGRectGetHeight(sinkCrossFrame)/2);
    
    if (animated)
    {
        self.sinkCross.alpha = 0.0;
        self.sinkView.alpha = 0.0;
    }
    
    [self.headSuperView addSubview:self.sinkView];
    [self.headSuperView addSubview:self.sinkCross];
    
    if (animated)
    {
        [UIView animateWithDuration:0.357
                         animations:^{
                             self.sinkView.alpha = 1.0;
                             self.sinkCross.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)removeSink:(BOOL)animated
{
    [self.headSuperView bringSubviewToFront:self.sinkCross];
    if (animated)
    {
        [UIView animateWithDuration:0.375
                         animations:^{
                             self.sinkView.alpha = 0.0;
                             self.sinkCross.alpha = 0.5;
                             self.sinkCross.transform = CGAffineTransformMakeScale(0.1, 0.1);
                         }
                         completion:^(BOOL finished) {
                             [self.sinkCross removeFromSuperview];
                             self.sinkCross = nil;
                             [self.sinkView removeFromSuperview];
                             self.sinkView = nil;
                         }];
    }
    else
    {
        [self.sinkCross removeFromSuperview];
        self.sinkCross = nil;
        [self.sinkView removeFromSuperview];
        self.sinkView = nil;
    }
}

- (void)setActiveChatHead:(FCChatHead *)activeChatHead
{
    if (_activeChatHead != activeChatHead)
    {
        for (FCChatHead *chatHead in self.chatHeads)
        {
            if (chatHead == activeChatHead)
            {
                _activeChatHead = activeChatHead;
            }
        }
    }
}


#pragma mark -
#pragma mark - CMPopTipViewDelegate

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    self.popoverView = nil;
}

#pragma mark -
#pragma mark - MISC


- (BOOL)fcRay:(FCRay)ray intersectsWithRect:(CGRect)rect
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


@end









