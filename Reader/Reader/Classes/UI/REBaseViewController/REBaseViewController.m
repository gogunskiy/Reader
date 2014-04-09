//
//  REBaseViewController.m
//  Reader
//
//  Created by Gogunsky Vladimir on 4/9/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REBaseViewController.h"

@interface REBaseViewController ()

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

@end
