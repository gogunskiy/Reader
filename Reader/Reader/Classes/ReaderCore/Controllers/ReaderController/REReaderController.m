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
    NSString *string = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    REBaseParser * parser = [REBaseParser parserForType:REParserTypeEpub];
    
    NSString *bookFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"000000000002.epub"];
 
    [parser parseBookAtPath:bookFilePath
            completionBlock:^(REDocument *document)
     {
         
     }
                 errorBlock:^(NSError *error)
     {
         
     }];
    
    [parser parseDataToAttributedString:string
                        completionBlock:^(REChapter *chapter)
     {
         REDocument *document = [REDocument new];
         [[document chapters] addObject:chapter];
         
         completionBlock(document);
     }
                             errorBlock:errorBlock];
}

@end
