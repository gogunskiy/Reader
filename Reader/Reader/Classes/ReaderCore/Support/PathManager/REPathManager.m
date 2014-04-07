//
//  PathManager.m
//  EpubReader
//
//  Created by word on 09.05.13.
//  Copyright (c) 2013 SealPoint. All rights reserved.
//

#import "REPathManager.h"

@implementation REPathManager

+ (NSString *)documentsDirectory
{
    return (NSString *)[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
}

+ (NSString *) booksDirectory
{
    NSString *dir = [self.documentsDirectory stringByAppendingPathComponent:@"Books"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir])
    {
        [fm createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return dir;
}

+ (BOOL)createDirectory:(NSString *)directory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:directory])
    {
        [fm removeItemAtPath:directory error:nil];
    }
    
    NSError *error;
    [fm createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:&error];
    
    return error == nil;
}

+ (BOOL)fileExists:(NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (NSString *)checkAndCreateFile:(NSString *)fileName
{
	BOOL success;
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	NSString *path = [[NSString alloc] initWithString:[[REPathManager documentsDirectory] stringByAppendingPathComponent:fileName]];
    
	success = [fileManager fileExistsAtPath:path];
    
	if (success)
    {
		return path;
	}
    
	NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    
	[fileManager copyItemAtPath:filePath toPath:path error:nil];
    
    
	return path;
}


@end