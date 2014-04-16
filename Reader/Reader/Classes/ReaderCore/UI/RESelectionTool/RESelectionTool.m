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

static NSUInteger const MARKER_WIDTH        = 4;
static NSUInteger const MARKER_HEIGHT       = 40;


@interface RESelectionTool()

@property (nonatomic, assign) BOOL capturedLeftMarker;
@property (nonatomic, assign) BOOL capturedRightMarker;

@property (nonatomic, assign) NSInteger minIndex;
@property (nonatomic, assign) NSInteger maxIndex;


@property (nonatomic, strong) UIMenuController *menuController;

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

- (void)awakeFromNib
{
    [self initializeMenu];
}


- (void) buildLines
{  
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    for (int i = 0; i < self.runs.count; i++)
    {
        NSDictionary *run = self.runs[i];
        CGRect frame = [run[@"frame"] CGRectValue];
        frame = CGRectInset(frame, 0, -1.5);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (i >= _minIndex && i <= _maxIndex) 
        {
            CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 0.2);   
        }
        else
        {
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.0);
        }
        
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.0); 
        CGContextFillRect(context, frame);
        CGContextStrokeRect(context, frame); 
    }
}


- (BOOL) reset
{
    _minIndex = -1;
    _maxIndex = -1;
    
    [[self viewWithTag:LEFT_MARKER_TAG] removeFromSuperview];
    [[self viewWithTag:RIGHT_MARKER_TAG] removeFromSuperview];
    
    [[self menuController] setMenuVisible:FALSE animated:FALSE];
    
    [self setNeedsDisplay];
    
    [self setUserInteractionEnabled:FALSE];
    
    return FALSE;
}

- (NSString *) text
{
    return [self textFrom:_minIndex to:_maxIndex];
}

#pragma mark - Actions -

- (void) move:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state)
    {
            
        case UIGestureRecognizerStateBegan:
        {
            [self hideMenu];
            
            CGPoint location = [gesture locationInView:self];
            
            CGRect leftMarkerFrame = CGRectInset([self viewWithTag:LEFT_MARKER_TAG].frame, -80, -80);
            CGRect rightMarkerFrame = CGRectInset([self viewWithTag:RIGHT_MARKER_TAG].frame, -80, -80);
            
            _capturedLeftMarker  = CGRectContainsPoint(leftMarkerFrame, location);
            _capturedRightMarker = CGRectContainsPoint(rightMarkerFrame, location);
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint location    = [gesture locationInView:self];
            
            
            if (_capturedLeftMarker || _capturedRightMarker) 
            {
                for (int i = 0; i < self.runs.count; i++)
                {
                    NSDictionary *run = self.runs[i];
                    CGRect frame = [run[@"frame"] CGRectValue];
                    
                    if (CGRectContainsPoint(frame, location))
                    {
                        if (_capturedLeftMarker) 
                        {
                            _minIndex = i < _maxIndex ? i : _minIndex;
                            break;
                        }
                        if (_capturedRightMarker) 
                        {
                            _maxIndex = i > _minIndex ? i : _maxIndex;
                            break;
                        }
                    }
                }  
                [self setNeedsDisplay];
                [self updateMarkersFrom:_minIndex to:_maxIndex];
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self setCapturedLeftMarker:FALSE];
            [self setCapturedRightMarker:FALSE];
            
            [self showMenu];
            
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
    
    [self reset];
    
    CGPoint location = [gesture locationInView:self];
    
    for (int i = 0; i < self.runs.count; i++)
    {
        NSDictionary *run = self.runs[i];
        CGRect frame = [run[@"frame"] CGRectValue];
        
        if (CGRectContainsPoint(frame, location))
        {
            NSInteger currentIndex = i;
            
            NSRange range = [run[@"range"] rangeValue];
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

            [self setNeedsDisplay];

            CGRect startFrame   = [self.runs[_minIndex][@"frame"] CGRectValue];
            CGRect endFrame   = [self.runs[_maxIndex][@"frame"] CGRectValue];
            
            [self addMarkersWithStartFrame:startFrame
                                  endFrame:endFrame];
            
            [self addGestureRecognizer];
            
            [self showMenu];
            
            return TRUE;
            
            break;
        }
    }
    
    return FALSE;
}

#pragma mark - Private -

- (void) initializeMenu
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyAction)];
    UIMenuItem *shareMenuItem = [[UIMenuItem alloc] initWithTitle:@"Share" action:@selector(shareAction)];
    UIMenuItem *googleMenuItem = [[UIMenuItem alloc] initWithTitle:@"Google" action:@selector(googleAction)];
    UIMenuItem *translateMenuItem = [[UIMenuItem alloc] initWithTitle:@"Translate" action:@selector(translateAction)];
    
    [menu setMenuItems:@[copyMenuItem, shareMenuItem, googleMenuItem, translateMenuItem]];
    
    [self setMenuController:menu];
}

