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
    REInnerTagNone = 0,
    REInnerTagBold = 1 << 1,
    REInnerTagItalic = 1 << 2,
    REInnerTagUnderlined = 1 << 3,
    REInnerTagAttachment = 1 << 4,
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
    }
    
    return self;
}

- (NSMutableAttributedString *) applyAttributedString
{
    NSMutableString * inputString = [[NSMutableString alloc] initWithString:[self text]];
    NSMutableString * resultString = [[NSMutableString alloc] initWithCapacity:[inputString length]];
     
    NSMutableArray * attributes = [[NSMutableArray alloc] init];
    
    REInnerTagAttribute *bAttribute = [[REInnerTagAttribute alloc] init];
    [bAttribute setType:REInnerTagBold];
    
    REInnerTagAttribute *iAttribute = [[REInnerTagAttribute alloc] init];
    [iAttribute setType:REInnerTagItalic];
    
    REInnerTagAttribute *uAttribute = [[REInnerTagAttribute alloc] init];
    [uAttribute setType:REInnerTagUnderlined];
    
    NSScanner *scanner = [NSScanner scannerWithString:inputString];
    scanner.charactersToBeSkipped = NULL;
    NSString *tempText = nil;
    
    while (![scanner isAtEnd])
    {
        [scanner scanUpToString:@"<" intoString:&tempText];
        
        if (tempText != nil)
            [resultString appendString:tempText];
        NSString *tag = nil;
        [scanner scanUpToString:@">" intoString:&tag];
        
        if ([tag isEqualToString:@"<b"] || [tag isEqualToString:@"<strong"])
        {
            [bAttribute setStart:resultString.length];
        } 
        else  if ([tag isEqualToString:@"<i"]) 
        {
            [iAttribute setStart:resultString.length];
            
        }
        else  if ([tag isEqualToString:@"<u"]) 
        {
            [uAttribute setStart:resultString.length];
        }
        else if ([tag isEqualToString:@"</b"] || [tag isEqualToString:@"</strong"])
        {
            [bAttribute setEnd:resultString.length];
            [attributes addObject:[bAttribute copy]];
        } 
        else  if ([tag isEqualToString:@"</i"]) 
        {
            [iAttribute setEnd:resultString.length];
            [attributes addObject:[iAttribute copy]];
        }
        else  if ([tag isEqualToString:@"</u"]) 
        {
            [uAttribute setEnd:resultString.length];
            [attributes addObject:[uAttribute copy]];
        }
        else  if ([tag isEqualToString:@"</br"] || [tag isEqualToString:@"<br"] || [tag isEqualToString:@"<br/"])
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

        
        if (![scanner isAtEnd])
            [scanner setScanLocation:[scanner scanLocation] + 1];
        
        tempText = nil;
    }
    
    NSMutableAttributedString* elementString = [[NSMutableAttributedString alloc] initWithString:resultString];
    
    [elementString setAttributes:@{(id)kCTForegroundColorAttributeName : [self color],
                                   (id)kCTParagraphStyleAttributeName : (__bridge id)[self paragraphStyle],
                                   (id)kCTKernAttributeName : @0,
                                   (id)kCTFontAttributeName : (__bridge id)[self _font]}
                           range:NSMakeRange(0, elementString.length)];
    
    
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
            callbacks.dealloc = MyDeallocationCallback;
            callbacks.getAscent = MyGetAscentCallback;
            callbacks.getDescent = MyGetDescentCallback;
            callbacks.getWidth = MyGetWidthCallback;
            CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge_retained void *)attribute.info);
            
            [elementString addAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)delegate range:NSMakeRange(attribute.start - 1, 1)];
        }
    }
    
    return elementString;
}


void MyDeallocationCallback( void* refCon )
{
    
}

CGFloat MyGetAscentCallback( void *refCon )
{
    NSDictionary *info = (__bridge NSDictionary *)refCon;
    CGSize size = [UIImage sizeOfImageAtURL:[NSURL fileURLWithPath:info[@"fileName"]]];
    
    NSDictionary *dict = [SETTINGS attachmentMaxSize];
    
    CGFloat maxHeight = [dict[@"height"] floatValue];
    
    return size.height / 2 > maxHeight / 2 ? maxHeight / 2 : size.height / 2;
}

CGFloat MyGetDescentCallback( void *refCon )
{
    return MyGetAscentCallback(refCon);
}

CGFloat MyGetWidthCallback( void* refCon)
{
    NSDictionary *dict = [SETTINGS attachmentMaxSize];
    NSDictionary *info = (__bridge NSDictionary *)refCon;
    CGSize size = [UIImage sizeOfImageAtURL:[NSURL fileURLWithPath:info[@"fileName"]]];
    
    CGFloat width = size.width > [dict[@"width"] floatValue] ? [dict[@"width"] floatValue] :  size.width;
    
    return width;
}


- (void) applyItalicFontInRange:(NSRange)range
{
    CTFontRef italicFont = CTFontCreateCopyWithSymbolicTraits([self _font], [self _fontSizeWithElementName:[self name]], NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    [[self attributedString] addAttribute:(id)kCTFontAttributeName value: (__bridge id)italicFont range:range];
    CFRelease(italicFont);
}

- (void) applyBoldFontInRange:(NSRange)range
{
    CTFontRef boldFont = CTFontCreateCopyWithSymbolicTraits([self _font], [self _fontSizeWithElementName:[self name]], NULL, kCTFontBoldTrait, kCTFontBoldTrait);
    [[self attributedString] addAttribute:(id)kCTFontAttributeName value: (__bridge id)boldFont range:range];
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
    
    [self setParagraphStyle:[SETTINGS baseParagraphStyle]];
    
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
        
            [self setParagraphStyle:[SETTINGS baseParagraphStyleWithAligment:aligment]];
        }
    }

    if ([[self name] rangeOfString:@"blockquote"].length)
    {
        [self setParagraphStyle:[SETTINGS blockquoteParagraphStyle]];
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
    [[self attributedString] addAttribute:(id)kCTFontAttributeName value:(__bridge id)[self _font] range:NSMakeRange(0, self.attributedString.length)];

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
