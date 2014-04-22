//
//  REReaderController.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>

#define READER [REReaderController shared]

@class REDocument;

@interface REReaderController : NSObject

+ (instancetype) shared;

- (NSArray *) documents;

- (void) addDocumentToLibraryWithTitle:(NSString *)title
                           description:(NSString *)description
                                author:(NSString *)author
                            sourcePath:(NSString *)sourcePath;

- (void) loadDocumentWithPath:(NSString *)filePath
                progressBlock:(void(^)(REDocument *document))progressBlock
              completionBlock:(void(^)(REDocument *document))completionBlock
                   errorBlock:(void(^)(NSError * error))errorBlock;

@end
