//
//  REChapter.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REAttributedElement.h"

@interface REChapter : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subTitle;

@property (nonatomic) NSAttributedString *attributedString;

@end
