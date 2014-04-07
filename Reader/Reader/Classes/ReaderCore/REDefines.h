//
//  REDefines.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/7/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_IPAD                                                 UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#ifdef IS_IPAD
static NSString * const DEVICE_ID                              = @"iPad";
#else
static NSString * const DEVICE_ID                              = @"iPhone";
#endif

static NSString * const PARAGRAPH_STYLE_BASE                    = @"baseParagraphStyle";
static NSString * const PARAGRAPH_STYLE_HEADER                  = @"headerParagraphStyle";
static NSString * const PARAGRAPH_STYLE_EPIGRAPH                = @"epigraphStyle";
static NSString * const PARAGRAPH_STYLE_EPIGRAPH_AUTHOR         = @"epigraphAuthorStyle";
static NSString * const PARAGRAPH_STYLE_BLOCKQUOTE              = @"blockquoteParagraphStyle";

static NSString * const minRowHeightKey                         = @"minRowHeight";
static NSString * const aligmentKey                             = @"aligment";
static NSString * const leadingKey                              = @"leading";
static NSString * const spaceKey                                = @"space";
static NSString * const firstLineHeadIndentKey                  = @"firstLineHeadIndent";
static NSString * const lineHeadIndentKey                       = @"lineHeadIndent";
static NSString * const linetTailIndentKey                      = @"linetTailIndent";









