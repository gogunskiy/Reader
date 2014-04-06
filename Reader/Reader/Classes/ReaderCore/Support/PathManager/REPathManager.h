//
//  PathManager.h
//  EpubReader
//
//  Created by word on 09.05.13.
//  Copyright (c) 2013 SealPoint. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface REPathManager : NSObject

+ (NSString *) documentsDirectory;
+ (NSString *) booksDirectory;


+ (BOOL) createDirectory:(NSString *)directory;
+ (NSString *) checkAndCreateFile:(NSString *)fileName;
+ (BOOL) fileExists:(NSString *)filePath;

@end
