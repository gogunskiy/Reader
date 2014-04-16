//
//  REUtils.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/16/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

#define UTILS [REUtils shared]

@interface REUtils : NSObject <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

+ (instancetype) shared;

- (void) openGoogleWithText:(NSString *)text;
- (void) openTranslaterWithText:(NSString *)text;

- (void) shareFacebookWithText:(NSString *)text parentViewController:(UIViewController *)parentViewController;
- (void) shareTwitterWithText:(NSString *)text parentViewController:(UIViewController *)parentViewController;
- (void) shareEmailWithText:(NSString *)text parentViewController:(UIViewController *)parentViewController;
- (void) shareSMSWithText:(NSString *)text parentViewController:(UIViewController *)parentViewController;

@end
