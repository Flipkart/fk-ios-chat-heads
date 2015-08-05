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
    BOOL chatHeadsShown;
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
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
    
    [self.view addGestureRecognizer:longPress];
    
    ChatHeadsController.datasource = self;
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(bombard:)
                                   userInfo:nil
                                    repeats:YES];
}

int unreadCount;
bool stopBombarding;

- (void)bombard:(NSTimer *)timer
{
    if (stopBombarding)
    {
        return;
    }
    
    NSString *imageName = [NSString stringWithFormat:@"%lu", (unsigned long)_index + 1];
    
    //    UIView *view = [[UIView alloc] initWithFrame:DEFAULT_CHAT_HEAD_FRAME];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.frame = CGRectMake(0, 0, 40, 40);
    //    imageView.frame = DEFAULT_CHAT_HEAD_FRAME;
    //    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.layer.cornerRadius = CGRectGetHeight(imageView.bounds)/2;
    imageView.layer.masksToBounds = YES;
    //    [view addSubview:imageView];
    
    //    [ChatHeadsController presentChatHeadWithImage:[UIImage imageNamed:imageName] chatID:imageName];
    [ChatHeadsController presentChatHeadWithView:imageView chatID:imageName];
    [ChatHeadsController setUnreadCount:unreadCount++ forChatHeadWithChatID:imageName];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    stopBombarding = YES;
    
    if (_index%2 == 0)
    {
        NSString *imageName = [NSString stringWithFormat:@"%lu", (unsigned long)_index++%6 + 1];
        
        //    UIView *view = [[UIView alloc] initWithFrame:DEFAULT_CHAT_HEAD_FRAME];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.frame = CGRectMake(0, 0, 40, 40);
        //    imageView.frame = DEFAULT_CHAT_HEAD_FRAME;
        //    imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.layer.cornerRadius = CGRectGetHeight(imageView.bounds)/2;
        imageView.layer.masksToBounds = YES;
        //    [view addSubview:imageView];
        
        //    [ChatHeadsController presentChatHeadWithImage:[UIImage imageNamed:imageName] chatID:imageName];
        [ChatHeadsController presentChatHeadWithView:imageView chatID:imageName];
    }
    else
    {
        for (NSInteger count = 0; count < 3; count++)
        {
            NSString *imageName = [NSString stringWithFormat:@"%lu", (unsigned long)_index++%6 + 1];
            
            //    UIView *view = [[UIView alloc] initWithFrame:DEFAULT_CHAT_HEAD_FRAME];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
            imageView.frame = CGRectMake(0, 0, 40, 40);
            //    imageView.frame = DEFAULT_CHAT_HEAD_FRAME;
            //    imageView.contentMode = UIViewContentModeScaleToFill;
            imageView.layer.cornerRadius = 20.0;//CGRectGetHeight(imageView.bounds)/2;
            imageView.layer.masksToBounds = YES;
            //    [view addSubview:imageView];
            
            //    [ChatHeadsController presentChatHeadWithImage:[UIImage imageNamed:imageName] chatID:imageName];
            [ChatHeadsController presentChatHeadWithView:imageView chatID:imageName];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleLongTap:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        if (chatHeadsShown)
        {
            chatHeadsShown = NO;
            
            [ChatHeadsController dismissAllChatHeads:YES];
        }
        else
        {
            chatHeadsShown = YES;
            
            NSMutableArray *chatHeads = [NSMutableArray array];
            
            for (int count = 0; count < 3; count++)
            {
                NSString *imageName = [NSString stringWithFormat:@"%d", count%6 + 1];
                
                //    UIView *view = [[UIView alloc] initWithFrame:DEFAULT_CHAT_HEAD_FRAME];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
                //    imageView.frame = DEFAULT_CHAT_HEAD_FRAME;
                //    imageView.contentMode = UIViewContentModeScaleToFill;
                imageView.layer.cornerRadius = CGRectGetHeight(imageView.bounds)/2;
                imageView.layer.masksToBounds = YES;
                
                FCChatHead *chatHead = [FCChatHead chatHeadWithView:imageView
                                                             chatID:imageName
                                                           delegate:ChatHeadsController];
                
                [chatHeads addObject:chatHead];
            }
            
            [ChatHeadsController presentChatHeads:chatHeads animated:YES];
        }
//        if (ChatHeadsController.allChatHeadsHidden)
//        {
//            [ChatHeadsController unhideAllChatHeads];
//        }
//        else
//        {
//            [ChatHeadsController hideAllChatHeads];
//        }
    }
}

- (UIView *)chatHeadsController:(FCChatHeadsController *)chatHeadsController viewForPopoverForChatHeadWithChatID:(NSString *)chatID
{
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    [view setBackgroundColor:[UIColor yellowColor]];
    
    return view;
}


@end
