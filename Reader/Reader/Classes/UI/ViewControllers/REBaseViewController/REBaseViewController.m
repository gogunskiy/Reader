//
//  REBaseViewController.m
//  Reader
//
//  Created by Gogunsky Vladimir on 4/9/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REBaseViewController.h"
#import "RMDownloadIndicator.h"

@interface REBaseViewController ()

@property (nonatomic) RMDownloadIndicator *loadingIndicator;

@end

@implementation REBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) pushViewControllerWithIdentifier:(Class)classId
{
    REBaseViewController *viewController = [[self storyboard] instantiateViewControllerWithIdentifier:NSStringFromClass(classId)];
    [[self navigationController] pushViewController:viewController animated:TRUE];
}

- (UIStoryboard *) storyboard
{
    if (IS_IPAD)
    {
        return [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    else
    {
        return [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
}

- (void) startLoadingIndicatorWithCurrentValue:(NSInteger)value maxvalue:(NSInteger)maxValue
{
    RMDownloadIndicator *mixedIndicator = [[RMDownloadIndicator alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 40, CGRectGetMidY(self.view.frame) - 40, 80, 80) 
                                                                               type:kRMMixedIndictor];
    [mixedIndicator setBackgroundColor:[UIColor whiteColor]];
    [mixedIndicator setFillColor:[UIColor colorWithRed:16./255 green:119./255 blue:234./255 alpha:1.0f]];
    [mixedIndicator setStrokeColor:[UIColor colorWithRed:16./255 green:119./255 blue:234./255 alpha:1.0f]];
    mixedIndicator.radiusPercent = 0.45;
    [mixedIndicator setIndicatorAnimationDuration:1.0];
    [self.view addSubview:mixedIndicator];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-40, - 50, mixedIndicator.frame.size.width + 100, 50)];
    [label setText:@"Loading .."];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont fontWithName:@"IowanOldStyle-Roman" size:22.0]];
    [label setTextColor:[UIColor colorWithRed:16./255 green:119./255 blue:234./255 alpha:1.0f]];
    [label setBackgroundColor:[UIColor clearColor]];
    [mixedIndicator addSubview:label];
    
    [mixedIndicator loadIndicator];
    
    [self setLoadingIndicator:mixedIndicator];
}


- (void) updateLoadingIndicatorWithCurrentValue:(NSInteger)value maxvalue:(NSInteger)maxValue
{
    [[self loadingIndicator] updateWithTotalBytes:maxValue downloadedBytes:value];
}

- (void) hideLoadingIndicator
{
    [UIView animateWithDuration:1.0 
                     animations:^
     {
         [[self loadingIndicator] setAlpha:0.0];
     } 
                     completion:^(BOOL finished) 
     {
         [[self loadingIndicator] removeFromSuperview];
     }];
}


@end
