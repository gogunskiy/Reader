//
//  REAttributedElement.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REAttributedElement.h"

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
    return [NSString stringWithFormat:@"{%ld,%ld} - %ld",self.start, self.end, self.type];
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
        [self setAttachments:[NSMutableArray new]];
        [self setChildren:[NSMutableArray new]];
        
        [self setColor:[UIColor blackColor]];
        [self setFontSize:14];
        [self setFontName:@"Helvetica"];
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
                NSString * previousCharacter = [inputString substringWithRange:NSMakeRange(i - 1, 1)];
                
                if (![previousCharacter isEqualToString:@" "])
                {
                    [resultString appendString:character];
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
                NSRange range= [[self text] rangeOfString:@"src=\""];
                
                NSString *fileName = [[self text] substringFromIndex:range.location + range.length];
                fileName = [fileName substringToIndex:[fileName rangeOfString:@"\""].location];
                
                NSDictionary *attachment = @{@"fileName" : [fileName lastPathComponent], @"attachmenTtype" : @"image"};
                
                REInnerTagAttribute *attribute = [[REInnerTagAttribute alloc] init];
                attribute.type = REInnerTagAttachment;
                attribute.info = attachment;
                attribute.start = resultString.length;
                
                attribute.end = resultString.length;
                
                [attributes addObject:attribute];
                [[self attachments] addObject:attachment];
            }
            
            tag = [NSMutableString stringWithFormat:@""];
        }
    }
    
    NSMutableAttributedString* elementString = [[NSMutableAttributedString alloc] initWithString:resultString];
    
    [elementString setAttributes:@{(id)kCTForegroundColorAttributeName : [self color],
                                   (id)kCTParagraphStyleAttributeName : (__bridge id)[self paragraphStyle],
                                   (id)kCTKernAttributeName : @-.1}
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
            CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (void *)@{@"key" : @"value"});
            
            [elementString addAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)delegate range:NSMakeRange(attribute.start, 1)];
        }
    }
    
    return elementString;
}


void MyDeallocationCallback( void* refCon )
{
    
}

CGFloat MyGetAscentCallback( void *refCon )
{
    return 100.0;
}

CGFloat MyGetDescentCallback( void *refCon )
{
    return 100;
}

CGFloat MyGetWidthCallback( void* refCon)
{
    return 200;
}


