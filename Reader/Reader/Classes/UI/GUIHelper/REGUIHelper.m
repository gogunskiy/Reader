//
//  REGUIHelper.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/11/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REGUIHelper.h"

@implementation REGUIHelper

+ (void) customize
{
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"dot"] forState:UIControlStateNormal];
}

@end
