//
//  FCPopOverView.m
//  Pods
//
//  Created by Rajat Kumar Gupta on 13/08/15.
//
//

#import "FCPopOverView.h"
#import "FCCHConstants.h"

@implementation FCPopOverView

- (CGRect)bubbleFrame {
    CGRect bubbleFrame = CGRectMake(0,
                                    self.pointerSize,
                                    [[UIScreen mainScreen] bounds].size.width,
                                    [[UIScreen mainScreen] bounds].size.height - DEFAULT_CHAT_HEAD_FRAME.size.height - 10.0);
    return bubbleFrame;
}

@end
