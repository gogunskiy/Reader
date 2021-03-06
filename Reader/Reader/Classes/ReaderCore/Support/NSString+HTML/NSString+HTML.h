//
//  NSString+HTML.h
//  CoreTextExtensions
//
//  Created by Oliver Drobnik on 1/9/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//


#define UNICODE_OBJECT_PLACEHOLDER @"\ufffc"
#define UNICODE_LINE_FEED @"\u2028"

@interface NSString (HTML)

- (BOOL)isInlineTag;
- (BOOL)isMetaTag;
- (BOOL)isNumeric;
- (float)percentValue;
- (NSString *)stringByNormalizingWhitespace;
- (BOOL)hasPrefixCharacterFromSet:(NSCharacterSet *)characterSet;
- (BOOL)hasSuffixCharacterFromSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByReplacingHTMLEntities;

@end
