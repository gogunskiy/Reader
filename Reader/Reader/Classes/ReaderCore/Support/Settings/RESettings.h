//
//  RESettings.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/7/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SETTINGS [RESettings shared]

@interface RESettings : NSObject

+ (instancetype) shared;

- (CTParagraphStyleRef) headerParagraphStyle;
- (CTParagraphStyleRef) blockquoteParagraphStyle;
- (CTParagraphStyleRef) baseParagraphStyle;
- (CTParagraphStyleRef) epigraphStyle;
- (CTParagraphStyleRef) epigraphAuthorStyle;

@end
