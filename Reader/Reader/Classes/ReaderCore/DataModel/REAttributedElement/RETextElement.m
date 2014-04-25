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
     
        CTFontRef font = [self _font];
        

        
        CTParagraphStyleRef paragraphStyle = [SETTINGS baseParagraphStyle];
        [self setParagraphStyle:(__bridge id)paragraphStyle];
        
        [attributedString addAttribute:(id)kCTForegroundColorAttributeName  value:[self color]          range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:(id)kCTParagraphStyleAttributeName   value:[self paragraphStyle] range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:(id)kCTKernAttributeName             value: @0                   range:NSMakeRange(0, attributedString.length)];
        
        if (self.node.nodetype == HTMLTextNode) 
        {
            BOOL isBold, isItalic, isUnderlined;
            
            [self isBold:&isBold italic:&isItalic underlined:&isUnderlined];
            
            if (isBold || isItalic || isUnderlined) 
            {
                if (isBold) 
                {
                    [self applyBoldAttributedString:&attributedString range:NSMakeRange(0, attributedString.length)];
                }
                
                if (isItalic) 
                {
                    [self applyItalicAttributedString:&attributedString range:NSMakeRange(0, attributedString.length)];
                }
                
                if (isUnderlined) 
                {
                    [self applyUnderlinedAttributedString:&attributedString range:NSMakeRange(0, attributedString.length)];
                }
            }
            else 
            {
                [attributedString addAttribute:(id)kCTFontAttributeName             value:(__bridge id)font     range:NSMakeRange(0, attributedString.length)];
            }
        }

        CFRelease(font);
        CFRelease(paragraphStyle);
    }

    return attributedString;
}

- (void) isBold:(BOOL *)bold italic:(BOOL *)italic underlined:(BOOL *)underlined
{
    HTMLNode *node = self.node.parent;
    
    BOOL isBold = FALSE;
    BOOL isItalic = FALSE;
    BOOL isUnderlined = FALSE;
    
    while (node->_node && ![node.tagName isEqualToString:@"body"]) 
    {
        if (node.nodetype == HTMLStrongNode) 
        {
            isBold = TRUE;
        }
        
        if ([node.tagName isEqualToString:@"i"] || [node.tagName isEqualToString:@"em"]) 
        {
            isItalic = TRUE;
        }
        
        if ([node.tagName isEqualToString:@"u"]) 
        {
            isUnderlined = TRUE;
        }
        
        node = node.parent;
    }
    
    *bold = isBold;
    *italic = isItalic;
    *underlined = isUnderlined;
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
}

- (void) applyItalicAttributedString:(NSMutableAttributedString **)attributedString range:(NSRange)range 
{
    CTFontRef font = [self _font];
    CTFontRef italicFont = CTFontCreateCopyWithSymbolicTraits(font,  CTFontGetSize(font), NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    [*attributedString addAttribute:(id)kCTFontAttributeName value: (__bridge id)italicFont range:range];
    
    CFRelease(font);
    CFRelease(italicFont);
}

- (void) applyUnderlinedAttributedString:(NSMutableAttributedString **)attributedString range:(NSRange)range 
{
   [*attributedString addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:range];
}

@end
