//
//  FCViewController.m
//  FCChatHeads
//
//  Created by Rajat Gupta on 04/09/2015.
//  Copyright (c) 2014 Rajat Gupta. All rights reserved.
//

#import "FCViewController.h"
#import <FCChatHeads/FCChatHeads.h>

@interface FCViewController () <FCChatHeadsControllerDatasource>
{
    NSUInteger _index;
}

@end

@implementation FCViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    
    [self.view addGestureRecognizer:tapGesture];
    
    ChatHeadsController.datasource = self;
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    NSString *imageName = [NSString stringWithFormat:@"%lu", (unsigned long)_index++%6 + 1];
    
    //    UIView *view = [[UIView alloc] initWithFrame:DEFAULT_CHAT_HEAD_FRAME];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
//    imageView.frame = DEFAULT_CHAT_HEAD_FRAME;
//    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.layer.cornerRadius = CGRectGetHeight(imageView.bounds)/2;
    imageView.layer.masksToBounds = YES;
    //    [view addSubview:imageView];
    
    //    [ChatHeadsController presentChatHeadWithImage:[UIImage imageNamed:imageName] chatID:imageName];
    [ChatHeadsController presentChatHeadWithView:imageView chatID:imageName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIView *)chatHeadsController:(FCChatHeadsController *)chatHeadsController viewForPopoverForChatHeadWithChatID:(NSString *)chatID
{
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    [view setBackgroundColor:[UIColor yellowColor]];
    
    return view;
}


@end
