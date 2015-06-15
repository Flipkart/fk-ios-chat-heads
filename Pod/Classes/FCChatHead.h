//
//  FCChatHead.h
//  FCChatHead
//
//  Created by Rajat Gupta on 02/24/2015.
//  Copyright (c) 2014 Rajat Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCChatHeadsDelegate.h"
#import "FCCHConstants.h"



@interface FCChatHead : UIView

@property (nonatomic, readonly, strong) UILabel *badge;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, weak) id<FCChatHeadsDelegate> delegate;

@property (nonatomic, strong) NSString *chatID;

@property (nonatomic, assign) NSUInteger hierarchyLevel;
@property (nonatomic, assign) NSUInteger indentationLevel;

@property (nonatomic, assign) BOOL circular;

@property (nonatomic, assign) BOOL animating;

@property (nonatomic, assign) NSInteger unreadCount;

+ (instancetype)chatHeadWithImage:(UIImage *)image;
+ (instancetype)chatHeadWithImage:(UIImage *)image delegate:(id<FCChatHeadsDelegate>)delegate;
+ (instancetype)chatHeadWithImage:(UIImage *)image chatID:(NSString *)chatID delegate:(id<FCChatHeadsDelegate>)delegate;
+ (instancetype)chatHeadWithView:(UIView *)view chatID:(NSString *)chatID delegate:(id<FCChatHeadsDelegate>)delegate;

- (void)highlightTouch;
- (void)unhightlight;

@end





