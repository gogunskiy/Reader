//
//  REAttributedElement.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REAttributedElement.h"

@implementation REAttributedElement


- (void) setName:(NSString *)name
{
    _name = name;
    
    [self makeStyleChangesWithName:name];
}

- (void) makeStyleChangesWithName:(NSString *)name
{
    
}

@end