- (void) showMenu
{
    CGRect minFrame   = [self.runs[_minIndex][@"frame"] CGRectValue];
    CGRect maxFrame   = [self.runs[_maxIndex][@"frame"] CGRectValue];
    
    CGRect rect;
    
    rect.origin.x = 0;
    rect.origin.y = MIN(CGRectGetMinY(minFrame), CGRectGetMinY(maxFrame));
    
    rect.size.width = self.frame.size.width;
    rect.size.height =  MAX(CGRectGetMaxY(minFrame), CGRectGetMaxY(maxFrame)) - rect.origin.y;
        
    [[self menuController] setTargetRect:rect inView:self];
    [[self menuController] setMenuVisible:YES animated:YES];
    
    [self becomeFirstResponder];
}

-(BOOL) canBecomeFirstResponder
{
    return TRUE;
}

- (void) hideMenu
{
    UIMenuController *theMenu = [UIMenuController sharedMenuController];
    [theMenu setMenuVisible:NO animated:NO];
}

- (void) copyAction
{
    NSString *text = [self textFrom:_minIndex to:_maxIndex];
    [[self delegate] selectionTool:self clickedItemWithType:RESelectionToolActionCopy selectedText:text];
}

- (void) shareAction
{
    NSString *text = [self textFrom:_minIndex to:_maxIndex];
    [[self delegate] selectionTool:self clickedItemWithType:RESelectionToolActionShare selectedText:text];
}

- (void) googleAction
{
    NSString *text = [self textFrom:_minIndex to:_maxIndex];
    [[self delegate] selectionTool:self clickedItemWithType:RESelectionToolActionGoogle selectedText:text];
}

- (void) translateAction
{
    NSString *text = [self textFrom:_minIndex to:_maxIndex];
    [[self delegate] selectionTool:self clickedItemWithType:RESelectionToolActionTranslate selectedText:text];
}

- (NSString *) textFrom:(NSInteger)startIndex to:(NSInteger)endIndex
{
    NSString *string = [[self attributedString] string];
    
    NSRange start   = [self.runs[_minIndex][@"range"] rangeValue];
    NSRange end     = [self.runs[_maxIndex][@"range"] rangeValue];
    
    return [string substringWithRange:NSMakeRange(start.location, end.location - start.location)];
}

- (void) updateMarkersFrom:(NSInteger)startIndex to:(NSInteger)endIndex
{    
    CGRect startFrame   = [self.runs[startIndex][@"frame"] CGRectValue];
    CGRect endFrame   = [self.runs[endIndex][@"frame"] CGRectValue];
    
    [[self viewWithTag:LEFT_MARKER_TAG] setFrame:CGRectMake(startFrame.origin.x - MARKER_WIDTH, startFrame.origin.y - (MARKER_HEIGHT - startFrame.size.height), MARKER_WIDTH, MARKER_HEIGHT)];
    [[self viewWithTag:RIGHT_MARKER_TAG] setFrame:CGRectMake(endFrame.origin.x + endFrame.size.width, endFrame.origin.y, MARKER_WIDTH, MARKER_HEIGHT)];
}

- (void) addMarkersWithStartFrame:(CGRect)startFrame endFrame:(CGRect)endFrame
{
    [[self viewWithTag:LEFT_MARKER_TAG] removeFromSuperview];
    
    UIView *leftmarker = [[UIView alloc] initWithFrame:CGRectMake(startFrame.origin.x - MARKER_WIDTH, startFrame.origin.y - (MARKER_HEIGHT - startFrame.size.height), MARKER_WIDTH, MARKER_HEIGHT)];
    [leftmarker setBackgroundColor:[UIColor blueColor]];
    [leftmarker setTag:LEFT_MARKER_TAG];
    [self addSubview:leftmarker];
    
    [[self viewWithTag:RIGHT_MARKER_TAG] removeFromSuperview];
    
    UIView *rightmarker = [[UIView alloc] initWithFrame:CGRectMake(endFrame.origin.x + endFrame.size.width, endFrame.origin.y, MARKER_WIDTH, MARKER_HEIGHT)];
    [rightmarker setBackgroundColor:[UIColor blueColor]];
    [rightmarker setTag:RIGHT_MARKER_TAG];
    [self addSubview:rightmarker];
}

- (void) addGestureRecognizer
{
    [self setUserInteractionEnabled:TRUE];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [self addGestureRecognizer:panGesture];
}

@end
