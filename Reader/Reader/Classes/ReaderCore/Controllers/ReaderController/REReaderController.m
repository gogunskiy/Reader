//
//  REReaderController.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REReaderController.h"
#import "REBaseParser.h"
#import "REPathManager.h"


@interface REReaderController()

@property (nonatomic) NSMutableArray *content;

@end


static REReaderController *shared = nil;

@implementation REReaderController

+ (instancetype) shared
{
    static dispatch_once_t once;
    
    dispatch_once(&once, ^
                  {
                      shared = [[REReaderController alloc] init];
                  });
    
    return shared;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self setContent:[[NSMutableArray alloc] initWithContentsOfFile:[REPathManager checkAndCreateFile:@"Content.plist"]]];
    }
    
    return self;
}

- (NSArray *) documents
{
    return [self content];
}


- (void) loadFile:(NSString *)filePath                        
  completionBlock:(void(^)(REDocument *document))completionBlock 
       errorBlock:(void(^)(NSError * error))errorBlock
{    
    NSString *string = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    REBaseParser * parser = [REBaseParser parserForType:REParserTypeEpub];
    
    NSString *bookFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Moskva - Petushki.epub"];
 
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
