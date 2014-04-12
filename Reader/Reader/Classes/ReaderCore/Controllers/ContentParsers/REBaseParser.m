//
//  REBaseParser.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REBaseParser.h"
#import "REEpubParser.h"

@implementation REBaseParser

+ (REBaseParser *) parserForType:(REParserType)type
{
    switch (type) 
    {
        case REParserTypeEpub:
        {
            return [[REEpubParser alloc] init];
            break;
        }
            
        case REParserTypeTxt:
        {
            break;
        }
            
        case REParserTypeHtml:
        {
            break;
        }
            
        default:
            break;
    }
    
    return nil;
}

- (void) parseBookAtPath:(NSString *)path
         completionBlock:(void(^)(REDocument *document))completionBlock
              errorBlock:(void(^)(NSError * error))errorBlock
{
    
}

- (void) parseChapterToAttributedStringInDoucment:(REDocument *)document
                                      chapterInfo:(NSDictionary *)chapterInfo
                                  completionBlock:(void(^)(REChapter *chapter))completionBlock
                                       errorBlock:(void(^)(NSError * error))errorBlock
{

}

@end
