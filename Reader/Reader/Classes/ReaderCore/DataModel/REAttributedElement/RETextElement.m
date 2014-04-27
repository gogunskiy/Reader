//
//  RETextElement.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/24/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "RETextElement.h"
#import "UIImage+Sizes.h"

@implementation RETextElement

- (instancetype)init
{
    self = [super init];
    
    if (self) 
    {
        [self setChildren:[NSMutableArray new]];
        [self setCss:[NSMutableDictionary new]];
        
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
        if ([[[self node] tagName] isEqualToString:@"table"])
        {
            for (RETextElement *element in [self children]) 
            {
                if ([element.node.tagName isEqualToString:@"thead"] || [element.node.tagName isEqualToString:@"tbody"]) 
                {
                    BOOL isHeader = [element.node.tagName isEqualToString:@"thead"];
                
                    NSArray *rows = [self tableRowDataWithElement:element isHeader:isHeader];
                    
                    for (NSDictionary *rowData in rows) 
                    {
                        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\u200a"]];
                        
                        CTRunDelegateRef delegate = [self createTableDelegateWithInfo:rowData];
                        [attributedString addAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)delegate range:NSMakeRange(attributedString.length - 1, 1)];
                        
                        CFRelease(delegate);
                    }
                } 
            }
        }
        else
        {
            for (RETextElement *element in [self children]) 
            {
                [attributedString appendAttributedString:[element attributedString]];
            }  
        }
    }
    else
    {
        _text = [[self text] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[self text]]];
        
        CTFontRef font = [self _font];
        
        CTParagraphStyleRef paragraphStyle = [SETTINGS baseParagraphStyleWithAligment:[self aligment]];
        [self setParagraphStyle:(__bridge id)paragraphStyle];
        
        [attributedString addAttribute:(id)kCTForegroundColorAttributeName  value:[self color]          range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:(id)kCTParagraphStyleAttributeName   value:[self paragraphStyle] range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:(id)kCTKernAttributeName             value: @0                   range:NSMakeRange(0, attributedString.length)];
        
        if ([[[self node] tagName] isEqualToString:@"text"])
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
                [attributedString addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(0, attributedString.length)];
            }
            
            CFRelease(font);
            CFRelease(paragraphStyle);
        }
        else if ([[[self node] tagName] isEqualToString:@"img"])
        {
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\u200a"]];
            
            NSString *fileName = [[self node] getAttributeNamed:@"src"];
            NSDictionary *attachment = @{@"aligment" : @([self aligment]),  @"fileName" : [_imagesPath stringByAppendingPathComponent:[fileName lastPathComponent]], @"attachmentType" : @"image"};
            
            CTRunDelegateCallbacks callbacks;
            callbacks.version = kCTRunDelegateVersion1;
            callbacks.dealloc = ImageDeallocationCallback;
            callbacks.getAscent = ImageGetAscentCallback;
            callbacks.getDescent = ImageGetDescentCallback;
            callbacks.getWidth = ImageGetWidthCallback;
            CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge_retained void *)attachment);
            
            [attributedString addAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)delegate range:NSMakeRange(attributedString.length - 1, 1)];
            
            CFRelease(delegate);
        }
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
                          size:[self _fontSize]];
}

- (CGFloat) _fontSize
{
    CGFloat size = [self fontSize];
    
    NSString *value = [self AllCss][@"font-size"];
    
    if (value)
    {
        size *= [value floatValue];
    }
    
    return size;
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

- (NSArray *) tableRowDataWithElement:(RETextElement *)element isHeader:(BOOL)isHeader
{
    NSMutableArray *rows = [NSMutableArray new];
    
    NSString *rowTag = isHeader ? @"th" : @"td";
    
    for (RETextElement *theadRowElement in [element children]) 
    {
        if ([theadRowElement.node.tagName isEqualToString:@"tr"]) 
        {
            NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
            [rowData setObject:[NSMutableArray new] forKey:@"cells"];
            [rowData setObject:@"tableRow"          forKey:@"attachmentType"];
            [rowData setObject:rowTag               forKey:@"userData"];
            [rowData setObject:@([self aligment])  forKey:@"aligment"];
            
            for (RETextElement *thElement in [theadRowElement children]) 
            {
                if ([thElement.node.tagName isEqualToString:rowTag]) 
                {
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
                    
                    [attributedString appendAttributedString:[thElement attributedString]];
                    [rowData[@"cells"] addObject:@{@"attributedString" : attributedString}];
                }
            }  
            
            [rows addObject:rowData];
        }
    }
    
    return rows;
}

- (CTRunDelegateRef) createTableDelegateWithInfo:(NSDictionary *)info
{
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.dealloc = TableDeallocationCallback;
    callbacks.getAscent = TableGetAscentCallback;
    callbacks.getDescent = TableGetDescentCallback;
    callbacks.getWidth = TableGetWidthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge_retained void *)info);
    
    return delegate;
}


void ImageDeallocationCallback( void* refCon )
{
    
}

CGFloat ImageGetAscentCallback( void *refCon )
{
    NSDictionary *info = (__bridge NSDictionary *)refCon;
    CGSize size = [UIImage sizeOfImageAtURL:[NSURL fileURLWithPath:info[@"fileName"]]];
    
    NSDictionary *dict = [SETTINGS attachmentMaxSize];
    
    CGFloat maxHeight = [dict[@"height"] floatValue];
    
    return size.height / 2 > maxHeight / 2 ? maxHeight / 2 : size.height / 2;
}

CGFloat ImageGetDescentCallback( void *refCon )
{
    return ImageGetAscentCallback(refCon);
}

CGFloat ImageGetWidthCallback( void* refCon)
{
    NSDictionary *dict = [SETTINGS attachmentMaxSize];
    NSDictionary *info = (__bridge NSDictionary *)refCon;
    CGSize size = [UIImage sizeOfImageAtURL:[NSURL fileURLWithPath:info[@"fileName"]]];
    
    CGFloat width = size.width > [dict[@"width"] floatValue] ? [dict[@"width"] floatValue] :  size.width;
    
    return width;
}

void TableDeallocationCallback( void* refCon )
{
    
}

CGFloat TableGetAscentCallback( void *refCon )
{
    return 60.0;
}

CGFloat TableGetDescentCallback( void *refCon )
{
    return TableGetAscentCallback(refCon);
}

CGFloat TableGetWidthCallback( void* refCon)
{
    return 600;
}


- (CTTextAlignment) aligment
{
    CTTextAlignment aligment = kCTTextAlignmentJustified;
    
    NSString *value = [self AllCss][@"text-align"];
    
    if (value)
    {
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
    }
    
    return aligment;
}

- (NSMutableDictionary *) AllCss
{
    
    if ([self.node.tagName isEqualToString:@"img"])
    {
        NSLog(@"FOUND");
    }
    
    NSMutableArray *nodesTree = [[NSMutableArray alloc] init];
    if ([self.css count])
    {
        [nodesTree addObject:self];
    }
    
    RETextElement *parent = self.parent;
    
    while (parent)
    {
        if ([parent.css count])
        {
            [nodesTree insertObject:parent atIndex:0];
        }
        
        parent = parent.parent;
    }
    
    NSMutableDictionary *css = [[NSMutableDictionary alloc] initWithDictionary:self.css];
    
    for (RETextElement *element in nodesTree)
    {
        [css addEntriesFromDictionary:element.css];
    }
    
    return css;
}


@end
