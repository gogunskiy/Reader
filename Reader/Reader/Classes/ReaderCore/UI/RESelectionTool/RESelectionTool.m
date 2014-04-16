//
//  RESelectionTool.m
//  Reader
//
//  Created by gogunsky on 4/13/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "RESelectionTool.h"

static NSUInteger const LEFT_MARKER_TAG     = 11134;
static NSUInteger const RIGHT_MARKER_TAG    = 11136;

static NSUInteger const MARKER_WIDTH        = 10;
static NSUInteger const MARKER_HEIGHT       = 40;


@interface RESelectionTool()

@property (nonatomic, assign) BOOL capturedLeftMarker;
@property (nonatomic, assign) BOOL capturedRightMarker;

@property (nonatomic, assign) NSInteger minIndex;
@property (nonatomic, assign) NSInteger maxIndex;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGPoint previousPoint;

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
        [view setHidden:TRUE];
        [view setTag:i + 1];
        [self addSubview:view];
    }
}

- (BOOL) reset
{
    [self unSelectAll];
    
    return FALSE;
}


- (void) clear
{
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
}

#pragma mark - Actions -
- (void) tap:(UITapGestureRecognizer *)gesture

{
}

- (void) move:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state)
    {
         
        case UIGestureRecognizerStateBegan:
        {
            CGPoint location = [gesture locationInView:self];
            [self setPreviousPoint:location];
            
            CGRect leftMarkerFrame = CGRectInset([self viewWithTag:LEFT_MARKER_TAG].frame, -40, -40);
            CGRect rightMarkerFrame = CGRectInset([self viewWithTag:RIGHT_MARKER_TAG].frame, -40, -40);
            
            _capturedLeftMarker  = CGRectContainsPoint(leftMarkerFrame, location);
            _capturedRightMarker = CGRectContainsPoint(rightMarkerFrame, location);
            
            if (_capturedRightMarker || _capturedLeftMarker) 
            {
                [self startUpdate];
            }
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint location    = [gesture locationInView:self];
            

                if (_capturedLeftMarker || _capturedRightMarker) 
                {
                    for (int i = 1; i <= self.runs.count; i++)
                    {
                        UIView *view = [self viewWithTag:i];
                        
                        if (CGRectContainsPoint([view frame], location))
                        {
                            if (_capturedLeftMarker) 
                            {
                                _minIndex = i;
                                break;
                            }
                            if (_capturedRightMarker) 
                            {
                                _maxIndex = i;
                                break;
                            }
                        
                    }
                }
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self stopUpdate];
            [self setCapturedLeftMarker:FALSE];
            [self setCapturedRightMarker:FALSE];
            [self selectFrom:_minIndex to:_maxIndex];

            
            break;
        }
        
        default:
        {
            break;
        }
    }
}


- (BOOL) longPress:(UILongPressGestureRecognizer *)gesture
{
    NSInteger leftMarkerTag = 0;
    NSInteger rightMarkerTag = 0;
    
    [self unSelectAll];
    
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
                return FALSE;
            }
            
            BOOL leftSpaceFound = FALSE;
            BOOL rightSpaceFound = FALSE;
            
            NSInteger delta = 0;
            NSInteger prevValue = 0;
            NSInteger nextValue = 0;
            
            while (!(leftSpaceFound && rightSpaceFound))
            {
                delta ++;
                
                prevValue = currentIndex - delta;
                if (prevValue >= 0 && !leftSpaceFound)
                {
                    NSRange range = [_runs[prevValue][@"range"] rangeValue];
                    NSString * character = [[_attributedString string] substringWithRange:range];
                    
                    if ([character isEqualToString:@" "] || 
                        [character isEqualToString:@"."] || 
                        [character isEqualToString:@","] || 
                        [character isEqualToString:@"\n"])
                    {
                        leftMarkerTag = prevValue;
                        leftSpaceFound = TRUE;
                    }
                }
                else
                {
                    leftSpaceFound = TRUE;
                }
                
                nextValue = currentIndex + delta;
                if (nextValue < _runs.count && !rightSpaceFound)
                {
                    NSRange range = [_runs[nextValue][@"range"] rangeValue];
                    NSString * character = [[_attributedString string] substringWithRange:range];
                    
                    if ([character isEqualToString:@" "] || 
                        [character isEqualToString:@"."] || 
                        [character isEqualToString:@","] || 
                        [character isEqualToString:@"\n"])
                    {
                        rightMarkerTag = nextValue;
                        rightSpaceFound = TRUE;
                    }
                }
                else
                {
                    rightSpaceFound = TRUE;
                }
            }
            
            _minIndex = leftMarkerTag;
            _maxIndex = rightMarkerTag;

            [self selectFrom:_minIndex to:_maxIndex];

            [self addMarkersWithStartFrame:[[self viewWithTag:_minIndex] frame]
                                  endFrame:[[self viewWithTag:_maxIndex] frame]];
            
            [self addGestureRecognizer];
            
            return TRUE;
            
            break;
        }
    }
    
    
    return FALSE;
}

