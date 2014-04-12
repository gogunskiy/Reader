//
//  REDocument.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REDocument.h"
#import "REChapter.h"

@implementation REDocument

- (instancetype)init
{
    self = [super init];
    
    if (self) 
    {
        [self setChapters:[NSMutableArray new]];
    }
    
    return self;
}

- (void) compileAttributedString
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    
    for (REChapter *chapter in [self chapters])
    {
        [result appendAttributedString: [chapter attributedString]];
        
        if ([[self chapters] indexOfObject:chapter] < [[self chapters] count] - 1) 
        {
            [result addAttribute:@"END_OF_CHAPTER" value:@1 range:NSMakeRange(result.length - 1, 1)];
        }
    }
    
    [self setAttributedString:result];
}

@end
