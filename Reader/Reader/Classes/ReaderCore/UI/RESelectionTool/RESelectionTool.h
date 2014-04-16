//
//  RESelectionTool.h
//  Reader
//
//  Created by gogunsky on 4/13/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RESelectionTool : UIView

@property (nonatomic) NSAttributedString *attributedString;
@property (nonatomic) NSArray *runs;

- (BOOL) longPress:(UILongPressGestureRecognizer *)gesture;

- (void) buildLines;
- (BOOL) reset;

@end
