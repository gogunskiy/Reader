//
//  RESelectionTool.m
//  Reader
//
//  Created by gogunsky on 4/13/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "RESelectionTool.h"

@interface RESelectionTool()

@end

@implementation RESelectionTool

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
    }
    
    return self;
}


- (void) buildLines
{
    [self clear];
    
    for (int i = 0; i < self.runs.count; i++)
    {
        NSDictionary *run = self.runs[i];
        CGRect frame = [run[@"frame"] CGRectValue];
        
        UIView *view = [[UIView alloc] initWithFrame:frame];
        [view setUserInteractionEnabled:FALSE];
        [view setBackgroundColor:[UIColor colorWithRed:.0
                                                 green:.0
                                                  blue:1.0
                                                 alpha:0.2]];
        [view setAlpha:0.0];
        
        [view setTag:i];
        [self addSubview:view];
    }
}

- (void) clear
{
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
}

#pragma mark - Actions -

- (void) longPress:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            for (UIView *view in self.subviews)
            {
                [view setAlpha:0];
            }
            
            CGPoint location = [gesture locationInView:self];
            
            for (UIView *view in self.subviews)
            {
                if (CGRectContainsPoint([view frame], location))
                {
                    NSInteger currentIndex = [view tag];
                    NSRange range = [_runs[currentIndex][@"range"] rangeValue];
                    NSString * character = [[_attributedString string] substringWithRange:range];
                    
                    if ([character isEqualToString:@" "])
                    {
                        return;
                    }
                    
                    [view setAlpha: 1.0];
                    
                    BOOL leftSpaceFound = FALSE;
                    BOOL rightSpaceFound = FALSE;
                    
                    NSInteger delta = 0;
                    
                    while (!(leftSpaceFound && rightSpaceFound))
                    {
                        delta ++;
                        
                        NSInteger prevValue = currentIndex - delta;
                        if (prevValue >= 0 && !leftSpaceFound)
                        {
                            NSRange range = [_runs[prevValue][@"range"] rangeValue];
                            NSString * character = [[_attributedString string] substringWithRange:range];

                            if ([character isEqualToString:@" "])
                            {
                                leftSpaceFound = TRUE;
                            }
                            else
                            {
                                [[self viewWithTag:prevValue] setAlpha:1.0];
                            }
                        }
                        else
                        {
                            leftSpaceFound = TRUE;
                        }
                        
                        NSInteger nextValue = currentIndex + delta;
                        if (nextValue < _runs.count && !rightSpaceFound)
                        {
                            NSRange range = [_runs[nextValue][@"range"] rangeValue];
                            NSString * character = [[_attributedString string] substringWithRange:range];
                            
                            if ([character isEqualToString:@" "])
                            {
                                rightSpaceFound = TRUE;
                            }
                            else
                            {
                                [[self viewWithTag:nextValue] setAlpha:1.0];
                            }
                        }
                        else
                        {
                            rightSpaceFound = TRUE;
                        }
                    }
                }
            }
            
            break;
        }
            
        default:
        {
            
        }
    }
}

#pragma mark - Private -


@end
