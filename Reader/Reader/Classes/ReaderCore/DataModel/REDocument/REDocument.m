//
//  REDocument.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REDocument.h"

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

- (NSAttributedString *) attributedString
{
    return nil;
}

@end
