//
//  FCChatHead.m
//  FCChatHead
//
//  Created by Rajat Gupta on 02/24/2015.
//  Copyright (c) 2014 Rajat Gupta. All rights reserved.
//

#import "FCChatHead.h"
#import <pop/POP.h>

@interface FCChatHead () <POPAnimationDelegate>
{
    UIPanGestureRecognizer *_panGesture;
    BOOL _didPan;
}
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *badge;

@end

@implementation FCChatHead

// ---- Using corner radius to make round image right now.
// ---- Will move to a performance efficient method later.

+ (instancetype)chatHeadWithImage:(UIImage *)image
{
    CGRect frame = CGRectMake(0, 0, CHAT_HEAD_DIMENSION, CHAT_HEAD_DIMENSION);
    
    FCChatHead *aChatHead = [[FCChatHead alloc] initWithFrame:frame];
    aChatHead.imageView.image = image;
    
    return aChatHead;
}

+ (instancetype)chatHeadWithImage:(UIImage *)image delegate:(id<FCChatHeadsDelegate>)delegate
{
    FCChatHead *aChatHead = [FCChatHead chatHeadWithImage:image];
    aChatHead.delegate = delegate;
    
    return aChatHead;
}

+ (instancetype)chatHeadWithImage:(UIImage *)image chatID:(NSString *)chatID delegate:(id<FCChatHeadsDelegate>)delegate
{
    FCChatHead *aChatHead = [FCChatHead chatHeadWithImage:image delegate:delegate];
    aChatHead.chatID = chatID;
    
    return aChatHead;
}

+ (instancetype)chatHeadWithView:(UIView *)view chatID:(NSString *)chatID delegate:(id<FCChatHeadsDelegate>)delegate
{
    CGRect frame = CGRectMake(0, 0, CHAT_HEAD_DIMENSION, CHAT_HEAD_DIMENSION);
    
    FCChatHead *aChatHead = [[FCChatHead alloc] initWithFrame:frame];
    aChatHead.delegate = delegate;
    aChatHead.chatID = chatID;
    
    view.frame = frame;
    view.userInteractionEnabled = NO;
    [aChatHead addSubview:view];
    
    return aChatHead;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}


- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    
    //    CGRect bounds = self.bounds;
    //    double radius = self.circular ? CGRectGetHeight(bounds)/2 : 0.0;
    //
    //    self.layer.cornerRadius = radius;
    //
    //    self.layer.shadowColor = [UIColor colorWithWhite:0.1 alpha:0.9].CGColor;
    //    self.layer.shadowOpacity = 1.0;
    //    self.layer.shadowRadius = CHAT_HEAD_SHADOW_RADIUS;
    //
    //    if (self.circular)
    //    {
    //        CGMutablePathRef shadowPath = CGPathCreateMutable();
    //        CGPathMoveToPoint(shadowPath, NULL, radius + CHAT_HEAD_SHADOW_RADIUS/2, radius + CHAT_HEAD_SHADOW_RADIUS/2);
    //
    //        bounds.origin.x += CHAT_HEAD_SHADOW_RADIUS/2;
    //        bounds.origin.y += CHAT_HEAD_SHADOW_RADIUS;
    //
    //        CGPathAddEllipseInRect(shadowPath, NULL, bounds);
    //
    //        self.layer.shadowPath = shadowPath;
    //
    //        CGPathRelease(shadowPath);
    //    }
    
    if (!_panGesture)
    {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:_panGesture];
    }
}


- (UIImageView *)imageView
{
    if (!_imageView)
    {
        CGRect frame = CGRectInset(self.bounds, CHAT_HEAD_IMAGE_INSET, CHAT_HEAD_IMAGE_INSET);
        frame.origin = CGPointMake(CHAT_HEAD_IMAGE_INSET, CHAT_HEAD_IMAGE_INSET);
        
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.autoresizingMask = UIViewAutoresizingNone;
        
        double radius = CGRectGetHeight(frame)/2.0;
        
        _imageView.layer.cornerRadius = radius;
        _imageView.clipsToBounds = YES;
        
        [self addSubview:_imageView];
    }
    
    return _imageView;
}

