//
//  REBaseParser.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REDocument.h"

typedef NS_ENUM(NSInteger, REParserType)
{
    REParserTypeEpub,
    REParserTypeTxt,
    REParserTypeHtml
};

@interface REBaseParser : NSObject

+ (REBaseParser *) parserForType:(REParserType)type;


- (void) parseAttributedDocumentFromData:(NSData *)data 
                         completionBlock:(void(^)(REDocument *document))completionBlock 
                              errorBlock:(void(^)(NSError * error))errorBlock;

@end
