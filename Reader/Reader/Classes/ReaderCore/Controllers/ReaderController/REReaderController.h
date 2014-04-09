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

- (void) loadDocumentWithPath:(NSString *)filePath
              completionBlock:(void(^)(REDocument *document))completionBlock
                   errorBlock:(void(^)(NSError * error))errorBlock;

@end
