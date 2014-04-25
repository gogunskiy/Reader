//
//  REAttributedElement.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REAttributedElement.h"
#import "UIImage+Sizes.h"

typedef NS_OPTIONS(NSInteger, REInnerTagType)
{
    REInnerTagNone          = 0,
    REInnerTagBold          = 1 << 1,
    REInnerTagItalic        = 1 << 2,
    REInnerTagUnderlined    = 1 << 3,
    REInnerTagAttachment    = 1 << 4,
    REInnerTagTable         = 1 << 5
};


@interface REInnerTagAttribute : NSObject <NSCopying>

@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger end;

@property (nonatomic, assign) REInnerTagType type;
@property (nonatomic, strong) NSDictionary *info;

@end

@implementation REInnerTagAttribute


- (id)copyWithZone:(NSZone *)zone
{
    REInnerTagAttribute *object = [[REInnerTagAttribute alloc] init];
    
    [object setStart:[self start]];
    [object setEnd:[self end]];
    [object setType:[self type]];
    
    return object;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{%ld,%ld} - %ld",(long)self.start, (long)self.end, (long)self.type];
}

@end

@interface REAttributedElement();

@end

@implementation REAttributedElement

- (instancetype)init
{
    self = [super init];
    
    if (self) 
    {
        [self setChildren:[NSMutableArray new]];
        
        [self setColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]];
        [self setFontSize:20];
        [self setFontName:@"IowanOldStyle-Roman"];
        [self setAttributedString:[[NSMutableAttributedString alloc] initWithString:@""]];
    }
    
    return self;
}

