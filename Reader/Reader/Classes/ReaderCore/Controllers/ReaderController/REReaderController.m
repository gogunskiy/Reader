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

- (void) addDocumentToLibraryWithTitle:(NSString *)title
                           description:(NSString *)description
                                author:(NSString *)author
                            sourcePath:(NSString *)sourcePath
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        REBaseParser * parser = [REBaseParser parserForType:REParserTypeEpub];
        
        NSString *destinationPath = [REPathManager copyDocumentToLibrary:sourcePath];
        
        NSString * booksDirectory = [[REPathManager booksDirectory] stringByAppendingPathComponent:[[destinationPath lastPathComponent] stringByDeletingPathExtension]];
        
        [parser unzipDocument:destinationPath
                    directory:booksDirectory
                   completion:^(BOOL saved)
         {
             NSArray *result = [[self content] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(file=%@)", destinationPath]];
             
             if (result.count == 0)
             {
                 [[self content] addObject:@{@"title" : title, @"description" : description, @"author" : author, @"file" : destinationPath}];
             }
         }];
    });

}


- (void) loadDocumentWithPath:(NSString *)filePath
                progressBlock:(void(^)(REDocument *document))progressBlock
              completionBlock:(void(^)(REDocument *document))completionBlock
                   errorBlock:(void(^)(NSError * error))errorBlock
{    
    REBaseParser * parser = [REBaseParser parserForType:REParserTypeEpub];
    
    [parser parseBookAtPath:filePath
            completionBlock:^(REDocument *document)
     {
         NSArray *chaptersInfo = document.info[@"chapters"];
         
         for (NSDictionary *chapterInfo in chaptersInfo)
         {
             [parser parseChapterToAttributedStringInDoucment:document
                                                  chapterInfo:chapterInfo
                                              completionBlock:^(REChapter *chapter)
              {
                  [[document chapters] addObject:chapter];
                  
                  progressBlock(document);
                  
                  if ([[document chapters] count] == [chaptersInfo count])
                  {
                      [document compileAttributedString];
                      completionBlock(document);
                  }
              }
                                                   errorBlock:^(NSError *error)
              {
                  
              }];

         }
         
           }
                 errorBlock:^(NSError *error)
     {
         
     }];
}

@end