- (void) applyItalicFontInRange:(NSRange)range
{
    CTFontRef italicFont = CTFontCreateCopyWithSymbolicTraits([self _font], [self _fontSizeWithElementName:[self name]], NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    [[self attributedString] addAttribute:(id)kCTFontAttributeName value: (__bridge id)italicFont range:range];
}

- (void) applyBoldFontInRange:(NSRange)range
{
    CTFontRef boldFont = CTFontCreateCopyWithSymbolicTraits([self _font], [self _fontSizeWithElementName:[self name]], NULL, kCTFontBoldTrait, kCTFontBoldTrait);
    [[self attributedString] addAttribute:(id)kCTFontAttributeName value: (__bridge id)boldFont range:range];
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
    [self setParagraphStyle:[self _baseParagraphStyle]];
    
    if ([[self name] rangeOfString:@"h"].length)
    {
        [self setParagraphStyle:[self _headerParagraphStyle]];
    }
    
    if ([[self name] rangeOfString:@"blockquote"].length)
    {
        [self setParagraphStyle:[self _blockquoteParagraphStyle]];
    }
    
    if ([[[self attributes] allValues] containsObject:@"epigraph"])
    {
        [self setParagraphStyle:[self _epigraphStyle]];
    }
    
    if ([[[self attributes] allValues] containsObject:@"epigraph-avtor"])
    {
        [self setParagraphStyle:[self _epigraphAuthorStyle]];
    }
    
    
}

- (CTFontRef) _font
{
    return [self _fontWithName:[self name] size:[self _fontSizeWithElementName:[self name]]];
}

- (void) applyFontStyle
{
    [[self attributedString] addAttribute:(id)kCTFontAttributeName value:(__bridge id)[self _font] range:NSMakeRange(0, self.attributedString.length)];

    if ([[[self attributes] allValues] containsObject:@"epigraph"])
    {
        [self applyItalicFontInRange:NSMakeRange(0, self.attributedString.length)];
    }
    
    if ([[[self attributes] allValues] containsObject:@"epigraph-avtor"])
    {
        [self applyBoldFontInRange:NSMakeRange(0, self.attributedString.length)];
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

- (CTParagraphStyleRef) _headerParagraphStyle
{
    CTTextAlignment aligment = kCTCenterTextAlignment;
    
    CGFloat minMineHeight = 10;
    CGFloat leading = 2;
    CGFloat space = 10;
    CGFloat firstLineHeadIndent = 8;
    CGFloat lineHeadIndent = 8;
    CGFloat linetTailIndent = -8;
    
    return [self _paragraphStyleWithAligment:aligment 
                               minMineHeight:minMineHeight 
                                     leading:leading 
                                       space:space
                         firstLineHeadIndent:firstLineHeadIndent
                              lineHeadIndent:lineHeadIndent
                             linetTailIndent:linetTailIndent];
}

- (CTParagraphStyleRef) _blockquoteParagraphStyle
{
    CTTextAlignment aligment = kCTCenterTextAlignment;
    
    CGFloat minMineHeight = 10;
    CGFloat leading = 2;
    CGFloat space = 10;
    CGFloat firstLineHeadIndent = 30;
    CGFloat lineHeadIndent = 30;
    CGFloat linetTailIndent = -30;
    
    return [self _paragraphStyleWithAligment:aligment
                               minMineHeight:minMineHeight
                                     leading:leading
                                       space:space
                         firstLineHeadIndent:firstLineHeadIndent
                              lineHeadIndent:lineHeadIndent
                             linetTailIndent:linetTailIndent];
}

- (CTParagraphStyleRef) _baseParagraphStyle
{
    CTTextAlignment aligment = kCTJustifiedTextAlignment;
    
    CGFloat minMineHeight = 10;
    CGFloat leading = 2;
    CGFloat space = 10;
    CGFloat firstLineHeadIndent = 20;
    CGFloat lineHeadIndent = 8;
    CGFloat linetTailIndent = -8;
    
    return [self _paragraphStyleWithAligment:aligment 
                               minMineHeight:minMineHeight 
                                     leading:leading 
                                       space:space
                         firstLineHeadIndent:firstLineHeadIndent
                              lineHeadIndent:lineHeadIndent
                             linetTailIndent:linetTailIndent];
}


- (CTParagraphStyleRef) _epigraphStyle
{
    CTTextAlignment aligment = kCTJustifiedTextAlignment;
    
    CGFloat minMineHeight = 10;
    CGFloat leading = 2;
    CGFloat space = 10;
    CGFloat firstLineHeadIndent = 100;
    CGFloat lineHeadIndent = 100;
    CGFloat linetTailIndent = -8;
    
    return [self _paragraphStyleWithAligment:aligment
                               minMineHeight:minMineHeight
                                     leading:leading
                                       space:space
                         firstLineHeadIndent:firstLineHeadIndent
                              lineHeadIndent:lineHeadIndent
                             linetTailIndent:linetTailIndent];
}

- (CTParagraphStyleRef) _epigraphAuthorStyle
{
    CTTextAlignment aligment = kCTRightTextAlignment;
    
    CGFloat minMineHeight = 10;
    CGFloat leading = 2;
    CGFloat space = 10;
    CGFloat firstLineHeadIndent = 100;
    CGFloat lineHeadIndent = 100;
    CGFloat linetTailIndent = -8;
    
    return [self _paragraphStyleWithAligment:aligment
                               minMineHeight:minMineHeight
                                     leading:leading
                                       space:space
                         firstLineHeadIndent:firstLineHeadIndent
                              lineHeadIndent:lineHeadIndent
                             linetTailIndent:linetTailIndent];
}

- (CTParagraphStyleRef) _paragraphStyleWithAligment:(CTTextAlignment)aligment 
                                      minMineHeight:(CGFloat)minMineHeight 
                                            leading:(CGFloat)leading 
                                              space:(CGFloat)space 
                                firstLineHeadIndent:(CGFloat)firstLineHeadIndent 
                                     lineHeadIndent:(CGFloat)lineHeadIndent 
                                    linetTailIndent:(CGFloat)linetTailIndent
{
    CTParagraphStyleSetting styleSettings[] = 
    {
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &minMineHeight},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minMineHeight},
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &leading},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &leading},
        {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &aligment},
        {kCTParagraphStyleSpecifierParagraphSpacing,  sizeof(CGFloat), &space},
        {kCTParagraphStyleSpecifierFirstLineHeadIndent,  sizeof(CGFloat), &firstLineHeadIndent},
        {kCTParagraphStyleSpecifierHeadIndent,  sizeof(CGFloat), &lineHeadIndent},
        {kCTParagraphStyleSpecifierTailIndent,  sizeof(CGFloat), &linetTailIndent}
    };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(styleSettings, sizeof(styleSettings) / sizeof(styleSettings[0]));
    
    return paragraphStyle;
}

@end
