//
//  REPageView.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/4/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface REPageView : UIView

- (void) setCTFrame:(CTFrameRef)frame;

- (UIImage *) snapshot;

@end
