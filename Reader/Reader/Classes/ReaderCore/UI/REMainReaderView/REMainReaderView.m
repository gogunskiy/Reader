//
//  REMainReaderView.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REMainReaderView.h"
#import <CoreText/CoreText.h>
#import "REChapter.h"
#import "REAttributedElement.h"
#import "REPageView.h"

typedef NS_ENUM(NSInteger, RESnapshotViewAnimationType)
{
    RESnapshotViewAnimationLeft = -1,
    RESnapshotViewAnimationNone = 0,
    RESnapshotViewAnimationRight = 1
};


@interface REMainReaderView()

@property (nonatomic, assign) NSUInteger currentFrame;

@property (nonatomic, strong) NSMutableArray *frames;

@property (nonatomic, assign)  CTFramesetterRef framesetter;

@property (nonatomic, strong) REPageView *pageView;
@property (nonatomic, strong) UIImageView *snapshotView;
@end

@implementation REMainReaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setFrames:[NSMutableArray array]];
    [self setAttachments:[NSMutableArray new]];
}

- (void) needsUpdatePages
{
    [self createPages];
    [self initializeSnapshotView];
    [self initializeScrollViewAtPage:1];
}

- (NSUInteger) pageCount
{
    return self.frames.count;
}

- (NSUInteger) currentPage
{
    return self.currentFrame + 1;
}

- (void) showNextPage
{
    if (_currentFrame < self.frames.count - 1 )
    {
        [self addSnapshotViewWithHideAnimation:RESnapshotViewAnimationLeft];
        
        NSInteger frameIndex  = _currentFrame + 1;
        [self showPageAtIndex:frameIndex];
    }

}

- (void) showPreviousPage
{
    if (_currentFrame > 0)
    {
        [self addSnapshotViewWithHideAnimation:RESnapshotViewAnimationRight];
        
        NSInteger frameIndex = _currentFrame - 1;
        [self showPageAtIndex:frameIndex];
    }
}

- (void) showPageAtIndex:(NSUInteger)index
{
    CTFrameRef ctFrame = (__bridge CTFrameRef)_frames[index];
    
    [[self pageView] setCTFrame:ctFrame
                    attachments:[self attachmentsForFrame:ctFrame]];
    
    [self setCurrentFrame:index];
}

#pragma mark - Private -

- (void) createPages
{
    NSInteger pointer = 0;
  
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    for (REChapter *chapter in [[self document] chapters])
    {
        NSAttributedString *attString = [chapter attributedString];
        __block NSInteger index = 0;
        [attString enumerateAttribute:(id)kCTRunDelegateAttributeName
                              inRange:NSMakeRange(0, attString.length)
                              options:0
                           usingBlock:^(id value, NSRange range, BOOL *stop)
         {
             if (range.length == 1)
             {
                 if (index < [[chapter attachments] count])
                 {
                     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[chapter attachments][index]];
                     [dict setObject:@(range.location) forKey:@"location"];
                     
                     [[self attachments] addObject:dict];
                     
                     index ++;
                 }
             }
     
         }];
        
        
        [self createFrameSetterWithString:attString];
        
        while (pointer < attString.length)
        {
            CTFrameRef frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(pointer, attString.length - pointer), path, NULL);
            
            CFRange frameRange = CTFrameGetVisibleStringRange(frame);
            pointer += frameRange.length;
            
            [[self frames] addObject:(__bridge id)frame];
            
            CFRelease(frame);
        }
    }
    
    CFRelease(path);
}

- (void) initializeSnapshotView
{
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self setSnapshotView:view];
}

- (void) addSnapshotViewWithHideAnimation:(RESnapshotViewAnimationType)type
{
    [[self snapshotView] setFrame:[[self pageView] frame]];
    [[self snapshotView] setImage:[[self pageView] snapshot]];
    [self addSubview:[self snapshotView]];
    
    CGRect frame = [[self snapshotView] frame];
    frame.origin.x += type * frame.size.width;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [UIView animateWithDuration:0.5
                     animations:^
     {
         [[self snapshotView] setFrame:frame];
     }
                     completion:^(BOOL finished)
     {
         [[self snapshotView] removeFromSuperview];
         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
     }];
}

- (void) initializeScrollViewAtPage:(NSUInteger)page
{
    CGFloat xOffset = 0;
    
    REPageView *pageView = [[REPageView alloc] initWithFrame:self.bounds];
    [pageView setBackgroundColor:[UIColor whiteColor]];
    [pageView setTag:1];
    
    CGRect pageFrame = pageView.frame;
    pageFrame.origin.x = xOffset;
    [pageView setFrame:pageFrame];
    
    xOffset += self.bounds.size.width;
    
    [self addSubview:pageView];
    
    
    [self setContentSize:CGSizeMake(xOffset, self.bounds.size.height)];
    [self setPageView:pageView];
    
    [self showPageAtIndex:page - 1];
}

- (NSArray *) attachmentsForFrame:(CTFrameRef)frame
{
    NSMutableArray *attachments = [NSMutableArray new];
    
    for (NSDictionary *attachment in [self attachments])
    {
        NSUInteger location = [attachment[@"location"] integerValue];
        
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        
        if (location >= frameRange.location && location < frameRange.location + frameRange.length)
        {
            [attachments addObject:attachment];
        }
    }
    
    return attachments;
}

- (void) createFrameSetterWithString:(NSAttributedString *)string
{
    if (_framesetter) 
    {
        CFRelease(_framesetter);
    }
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
    
    [self setFramesetter:framesetter];
}

@end
