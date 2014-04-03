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

@interface REMainReaderView()

@property (nonatomic, assign) CGFloat nextPosition;
@property (nonatomic, assign) CGFloat lastDisplayedPosition;

@end

@implementation REMainReaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setNextPosition:0];
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    CTTextAlignment alignment = kCTJustifiedTextAlignment;

    CGFloat minMineHeight = 10;
    CGFloat leading = 2;
    CGFloat space = 10;
        CGFloat firstLineHeadIndent = 10;
    
    CTParagraphStyleSetting styleSettings[] = {
        
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &minMineHeight},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minMineHeight},
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &leading},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &leading},
        {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment},
        {kCTParagraphStyleSpecifierParagraphSpacing,  sizeof(CGFloat), &space},
        {kCTParagraphStyleSpecifierFirstLineHeadIndent,  sizeof(CGFloat), &firstLineHeadIndent},
    };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(styleSettings, sizeof(styleSettings) / sizeof(styleSettings[0]));
    

    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    REChapter *chapter = [[self document] chapters][0];
    
    for (REAttributedElement *element in [chapter elements]) 
    {
        NSMutableAttributedString* elementString = [[NSMutableAttributedString alloc] initWithString:[element text]];
        
        [elementString setAttributes:@{(id)kCTForegroundColorAttributeName : [element color],
                                   (id)kCTParagraphStyleAttributeName : (__bridge id)paragraphStyle}
                           range:NSMakeRange(0, elementString.length)];
     
        
        [attString appendAttributedString:elementString];
        [attString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    }
    
    CGFloat nextPos = [self nextPosition];
    CGFloat length = 2100;
    if (nextPos + length > attString.length)
    {
        length = attString.length - nextPos;
    }
    
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef frame =
    CTFramesetterCreateFrame(framesetter,
                             CFRangeMake([self nextPosition], length), path, NULL);
    
    CFRange frameRange = CTFrameGetVisibleStringRange(frame); //5
    [self setLastDisplayedPosition:frameRange.location + frameRange.length];
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFrameDraw(frame, context);
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _nextPosition = _lastDisplayedPosition;
    [self setNeedsDisplay];
}


@end