- (UILabel *)badge
{
    if (!_badge)
    {
        CGRect frame = CGRectMake(self.frame.size.width - 15.0, 0.0, 15.0, 15.0);
        _badge = [UILabel new];
        _badge.frame = frame;
        _badge.layer.cornerRadius = 7.5;
        _badge.layer.masksToBounds = YES;
        _badge.backgroundColor = [UIColor redColor];
        _badge.textColor = [UIColor whiteColor];
        _badge.font = [UIFont boldSystemFontOfSize:12.0];
        _badge.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_badge];
    }
    
    return _badge;
}

- (void)setCircular:(BOOL)circular
{
    if (_circular != circular)
    {
        _circular = circular;
        
        [self setup];
        [self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark - Touch Event/Gesture handlers


- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    if (pan != _panGesture)
        return;
    
    NSLog(@"%s", __func__);
    _didPan = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatHead:didObservePan:)]) {
        [self.delegate chatHead:self didObservePan:pan];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s", __func__);
    [super touchesBegan:touches withEvent:event];
    
    _didPan = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self highlightTouch];
        
    });
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self unhightlight];
        
    });
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self unhightlight];
        
    });
    
    if (!_didPan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatHeadSelected:)]) {
            [self.delegate chatHeadSelected:self];
        }
    }
}

#pragma mark -
#pragma mark - View Layout


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.animating)
    {
        self.badge.hidden = YES;
    }
    else
    {
        self.badge.hidden = (self.unreadCount == 0);
    }
    
    CGSize textSize = [self.badge.text sizeWithFont:self.badge.font constrainedToSize:CGSizeMake(CHAT_HEAD_DIMENSION, CGFLOAT_MAX)];
    CGRect frame = self.badge.frame;
    frame.size.width = textSize.width + 5;
    frame.origin.x = self.frame.size.width - MAX(frame.size.width/2, 15.0);
    self.badge.frame = frame;
}


#pragma mark -
#pragma mark - Misc

// Highlights the touch by giving some visual response to it.
- (void)highlightTouch
{
    //    self.transform = CGAffineTransformMakeScale(0.9, 0.9);
    //    self.imageView.alpha = 0.8f;
    //    self.backgroundColor = [UIColor blackColor];
}

- (void)unhightlight
{
    //    self.transform = CGAffineTransformIdentity;
    //    self.imageView.alpha = 1.0f;
    //    self.backgroundColor = [UIColor clearColor];
}

- (void)setUnreadCount:(NSInteger)unreadCount
{
    if (_unreadCount != unreadCount)
    {
        _unreadCount = unreadCount;
        
        if (_unreadCount == 0)
        {
            self.badge.hidden = YES;
        }
        else
        {
            self.badge.hidden = self.animating;
            self.badge.text = [NSString stringWithFormat:@"%ld", (long)unreadCount];
            
            CGSize textSize = [self.badge.text sizeWithFont:self.badge.font constrainedToSize:CGSizeMake(CHAT_HEAD_DIMENSION, CGFLOAT_MAX)];
            CGRect frame = self.badge.frame;
            frame.size.width = textSize.width + 5;
            frame.origin.x = self.frame.size.width - MAX(frame.size.width/2, 15.0);
            self.badge.frame = frame;
            //            [self.badge sizeToFit];
        }
    }
}

- (void)setHierarchyLevel:(NSUInteger)hierarchyLevel
{
    if (hierarchyLevel != _hierarchyLevel)
    {
        _hierarchyLevel = hierarchyLevel;
        
        [self setViewStateForHierarchyLevel:hierarchyLevel];
    }
}

- (void)setViewStateForHierarchyLevel:(NSUInteger)hierarchy
{
    self.imageView.alpha = 1;//MAX(1.0 - 0.35*hierarchy, 0.05);
    self.backgroundColor = (hierarchy == 0) ? [UIColor clearColor] : [UIColor clearColor];
    self.userInteractionEnabled = hierarchy == 0;
}

- (void)setIndentationLevel:(NSUInteger)indentationLevel
{
    if (indentationLevel != _indentationLevel)
    {
        if (indentationLevel < 1)
            _indentationLevel = 1;
        else if (indentationLevel > MAX_NUMBER_OF_CHAT_HEADS)
            _indentationLevel = MAX_NUMBER_OF_CHAT_HEADS;
        else
            _indentationLevel = indentationLevel;
        
        //        self.badge.text = [NSString stringWithFormat:@"%lu", (unsigned long)_indentationLevel];
    }
}












@end
