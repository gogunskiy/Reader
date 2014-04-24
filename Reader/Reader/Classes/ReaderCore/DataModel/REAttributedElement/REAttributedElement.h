//
//  REAttributedElement.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface REAttributedElement : NSObject

@property (nonatomic, strong) id paragraphStyle;
@property (nonatomic) NSString * fontName;

@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic) NSMutableArray *children;

@property (nonatomic) NSString * name;
@property (nonatomic) NSString * imagesPath;
@property (nonatomic) NSArray * csss;
@property (nonatomic) NSDictionary * attributes;
@property (nonatomic) NSString * text;
@property (nonatomic) UIColor *color;
@property (nonatomic, assign) CTTextAlignment aligment;

@property (nonatomic) NSMutableAttributedString *attributedString;

- (void) apply;

@end
