//
//  REMainViewController.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REBaseViewController.h"
#import "REDocumentReader.h"

@interface REMainViewController : REBaseViewController <UIActionSheetDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, REMainReaderDelegate>

@property (nonatomic) NSDictionary *documentInfo;

@end
