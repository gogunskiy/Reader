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

@interface REMainReaderView()

@property (nonatomic, strong) NSMutableArray *pageViews;

@property (nonatomic)  CTFramesetterRef framesetter;

@end

@implementation REMainReaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setPageViews:[NSMutableArray array]];
}

- (void) needsUpdatePages
{
    [self createPages];
}

- (void) createPages
{
    NSInteger pointer = 0;
    CGFloat xOffset = 0;
    
    NSAttributedString *attString = [self attributedStringForDocument:self.document];
    
    [self createFrameSetterWithString:attString];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    while (pointer < attString.length)
    {
        REPageView *pageView = [[REPageView alloc] initWithFrame:self.bounds];
        [pageView setBackgroundColor:[UIColor whiteColor]];
        
        CGRect pageFrame = pageView.frame;
        pageFrame.origin.x = xOffset;
        [pageView setFrame:pageFrame];
        
        CTFrameRef frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(pointer, attString.length - pointer), path, NULL);
        
        CFRange frameRange = CTFrameGetVisibleStringRange(frame); 
        pointer += frameRange.length;
        
        xOffset += self.bounds.size.width;
    
        [self addSubview:pageView];
        [[self pageViews] addObject:pageView];
    
        [pageView setCTFrame:frame];
        
    }

    [self setContentSize:CGSizeMake(xOffset, self.bounds.size.height)];
    
    CFRelease(path);
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

- (NSMutableAttributedString*) attributedStringForDocument:(REDocument *)document
{
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:@""];

    for (REChapter *chapter in [document chapters])
    {
        [attString appendAttributedString:[chapter attributedString]];
        [attString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    }
    
    return attString;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}


@end
