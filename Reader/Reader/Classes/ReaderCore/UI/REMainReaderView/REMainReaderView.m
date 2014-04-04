//
//  REMainReaderView.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REMainReaderView.h"
#import <CoreText/CoreText.h>
#import "RECoreTextNode.h"
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
    
    CTTextAlignment alignment = kCTJustifiedTextAlignment;
    
    CGFloat minMineHeight = 10;
    CGFloat leading = 2;
    CGFloat space = 10;
    CGFloat firstLineHeadIndent = 20;
    CGFloat lineHeadIndent = 5;
    CGFloat linetTailIndent = self.frame.size.width - 5;
    
    CTParagraphStyleSetting styleSettings[] = {
        
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &minMineHeight},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minMineHeight},
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &leading},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &leading},
        {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment},
        {kCTParagraphStyleSpecifierParagraphSpacing,  sizeof(CGFloat), &space},
        {kCTParagraphStyleSpecifierFirstLineHeadIndent,  sizeof(CGFloat), &firstLineHeadIndent},
        {kCTParagraphStyleSpecifierHeadIndent,  sizeof(CGFloat), &lineHeadIndent},
        {kCTParagraphStyleSpecifierTailIndent,  sizeof(CGFloat), &linetTailIndent},
    };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(styleSettings, sizeof(styleSettings) / sizeof(styleSettings[0]));
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    REChapter *chapter = [document chapters][0];
    
    for (REAttributedElement *element in [chapter elements]) 
    {
        NSMutableAttributedString* elementString = [[NSMutableAttributedString alloc] initWithString:[element text]];
        
        [elementString setAttributes:@{(id)kCTForegroundColorAttributeName : [element color],
                                       (id)kCTParagraphStyleAttributeName : (__bridge id)paragraphStyle}
                               range:NSMakeRange(0, elementString.length)];
        
        
        [attString appendAttributedString:elementString];
        [attString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    }
    
    return attString;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}


@end