- (NSMutableAttributedString *) applyAttributedString
{
    NSMutableString * inputString = [[NSMutableString alloc] initWithString:[self text]];
    NSMutableString * resultString = [[NSMutableString alloc] init];
    
    NSMutableArray * attributes = [[NSMutableArray alloc] init];
    NSMutableString *tag = [[NSMutableString alloc] init];
    
    BOOL inTag = FALSE;
    
    REInnerTagAttribute *bAttribute = [[REInnerTagAttribute alloc] init];
    [bAttribute setType:REInnerTagBold];
    
    REInnerTagAttribute *iAttribute = [[REInnerTagAttribute alloc] init];
    [iAttribute setType:REInnerTagItalic];
    
    REInnerTagAttribute *uAttribute = [[REInnerTagAttribute alloc] init];
    [uAttribute setType:REInnerTagUnderlined];
    
    for (int i = 0; i < [inputString length]; i++) 
    {
        NSString * character = [inputString substringWithRange:NSMakeRange(i, 1)];
        
        if ([character isEqualToString:@"<"])
        {
            inTag = TRUE;
        }
        
        if (inTag) 
        {
            [tag appendString:character];
        }
        else
        {
            if ([character isEqualToString:@" "])
            {
                if (i)
                {
                    NSString * previousCharacter = [inputString substringWithRange:NSMakeRange(i - 1, 1)];
                    
                    if (![previousCharacter isEqualToString:@" "])
                    {
                        [resultString appendString:character];
                    }
                }
            }
            else
            {
                [resultString appendString:character];
            }
        }
        
        if ([character isEqualToString:@">"])
        {
            inTag = FALSE;
            
            if ([tag isEqualToString:@"<b>"] || [tag isEqualToString:@"<strong>"])
            {
                [bAttribute setStart:resultString.length];
            } 
            else  if ([tag isEqualToString:@"<i>"]) 
            {
                [iAttribute setStart:resultString.length];
                
            }
            else  if ([tag isEqualToString:@"<u>"]) 
            {
                [uAttribute setStart:resultString.length];
            }
            else if ([tag isEqualToString:@"</b>"] || [tag isEqualToString:@"</strong>"])
            {
                [bAttribute setEnd:resultString.length];
                [attributes addObject:[bAttribute copy]];
            } 
            else  if ([tag isEqualToString:@"</i>"]) 
            {
                [iAttribute setEnd:resultString.length];
                [attributes addObject:[iAttribute copy]];
            }
            else  if ([tag isEqualToString:@"</u>"]) 
            {
                [uAttribute setEnd:resultString.length];
                [attributes addObject:[uAttribute copy]];
            }
            else  if ([tag isEqualToString:@"</br>"] || [tag isEqualToString:@"<br>"] || [tag isEqualToString:@"<br/>"])
            {
                [resultString appendString:@"\n"];
            }
            else if ([tag rangeOfString:@"<img"].length)
            {
                [resultString appendString:@"  "];
                
                NSRange range= [[self text] rangeOfString:@"src=\""];
                
                NSString *fileName = [[self text] substringFromIndex:range.location + range.length];
                fileName = [fileName substringToIndex:[fileName rangeOfString:@"\""].location];
                
                NSDictionary *attachment = @{@"aligment" : @(_aligment),  @"fileName" : [_imagesPath stringByAppendingPathComponent:[fileName lastPathComponent]], @"attachmentType" : @"image"};
                
                REInnerTagAttribute *attribute = [[REInnerTagAttribute alloc] init];
                attribute.type = REInnerTagAttachment;
                attribute.info = attachment;
                attribute.start = resultString.length;
                
                attribute.end = resultString.length;
                
                [attributes addObject:attribute];
            }
            else if ([tag rangeOfString:@"<table"].length)
            {
                REInnerTagAttribute *tableAttribute = [[REInnerTagAttribute alloc] init];
                [tableAttribute setType:REInnerTagTable];
                
                NSRange tableEnd = [inputString rangeOfString:@"</table>"];
                
                tableAttribute.start =  resultString.length;
                tableAttribute.end =  tableEnd.location + tableEnd.length;
                    
                NSLog(@"%@", [inputString substringWithRange:NSMakeRange(tableAttribute.start, tableAttribute.end - tableAttribute.start)]);
                
                i += tableAttribute.end - 1;
                
                [attributes addObject:tableAttribute];
                
                [resultString appendString:@"  "];
            }
            
            tag = [NSMutableString stringWithFormat:@""];
        }
    }

    
    NSMutableAttributedString* elementString = [[NSMutableAttributedString alloc] initWithString:resultString];
    
    CTFontRef font = [self _font];
    
    [elementString setAttributes:@{(id)kCTForegroundColorAttributeName : [self color],
                                   (id)kCTParagraphStyleAttributeName : [self paragraphStyle],
                                   (id)kCTKernAttributeName : @0,
                                   (id)kCTFontAttributeName : (__bridge id)font}
                           range:NSMakeRange(0, elementString.length)];
    
    CFRelease(font);
    
    for (REInnerTagAttribute *attribute in attributes) 
    {
        NSRange range = NSMakeRange(attribute.start, attribute.end - attribute.start);
        
        if ([attribute type] == REInnerTagBold) 
        {
            [self applyBoldFontInRange:range];
        }
        else if ([attribute type] == REInnerTagItalic) 
        {
            [self applyItalicFontInRange:range];
        }      
        else if ([attribute type] == REInnerTagUnderlined) 
        {
            [self applyUnderlinedFontInRange:range];
        }
        else if ([attribute type] == REInnerTagAttachment)
        {
            CTRunDelegateCallbacks callbacks;
            callbacks.version = kCTRunDelegateVersion1;
            CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge_retained void *)attribute.info);
            
            [elementString addAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)delegate range:NSMakeRange(attribute.start - 1, 1)];
        }
    }
    
    return elementString;
}


