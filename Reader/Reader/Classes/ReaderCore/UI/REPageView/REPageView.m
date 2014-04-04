//
//  REPageView.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/4/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REPageView.h"

@interface REPageView()

@property (nonatomic, assign) CTFrameRef frameRef;

@end

@implementation REPageView


- (void) setCTFrame:(CTFrameRef)frame
{
    _frameRef = frame;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFrameDraw(_frameRef, context);
}

- (void)dealloc
{
    if (_frameRef) 
    {
        CFRelease(_frameRef);
    }
}

@end
