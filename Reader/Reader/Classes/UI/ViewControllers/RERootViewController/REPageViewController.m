//
//  RERootViewController.m
//  Reader
//
//  Created by gogunsky on 4/14/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REPageViewController.h"
#import "REMainViewController.h"
#import "REPageView.h"

@interface REPageViewController ()

@property (nonatomic) REPageView *pageView;

@end

@implementation REPageViewController

- (id) initWithViewFrame:(CGRect)frame
{
    self = [super init];
    if (self) 
    {
        [[self view] setFrame:frame];
        [self initializePageView];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) setCTFrame:(CTFrameRef)frame attachments:(NSArray *)attachments
{
    [[self pageView] setCTFrame:frame attachments:attachments];
    [[self pageView] setNeedsDisplay];
}

- (void) initializePageView
{
    REPageView *pageView = [[REPageView alloc] initWithFrame:self.view.bounds];
    [pageView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
    [pageView setBackgroundColor:[UIColor whiteColor]];
    
    [[self view] addSubview:pageView];
    
    [self setPageView:pageView];
}

@end