- (void) applyItalicFontInRange:(NSRange)range
{
    CTFontRef font = [self _font];
    CTFontRef italicFont = CTFontCreateCopyWithSymbolicTraits(font, [self _fontSizeWithElementName:[self name]], NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    [[self attributedString] addAttribute:(id)kCTFontAttributeName value: (__bridge id)italicFont range:range];
    CFRelease(font);
    CFRelease(italicFont);
}

- (void) applyBoldFontInRange:(NSRange)range
{
    CTFontRef font = [self _font];
    CTFontRef boldFont = CTFontCreateCopyWithSymbolicTraits(font, [self _fontSizeWithElementName:[self name]], NULL, kCTFontBoldTrait, kCTFontBoldTrait);
    [[self attributedString] addAttribute:(id)kCTFontAttributeName value: (__bridge id)boldFont range:range];
    
    CFRelease(font);
    CFRelease(boldFont);
}

- (void) applyUnderlinedFontInRange:(NSRange)range
{
    [[self attributedString] addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:range];
}

- (void) apply
{
    [self applyParagraphStyle];
    [self setAttributedString:[self applyAttributedString]];
    [self applyFontStyle];
}

- (void) applyParagraphStyle
{
    NSDictionary *cssAttributes = [self _cssAttributes];
    
    CTParagraphStyleRef paragraphStyle = [SETTINGS baseParagraphStyle];
    [self setParagraphStyle:(__bridge id)paragraphStyle];
    CFRelease(paragraphStyle);
    
    if (cssAttributes) 
    {
        NSString *value = cssAttributes[@"text-align"];
        
        if (value)
        {
            CTTextAlignment aligment = kCTTextAlignmentNatural;
        
            if ([value isEqualToString:@"left"])
            {
                aligment = kCTTextAlignmentLeft;
            }
            else if ([value isEqualToString:@"right"])
            {
                 aligment = kCTTextAlignmentRight;
            }
            else if ([value isEqualToString:@"center"])
            {
                aligment = kCTTextAlignmentCenter;
            }
            else if ([value isEqualToString:@"justify"])
            {
                aligment = kCTTextAlignmentJustified;
            }
            
            [self setAligment:aligment];
        
            CTParagraphStyleRef paragraphStyle = [SETTINGS baseParagraphStyleWithAligment:aligment];
            [self setParagraphStyle:(__bridge id)paragraphStyle];
            CFRelease(paragraphStyle);
        }
    }

    if ([[self name] rangeOfString:@"blockquote"].length)
    {
        CTParagraphStyleRef paragraphStyle = [SETTINGS blockquoteParagraphStyle];
        [self setParagraphStyle:(__bridge id)paragraphStyle];
        CFRelease(paragraphStyle);
    }
    
}

- (NSDictionary *) _cssAttributes
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    
    NSString *classAttribute = [self attributes][@"class"];
    
    if (classAttribute) 
    {
        for (int i = 0; i < self.csss.count; i++) 
        {
            for (int j = 0; j < [self.csss[i] count]; j++) 
            {
                NSString *key = [self.csss[i] allKeys][j];
                NSDictionary *value = self.csss[i][key];
                
                if ([[key lowercaseString] rangeOfString:[classAttribute lowercaseString]].length) 
                {
                    [attributes addEntriesFromDictionary:value];
                }
            }
        }
    }
    
    return attributes;
}

- (CTFontRef) _font
{
    return [self _fontWithName:[self fontName] size:[self _fontSizeWithElementName:[self name]]];
}

- (void) applyFontStyle
{
    CTFontRef font = [self _font];
    [[self attributedString] addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(0, self.attributedString.length)];

    CFRelease(font);
    
    NSDictionary *cssAttributes = [self _cssAttributes];

    if (cssAttributes)
    {
        NSString *value = cssAttributes[@"font-style"];
        
        if (value)
        {
            if ([value isEqualToString:@"italic"])
            {
                [self applyItalicFontInRange:NSMakeRange(0, self.attributedString.length)];
            }
        }
        
        value = cssAttributes[@"font-weight"];
        
        if (value)
        {
            if ([value isEqualToString:@"bold"])
            {
                [self applyBoldFontInRange:NSMakeRange(0, self.attributedString.length)];
            }
        }
    }
}

- (CGFloat) _fontSizeWithElementName:(NSString *)elementName
{
    CGFloat size = [self fontSize];
    
    if ([elementName rangeOfString:@"h1"].length)
    {
        size *= 1.8;
    }
    else if ( [elementName rangeOfString:@"h2"].length)
    {
        size *= 1.6;
    }
    else if ( [elementName rangeOfString:@"h3"].length)
    {
        size *= 1.3;
    }
    else if ( [elementName rangeOfString:@"h4"].length)
    {
        size *= 1.1;
    }
    
    return size;
}

- (CTFontRef) _fontWithName:(NSString *)name size:(CGFloat)size
{
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)name, size, NULL);
    return fontRef;
}

@end
