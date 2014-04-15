//
//  RERootViewController.h
//  Reader
//
//  Created by gogunsky on 4/14/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface REPageViewController : UIViewController 

- (id) initWithViewFrame:(CGRect)frame;

- (void) setCTFrame:(CTFrameRef)frame attachments:(NSArray *)attachments;

@end
