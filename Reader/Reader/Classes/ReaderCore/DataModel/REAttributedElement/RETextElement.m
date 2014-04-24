//
//  RETextElement.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/24/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "RETextElement.h"

@implementation RETextElement

- (instancetype)init
{
    self = [super init];
    
    if (self) 
    {
        [self setChildren:[NSMutableArray new]];
        [self setAttributes:[NSMutableDictionary new]];
        
        [self setColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]];
        [self setFontSize:20];
        [self setFontName:@"IowanOldStyle-Roman"];
    }
    
    return self;
}

- (NSMutableAttributedString *) attributedString
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    if ([[self children] count]) 
    {
        for (RETextElement *element in [self children]) 
        {
            [attributedString appendAttributedString:[element attributedString]];
        }
    }
    else
    {
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[self text]]];
    }
    
    CTFontRef font = [self _font];
    
    CTParagraphStyleRef paragraphStyle = [SETTINGS baseParagraphStyle];
    [self setParagraphStyle:(__bridge id)paragraphStyle];
    
    [attributedString setAttributes:@{(id)kCTForegroundColorAttributeName : [self color],
                                      (id)kCTParagraphStyleAttributeName : [self paragraphStyle],
                                      (id)kCTKernAttributeName : @0}
                              range:NSMakeRange(0, attributedString.length)];
   
    
    if (self.node.nodetype == HTMLStrongNode) 
    {
        CTFontRef boldFont = CTFontCreateCopyWithSymbolicTraits(font, CTFontGetSize(font), NULL, kCTFontBoldTrait, kCTFontBoldTrait);
        [attributedString addAttribute:(id)kCTFontAttributeName value: (__bridge id)boldFont range:NSMakeRange(0, attributedString.length)];
        
        NSLog(@"%@ : %@ %@", self.node.tagName, self.node.contents, self.node.rawContents);
        
    //    [self applyBoldAttributedString:&attributedString range:NSMakeRange(0, attributedString.length)];
    }

    
    CFRelease(font);
    CFRelease(paragraphStyle);
    
    if ([self.node.tagName isEqualToString:@"i"]) 
    {
        [self applyItalicAttributedString:&attributedString range:NSMakeRange(0, attributedString.length)];
    }
    
    return attributedString;
}

- (CTFontRef) _font
{
    return [self _fontWithName:_fontName 
                          size:_fontSize];
}

- (CTFontRef) _fontWithName:(NSString *)name size:(CGFloat)size
{
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)name, size, NULL);
    return fontRef;
}

- (void) applyBoldAttributedString:(NSMutableAttributedString **)attributedString range:(NSRange)range 
{
    CTFontRef font = [self _font];
    CTFontRef boldFont = CTFontCreateCopyWithSymbolicTraits(font, CTFontGetSize(font), NULL, kCTFontBoldTrait, kCTFontBoldTrait);
    [*attributedString addAttribute:(id)kCTFontAttributeName value: (__bridge id)boldFont range:range];
    
    CFRelease(font);
    CFRelease(boldFont);
    
    NSLog(@"%@", *attributedString);
}

- (void) applyItalicAttributedString:(NSMutableAttributedString **)attributedString range:(NSRange)range 
{
    CTFontRef font = [self _font];
    CTFontRef italicFont = CTFontCreateCopyWithSymbolicTraits(font,  CTFontGetSize(font), NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    [*attributedString addAttribute:(id)kCTFontAttributeName value: (__bridge id)italicFont range:range];
    
    CFRelease(font);
    CFRelease(italicFont);
}

@end
