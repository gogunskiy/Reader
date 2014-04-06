//
//  REEpubParser.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REEpubParser.h"
#import "REChapter.h"
#import "ZipArchive.h"
#import "NSString+HTML.h"
#import "REAttributedElement.h"
#import "RXMLElement.h"
#import "REPathManager.h"

@implementation REEpubParser

#pragma mark - Chapter Parsing -

- (void) parseBookAtPath:(NSString *)path
         completionBlock:(void(^)(REDocument *document))completionBlock
              errorBlock:(void(^)(NSError * error))errorBlock
{
    NSString * booksDirectory = [[REPathManager booksDirectory] stringByAppendingPathComponent:[path lastPathComponent]];
    
    [self unzipEpub:path
          directory:booksDirectory
         completion:^(BOOL saved)
    {
             
    }];
}

- (void) parseDataToAttributedString:(NSString *)data
                     completionBlock:(void(^)(REChapter *chapter))completionBlock
                          errorBlock:(void(^)(NSError * error))errorBlock
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:@""];
    
    RXMLElement *htmlTree = [[RXMLElement alloc] initFromHTMLString:data encoding:NSUTF8StringEncoding];
    
    NSArray *elements = [self childAttributedElementsFor:htmlTree];

    for (REAttributedElement *element in elements)
    {
        [result appendAttributedString:[element attributedString]];
        [result appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    
    REChapter *chapter = [[REChapter alloc] init];
    [chapter setAttributedString:result];
    
    
    completionBlock(chapter);
}

- (NSArray *) childAttributedElementsFor:(RXMLElement *)element
{
    NSMutableArray *attributedElements = [[NSMutableArray alloc] init];
    
    NSArray *children = [element childrenWithRootXPath:@"//*"];
    
    for (RXMLElement *child in children)
    {
        if (![[child tag] isInlineTag] && ![[child tag] isMetaTag])
        {
            REAttributedElement *element = [[REAttributedElement alloc] init];
            [element setText:[child xml]];
            [element setName:[child tag]];
            
            NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
            
            for (NSString *attrName in [child attributeNames])
            {
                attributes[[attrName lowercaseString]] = [[child attribute:attrName] lowercaseString];
            }
            
            [element setAttributes:attributes];
            
            [element apply];
            
            [attributedElements addObject:element];
        }
    }
    
    return attributedElements;
}

#pragma mark - File Management -

- (void) unzipEpub:(NSString *)epubPath directory:(NSString *)directory completion:(void(^)(BOOL saved))completion
{
    ZipArchive *zip = [ZipArchive new];
    
    if (![REPathManager createDirectory:directory])
    {
        completion(0);
    }
    
    
    if (![zip UnzipOpenFile:epubPath])
    {
        completion(0);
    }
    
    BOOL retVal = [zip UnzipFileTo:directory overWrite:YES];
    
    [zip UnzipCloseFile];
    
    completion(retVal);
}

@end
