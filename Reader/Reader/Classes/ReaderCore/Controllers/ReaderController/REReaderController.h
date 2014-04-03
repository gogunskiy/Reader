//
//  REReaderController.h
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@class REDocument;

@interface REReaderController : NSObject

- (void) loadFile:(NSString *)filePath                        
  completionBlock:(void(^)(REDocument *document))completionBlock 
       errorBlock:(void(^)(NSError * error))errorBlock;

@end
