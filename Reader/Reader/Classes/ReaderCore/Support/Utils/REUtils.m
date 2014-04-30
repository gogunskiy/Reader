//
//  REUtils.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/16/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REUtils.h"

#import <Social/Social.h>

static REUtils *shared = nil;

@implementation REUtils

+ (instancetype) shared
{
    static dispatch_once_t once;
    
    dispatch_once(&once, ^
                  {
                      shared = [[REUtils alloc] init]; 
                  });
    
    return shared;
}


- (void) openGoogleWithText:(NSString *)text
{
    NSString *url = [[NSString stringWithFormat:@"https://www.google.com/search?q=%@", text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void) openTranslaterWithText:(NSString *)text
{
    
}

- (void) shareFacebookWithText:(NSString *)text parentViewController:(UIViewController *)parentViewController
{
    [self shareWithServiceType:SLServiceTypeFacebook 
                             text:text 
             parentViewController:parentViewController];
}

- (void) shareTwitterWithText:(NSString *)text parentViewController:(UIViewController *)parentViewController
{
    [self shareWithServiceType:SLServiceTypeTwitter 
                             text:text 
             parentViewController:parentViewController];
}

- (void) shareEmailWithText:(NSString *)text parentViewController:(UIViewController *)parentViewController
{
    if ([MFMailComposeViewController canSendMail]) 
    {
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        [mailVC setMessageBody:text isHTML:FALSE];
        
        [parentViewController presentViewController:mailVC animated:YES completion:NULL];  
    }
}

- (void) shareSMSWithText:(NSString *)text parentViewController:(UIViewController *)parentViewController
{
    if ([MFMessageComposeViewController  canSendText])
    {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        [messageController setBody:text];
        
        [parentViewController presentViewController:messageController animated:YES completion:NULL];
    }
}

- (void) changeBrightness:(CGFloat)deltaValue
{
    CGFloat newBrightness = [[UIScreen mainScreen] brightness] + deltaValue;
    
    if (newBrightness > 1.0)
    {
        newBrightness = 1.0;
    }
    if (newBrightness < .0)
    {
        newBrightness = 0.0;
    }
    
    [[UIScreen mainScreen] setBrightness:newBrightness];
}

#pragma mark - Private - 

- (void) shareWithServiceType:(NSString *)serviceType text:(NSString *)text  parentViewController:(UIViewController *)parentViewController
{
    if ([SLComposeViewController isAvailableForServiceType:serviceType])
    {
        SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:serviceType];
       
        [composeController setInitialText:text];
     
        
        [composeController setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             switch (result) 
             {
                 case SLComposeViewControllerResultCancelled:
                 case SLComposeViewControllerResultDone:
                 {
                     [parentViewController dismissViewControllerAnimated:YES completion:NULL];
                     break;
                 }
                     
                 default:
                     break;
             }
         }];

    }
}


#pragma mark - Mail Composer Delegate -

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - SMS Composer Delegate -

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
