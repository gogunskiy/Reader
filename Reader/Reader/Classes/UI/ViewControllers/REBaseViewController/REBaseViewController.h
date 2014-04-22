//
//  REBaseViewController.h
//  Reader
//
//  Created by Gogunsky Vladimir on 4/9/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface REBaseViewController : UIViewController

- (void) pushViewControllerWithIdentifier:(Class)classId;
- (UIStoryboard *) storyboard;

- (void) startLoadingIndicatorWithCurrentValue:(NSInteger)value maxvalue:(NSInteger)maxValue;
- (void) updateLoadingIndicatorWithCurrentValue:(NSInteger)value maxvalue:(NSInteger)maxValue;
- (void) hideLoadingIndicator;

@end
