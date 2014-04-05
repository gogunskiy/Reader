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
    REInnerTagUnderlined = 1 << 3
};


@interface REInnerTagAttribute : NSObject <NSCopying>

@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger end;
@property (nonatomic, assign) REInnerTagType type;

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
    return [NSString stringWithFormat:@"{%d,%d} - %d",self.start, self.end, self.type];
}

@end

@implementation REAttributedElement

- (instancetype)init
{
    self = [super init];
    
    if (self) 
    {
        [self setChildren:[NSMutableArray new]];
    }
    
    return self;
}

- (NSAttributedString *) attributedString
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
            [resultString appendString:character];
        }
        
        if ([character isEqualToString:@">"])
        {
            inTag = FALSE;
            
            NSLog(@"%@", tag);
            
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
            
            tag = [NSMutableString stringWithFormat:@""];
        }
    }
    
    if ([attributes count])
        NSLog(@"%@", attributes);

    
    //           CTFontRef italicFont = CTFontCreateCopyWithSymbolicTraits(self.font, 12, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
    //[elementString addAttribute:(id)kCTFontAttributeName value: (__bridge id)italicFont range:NSMakeRange(start.location, end.location - (start.location + start.length))];
    
    NSMutableAttributedString* elementString = [[NSMutableAttributedString alloc] initWithString:resultString];
    
    
    [elementString setAttributes:@{(id)kCTForegroundColorAttributeName : [self color],
                                   (id)kCTParagraphStyleAttributeName : (__bridge id)[self paragraphStyle],
                                   (id)kCTFontAttributeName : (__bridge id)[self font]}
                           range:NSMakeRange(0, elementString.length)];
    
    
    for (REInnerTagAttribute *attribute in attributes) 
    {
        if ([attribute type] == REInnerTagBold) 
        {
            CTFontRef italicFont = CTFontCreateCopyWithSymbolicTraits(self.font, 14, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
            NSRange range = NSMakeRange(attribute.start, attribute.end - attribute.start);
            [elementString addAttribute:(id)kCTFontAttributeName value: (__bridge id)italicFont range:range];
        }
        else if ([attribute type] == REInnerTagItalic) 
        {
            CTFontRef italicFont = CTFontCreateCopyWithSymbolicTraits(self.font, 14, NULL, kCTFontItalicTrait, kCTFontItalicTrait);
            NSRange range = NSMakeRange(attribute.start, attribute.end - attribute.start);
            [elementString addAttribute:(id)kCTFontAttributeName value: (__bridge id)italicFont range:range];
        }      
        else if ([attribute type] == REInnerTagUnderlined) 
        {
            NSRange range = NSMakeRange(attribute.start, attribute.end - attribute.start);
            [elementString addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:range];
        }
    }
    
    return elementString;
}

- (void) setName:(NSString *)name
{
    _name = name;
    
    [self applyParagraphStyleForElementName:name];
}

- (void) applyParagraphStyleForElementName:(NSString *)name
{
    if ([name isEqualToString:@"header"])
    {
        [self setParagraphStyle:[self _headerParagraphStyle]];        
        [self setFont:  [self _fontWithName:@"Helvetica-Bold" size:20]];
    }
    else if ( [name isEqualToString:@"subheader"])
    {
        [self setParagraphStyle:[self _headerParagraphStyle]];
        [self setFont:  [self _fontWithName:@"Helvetica-Bold" size:14]];    
    }
    else 
    {
        [self setParagraphStyle:[self _baseParagraphStyle]];
        [self setFont:  [self _fontWithName:@"Helvetica" size:14]];
    }
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
        {kCTParagraphStyleSpecifierTailIndent,  sizeof(CGFloat), &linetTailIndent},
    };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(styleSettings, sizeof(styleSettings) / sizeof(styleSettings[0]));
    
    return paragraphStyle;
}

@end
