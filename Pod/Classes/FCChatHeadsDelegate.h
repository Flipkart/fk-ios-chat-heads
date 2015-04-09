//
//  FCChatHeadsDelegate.h
//  FCChatHead
//
//  Created by Rajat Gupta on 02/24/2015.
//  Copyright (c) 2014 Rajat Gupta. All rights reserved.
//

@class FCChatHead;

@protocol FCChatHeadsDelegate <NSObject>

- (void)chatHead:(FCChatHead *)chatHead didObservePan:(UIPanGestureRecognizer *)panGesture;
- (void)chatHeadSelected:(FCChatHead *)chatHead;

@end