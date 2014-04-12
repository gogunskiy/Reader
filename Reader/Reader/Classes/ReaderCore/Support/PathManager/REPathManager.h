
#import <Foundation/Foundation.h>

@interface REPathManager : NSObject

+ (NSString *) documentsDirectory;
+ (NSString *) booksDirectory;


+ (BOOL) createDirectory:(NSString *)directory;
+ (NSString *) checkAndCreateFile:(NSString *)fileName;
+ (BOOL) fileExists:(NSString *)filePath;

+ (NSString *) copyDocumentToLibrary:(NSString *)fileNam;

@end