#pragma mark - Private -

- (void) selectFrom:(NSInteger)startIndex to:(NSInteger)endIndex
{
    for (int i = 1; i <= self.runs.count; i++) 
    {
        if (i >= startIndex && i <=endIndex) 
        {
            [[self viewWithTag:i] setHidden:FALSE];
        }
        else
        {
            [[self viewWithTag:i] setHidden:TRUE];
        }
    }
};


- (void) updateMarkersFrom:(NSInteger)startIndex to:(NSInteger)endIndex
{
    CGRect startFrame   = [[self viewWithTag:startIndex] frame];
    CGRect endFrame     = [[self viewWithTag:endIndex] frame];
    
    [[self viewWithTag:LEFT_MARKER_TAG] setFrame:CGRectMake(startFrame.origin.x + (startFrame.size.width - MARKER_WIDTH), startFrame.origin.y - (MARKER_HEIGHT - startFrame.size.height), MARKER_WIDTH, MARKER_HEIGHT)];
    [[self viewWithTag:RIGHT_MARKER_TAG] setFrame:CGRectMake(endFrame.origin.x, endFrame.origin.y, MARKER_WIDTH, MARKER_HEIGHT)];
}

- (void) unSelectAll
{
    [self setUserInteractionEnabled:FALSE];
 
    for (UIView *view in self.subviews)
    {
        [view setHidden:TRUE];
    }
}


- (void) addMarkersWithStartFrame:(CGRect)startFrame endFrame:(CGRect)endFrame
{
    [[self viewWithTag:LEFT_MARKER_TAG] removeFromSuperview];
    
    UIView *leftmarker = [[UIView alloc] initWithFrame:CGRectMake(startFrame.origin.x + (startFrame.size.width - MARKER_WIDTH), startFrame.origin.y - (MARKER_HEIGHT - startFrame.size.height), MARKER_WIDTH, MARKER_HEIGHT)];
    [leftmarker setBackgroundColor:[UIColor redColor]];
    [leftmarker setTag:LEFT_MARKER_TAG];
    [self addSubview:leftmarker];
    
    [[self viewWithTag:RIGHT_MARKER_TAG] removeFromSuperview];
    
    UIView *rightmarker = [[UIView alloc] initWithFrame:CGRectMake(endFrame.origin.x, endFrame.origin.y, MARKER_WIDTH, MARKER_HEIGHT)];
    [rightmarker setBackgroundColor:[UIColor redColor]];
    [rightmarker setTag:RIGHT_MARKER_TAG];
    [self addSubview:rightmarker];
}

- (void) addGestureRecognizer
{
    [self setUserInteractionEnabled:TRUE];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [self addGestureRecognizer:panGesture];
}

- (void) startUpdate
{
    _timer = [NSTimer timerWithTimeInterval:0.05 
                                     target:self
                                   selector:@selector(update)
                                   userInfo:nil 
                                    repeats:TRUE];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void) stopUpdate
{
    [_timer invalidate];
}

- (void) update
{
    [self updateMarkersFrom:_minIndex to:_maxIndex];
}

@end
