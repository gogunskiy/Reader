//
//  REMainReaderView.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REMainReaderView.h"
#import <CoreText/CoreText.h>

@implementation REMainReaderView


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

	// create a font, quasi systemFontWithSize:24.0
	CTFontRef sysUIFont = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 24.0, NULL);
    
	// create a naked string
	NSString *string = @"Some Text";
    
	// blue
	CGColorRef color = [UIColor blueColor].CGColor;
    
	// single underline
	NSNumber *underline = [NSNumber numberWithInt:kCTUnderlineStyleSingle];
    
	// pack it into attributes dictionary
	NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (__bridge id)sysUIFont, (id)kCTFontAttributeName,
                                    color, (id)kCTForegroundColorAttributeName,
                                    underline, (id)kCTUnderlineStyleAttributeName, nil];
    
	// make the attributed string
	NSAttributedString *stringToDraw = [[NSAttributedString alloc] initWithString:string
                                                                       attributes:attributesDict];
    
	// now for the actual drawing
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	// flip the coordinate system
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
	// draw
	CTLineRef line = CTLineCreateWithAttributedString(
                                                      (CFAttributedStringRef)stringToDraw);
	CGContextSetTextPosition(context, 140.0, 40.0);
	CTLineDraw(line, context);
    
	// clean up
	CFRelease(line);
	CFRelease(sysUIFont);


}


@end
