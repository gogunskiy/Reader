//
//  REReaderController.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REReaderController.h"
#import "REBaseParser.h"

@implementation REReaderController

- (void) loadFile:(NSString *)filePath                        
  completionBlock:(void(^)(REDocument *document))completionBlock 
       errorBlock:(void(^)(NSError * error))errorBlock
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    REBaseParser * parser = [REBaseParser parserForType:REParserTypeEpub];
    
    [parser parseAttributedDocumentFromData:data 
                            completionBlock:completionBlock
                                 errorBlock:errorBlock];
}

@end
