//
//  RESettings.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/7/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "RESettings.h"
#import <CoreText/CoreText.h>

@interface RESettings()

@property (nonatomic, strong) NSDictionary *settings;

@end

static RESettings *shared = nil;

@implementation RESettings


+ (instancetype) shared
{
    static dispatch_once_t once;
    
    dispatch_once(&once, ^
    {
        shared = [[RESettings alloc] init]; 
    });
    
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) 
    {
        [self setSettings:[NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"Settings.plist"]]];
    }
    return self;
}

- (CTParagraphStyleRef) headerParagraphStyle
{
    return [self _paragraphStyleForType:PARAGRAPH_STYLE_HEADER];
}

- (CTParagraphStyleRef) blockquoteParagraphStyle
{
    return [self _paragraphStyleForType:PARAGRAPH_STYLE_BLOCKQUOTE];
}

- (CTParagraphStyleRef) baseParagraphStyle
{
    return [self _paragraphStyleForType:PARAGRAPH_STYLE_BASE];
}


- (CTParagraphStyleRef) epigraphStyle
{
    return [self _paragraphStyleForType:PARAGRAPH_STYLE_EPIGRAPH];
}

- (CTParagraphStyleRef) epigraphAuthorStyle
{
    return [self _paragraphStyleForType:PARAGRAPH_STYLE_EPIGRAPH_AUTHOR];
}

#pragma mark - Private - 

- (CTParagraphStyleRef) _paragraphStyleForType:(NSString *)type
{
    CTTextAlignment aligment = [_settings[DEVICE_ID][type][aligmentKey] intValue];
    
    CGFloat minMineHeight = [_settings[DEVICE_ID][type][minRowHeightKey] floatValue];
    CGFloat leading =  [_settings[DEVICE_ID][type][leadingKey] floatValue];
    CGFloat space = [_settings[DEVICE_ID][type][spaceKey] floatValue];
    CGFloat firstLineHeadIndent =  [_settings[DEVICE_ID][type][firstLineHeadIndentKey] floatValue];
    CGFloat lineHeadIndent =  [_settings[DEVICE_ID][type][lineHeadIndentKey] floatValue];
    CGFloat linetTailIndent = [_settings[DEVICE_ID][type][linetTailIndentKey] floatValue];
    
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