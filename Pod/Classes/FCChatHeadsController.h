//
//  FCChatHeadsController.h
//  FCChatHead
//
//  Created by Rajat Gupta on 02/24/2015.
//  Copyright (c) 2014 Rajat Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FCChatHead.h"
#import "FCCHConstants.h"


@protocol FCChatHeadsControllerDatasource;
@protocol FCChatHeadsControllerDelegate;



@interface FCChatHeadsController : NSObject <FCChatHeadsDelegate>

@property (nonatomic, strong) UIView *headSuperView;

@property (nonatomic, weak) id<FCChatHeadsControllerDatasource> datasource;
@property (nonatomic, weak) id<FCChatHeadsControllerDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL allChatHeadsHidden;

+ (instancetype)chatHeadsController;

- (void)presentChatHeadWithImage:(UIImage *)image chatID:(NSString *)chatID;
- (void)presentChatHeadWithView:(UIView *)view chatID:(NSString *)chatID;

- (void)presentChatHeads:(NSArray *)chatHeads animated:(BOOL)animated;

- (void)hideAllChatHeads;
- (void)unhideAllChatHeads;

- (void)setUnreadCount:(NSInteger)unreadCount forChatHeadWithChatID:(NSString *)chatID;

//- (void)dismissChatheadWithID:(NSString *)chatID animated:(BOOL)animated;
- (void)dismissAllChatHeads:(BOOL)animated;

@end




@protocol FCChatHeadsControllerDatasource <NSObject>

@optional
/*
 - (NSInteger)maximumNumberOfChatHeads:(FCChatHeadsController *)chatHeadsController;
 - (BOOL)showPopoverOnChatHeadSelection:(FCChatHeadsController *)chatHeadsController;
 */
- (UIView *)chatHeadsController:(FCChatHeadsController *)chatHeadsController viewForPopoverForChatHeadWithChatID:(NSString *)chatID;

@end

@protocol FCChatHeadsControllerDelegate <NSObject>

- (void)chatHeadsController:(FCChatHeadsController *)chController didDismissPopoverForChatID:(NSString *)chatID;
- (void)chatHeadsController:(FCChatHeadsController *)chController didRemoveChatHeadWithChatID:(NSString *)chatID;

/*
 - (void)chatHeadsController:(FCChatHeadsController *)chatHeadsController didSelectChatHeadWithChatID:(NSString *)chatID;
 */
@end