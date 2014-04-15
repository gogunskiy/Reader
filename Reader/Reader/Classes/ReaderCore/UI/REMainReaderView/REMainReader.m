//
//  REMainReaderView.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REMainReader.h"
#import "REChapter.h"
#import "REAttributedElement.h"
#import "REPageView.h"


typedef NS_ENUM(NSInteger, RESnapshotViewAnimationType)
{
    RESnapshotViewAnimationLeft = -1,
    RESnapshotViewAnimationNone = 0,
    RESnapshotViewAnimationRight = 1
};


@interface REMainReader()

@property (nonatomic, assign) NSUInteger currentFrame;

@property (nonatomic, strong) NSMutableArray *frames;

@property (nonatomic, assign)  CTFramesetterRef framesetter;

@property (nonatomic, strong) REPageView *pageView;
@property (nonatomic, strong) UIImageView *snapshotView;

@end

@implementation REMainReader

- (instancetype)init
{
    self = [super init];
    if (self) 
    {
        [self setFrames:[NSMutableArray array]];
        [self setAttachments:[NSMutableArray new]];
    }
    
    return self;
}

- (void) needsUpdatePagesWithFrame:(CGRect)frame
{
    [self createPagesWithFrame:frame];
    [self initializeSnapshotView];
    [self initializeScrollViewAtPage:1];
}


- (NSArray *) runs
{
    return self.pageView.runs;
}

- (NSUInteger) pageCount
{
    return self.frames.count;
}

- (NSUInteger) currentPage
{
    return self.currentFrame + 1;
}

- (CTFrameRef) currentCTFrame
{
    CTFrameRef ctFrame = (__bridge CTFrameRef)_frames[_currentFrame];
    
    return ctFrame;
}

- (void) showNextPage
{
    if (_currentFrame < self.frames.count - 1 )
    {
        NSInteger frameIndex  = _currentFrame + 1;
        [self showPageAtIndex:frameIndex];
    }

}

- (void) showPreviousPage
{
    if (_currentFrame > 0)
    {
        NSInteger frameIndex = _currentFrame - 1;
        [self showPageAtIndex:frameIndex];
    }
}

- (void) showPageAtIndex:(NSUInteger)index
{
    if ([_frames count] <= index)
    {
        return;
    }
    
    CTFrameRef ctFrame = (__bridge_retained CTFrameRef)_frames[index];
    
    [[self pageView] setCTFrame:ctFrame
                    attachments:[self attachmentsForFrame:ctFrame]];
    
    [self setCurrentFrame:index];
}

#pragma mark - Private -

- (void) createPagesWithFrame:(CGRect)frame
{
    NSInteger pointer = 0;
  
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, frame);
    
    NSAttributedString *attString = [self.document attributedString];
    
    [attString enumerateAttribute:(id)kCTRunDelegateAttributeName
                          inRange:NSMakeRange(0, attString.length)
                          options:0
                       usingBlock:^(id value, NSRange range, BOOL *stop)
     {
         if (range.length == 1)
         {
             if (value)
             {
                 CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)(value);
                 
                 NSDictionary *info = (NSDictionary *)CTRunDelegateGetRefCon(delegate);
                 
                 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:info];
                 [dict setObject:dict[@"fileName"] forKey:@"attachmentPath"];
                 [dict setObject:@(range.location) forKey:@"location"];
                 
                 [[self attachments] addObject:dict];
             }
         }
     }];
    
    
    NSMutableArray *endOfChapters = [[NSMutableArray alloc] init];
    
    [attString enumerateAttribute:@"END_OF_CHAPTER"
                          inRange:NSMakeRange(0, attString.length)
                          options:0
                       usingBlock:^(id value, NSRange range, BOOL *stop)
     {
         if ([value integerValue])
         {
             [endOfChapters addObject:@(range.location)];
         }
     }];
    
    [self createFrameSetterWithString:attString];
    
    while (pointer < attString.length)
    {
        CGFloat length = attString.length - pointer;
        
        CTFrameRef frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(pointer, length), path, NULL);
        
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        
        for (NSNumber *endOfChapter in endOfChapters)
        {
            if (frameRange.location <= [endOfChapter integerValue] && frameRange.location + frameRange.length >= [endOfChapter integerValue])
            {
                length = [endOfChapter integerValue] - pointer;
                
                frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(pointer, length), path, NULL);
                frameRange = CTFrameGetVisibleStringRange(frame);
            }
        }
        
        pointer += frameRange.length;
        
        
        [[self frames] addObject:(__bridge id)frame];
    }
    
    CFRelease(path);
}

- (void) initializeSnapshotView
{
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self setSnapshotView:view];
}

- (void) initializeScrollViewAtPage:(NSUInteger)page
{    
    [self showPageAtIndex:page - 1];
}

- (NSString *) currentChapterTitle
{
    CTFrameRef currentFrame = (__bridge CTFrameRef)_frames[_currentFrame];
    
    CFRange range = CTFrameGetStringRange(currentFrame);
    
    NSRange pageRange = NSMakeRange(range.location, range.length);
    
    if (range.length > 40)
    {
        pageRange = NSMakeRange(range.location, 40);
    }
    
    NSString * pageString = [[[self.document.attributedString string] substringWithRange:pageRange] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    for (REChapter *chapter in self.document.chapters)
    {
        NSString *chapterText = [[[chapter attributedString] string] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        if ([chapterText rangeOfString:pageString].length > 0)
        {
            return [chapter title];
        }
    }
    
    return @"";
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
