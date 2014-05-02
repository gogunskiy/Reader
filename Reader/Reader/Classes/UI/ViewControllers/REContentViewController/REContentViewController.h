//
//  REContentViewController.h
//  Reader
//
//  Created by Gogunsky Vladimir on 4/9/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REBaseViewController.h"

NS_ENUM(NSUInteger, RESortingType)
{
    RESortingByName,
    RESortingByAuthor
};

@interface REContentViewController : REBaseViewController <UITableViewDataSource, UITableViewDelegate>

@end
