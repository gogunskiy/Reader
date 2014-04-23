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
#import "HTMLParser.h"

static NSString * const MANIFEST_PATH                   =  @"META-INF/container.xml";
static NSString * const CONTAINER_ROOTFILE_XPATH_KEY    =  @"//rootfile";

static NSString * const NAV_LABELS_XPATH_KEY            =  @"//ncx:content[@src='%@']/../ncx:navLabel/ncx:text";
static NSString * const ITEM_REF_XPATH_KEY              =  @"//opf:itemref";

static NSString * const META_TYPE_XML_KEY               = @"media-type";
static NSString * const META_TYPE_PACKAGE_XML_KEY       = @"application/oebps-package+xml";
static NSString * const META_TYPE_DTBNCX_XML_KEY        = @"application/x-dtbncx+xml";
static NSString * const META_TYPE_XHTML_XML_KEY         = @"application/xhtml+xml";
static NSString * const META_TYPE_IMAGE_KEY             = @"image/png";
static NSString * const META_TYPE_CSS_KEY               = @"text/css";


static NSString * const FULL_PATH_XML_KEY               = @"full-path";
static NSString * const ID_XML_KEY                      = @"id";
static NSString * const TEXT_XML_KEY                    = @"text";
static NSString * const MARKER_XML_KEY                  = @"marker";
static NSString * const HREF_XML_KEY                    = @"href";
static NSString * const HREF_FULL_XML_KEY               = @"hrefFull";
static NSString * const ID_REF_XML_KEY                  = @"idref";
static NSString * const ID_REF_XML_BOOK_INFO_KEY        = @"epubbooksinfo";


@implementation REEpubParser

static dispatch_queue_t parseQueue;

#pragma mark - Chapter Parsing -

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            parseQueue = dispatch_queue_create("parse", NULL);
        });
    }
    
    return self;
}

- (void) parseBookAtPath:(NSString *)path
         completionBlock:(void(^)(REDocument *document))completionBlock
              errorBlock:(void(^)(NSError * error))errorBlock
{
    NSString * booksDirectory = [[REPathManager booksDirectory] stringByAppendingPathComponent:[[path lastPathComponent] stringByDeletingPathExtension]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        [self unzipEpub:path
              directory:booksDirectory
             completion:^(BOOL saved)
        {
            [self parseManifestAndGetOpfPath:booksDirectory
                                  completion:^(NSString *path)
             {
                 [self bookFromOPFFilePath:[booksDirectory stringByAppendingPathComponent:path]
                                completion:^(NSDictionary *bookInfo)
                  {
                      REDocument *document = [[REDocument alloc] init];
                      [document setInfo:bookInfo];
                      
                      completionBlock(document);
                  }];
             }];
        }];
    });
}

- (void) parseChapterToAttributedStringInDoucment:(REDocument *)document
                                      chapterInfo:(NSDictionary *)chapterInfo
                                  completionBlock:(void(^)(REChapter *chapter))completionBlock
                                       errorBlock:(void(^)(NSError * error))errorBlock
{
    dispatch_async(parseQueue, ^
    {
        NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:@""];
        
        NSString *chapterPath = chapterInfo[@"hrefFull"];
        
        NSString *chapterContent = [NSString stringWithContentsOfFile:chapterPath encoding:NSUTF8StringEncoding error:nil];
        
        HTMLParser *htmlTree = [[HTMLParser alloc] initWithString:chapterContent error:nil];

        
        REChapter *chapter = [[REChapter alloc] init];
        [chapter setTitle:chapterInfo[@"title"]];
        
        NSArray *elements = [self childAttributedElementsFor:[htmlTree body] 
                                                    document:document];
        
        for (REAttributedElement *element in elements)
        {
            [result appendAttributedString:[element attributedString]];
           // [result appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
        
       [chapter setAttributedString:result];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            completionBlock(chapter);
        });
    });
    

}

- (NSArray *) childAttributedElementsFor:(HTMLNode *)element document:(REDocument *)document
{
    NSMutableArray *attributedElements = [[NSMutableArray alloc] init];
    
    for (HTMLNode *child in [element children])
    {
        if ([[child tagName] isEqualToString:@"div"]) 
        {
            NSArray * children = [self childAttributedElementsFor:child document:document];
            [attributedElements addObjectsFromArray:children];
        }
        else if (![[child tagName] isInlineTag] && ![[child tagName] isMetaTag])
        {
            REAttributedElement *element = [[REAttributedElement alloc] init];
            [element setText:[child rawContents]];
            [element setName:[child tagName]];
            [element setImagesPath:document.info[@"imagesPath"]];
            [element setCsss:document.info[@"css"]];
            
            NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
            
            attributes[@"class"] = [[child className] lowercaseString] ? [[child className] lowercaseString] : @"";
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
    if ([REPathManager fileExists:directory])
    {
        completion(1);
        return;
    }
    
    ZipArchive *zip = [ZipArchive new];
    
    if (![REPathManager createDirectory:directory])
    {
        completion(0);
        return;
    }
    
    
    if (![zip UnzipOpenFile:epubPath])
    {
        completion(0);
        return;
    }
    
    BOOL retVal = [zip UnzipFileTo:directory overWrite:YES];
    
    [zip UnzipCloseFile];
    
    completion(retVal);
}

- (void) parseManifestAndGetOpfPath:(NSString *)pathToSavedEpub completion:(void (^)(NSString *path))completion
{
    NSString *manifestFile = [pathToSavedEpub stringByAppendingPathComponent:MANIFEST_PATH];
    if (![REPathManager fileExists:manifestFile])
    {
        completion(nil);
    }

    RXMLElement *manifestDoc = [[RXMLElement alloc] initFromXMLFilePath:manifestFile];
    
    [manifestDoc iterate:@"rootfiles.rootfile"
              usingBlock:^(RXMLElement *element)
    {
        if ([[element attribute:META_TYPE_XML_KEY] isEqualToString:META_TYPE_PACKAGE_XML_KEY])
        {
            completion([element attribute:FULL_PATH_XML_KEY]);
        }
    }];
}


- (void) bookFromOPFFilePath:(NSString *)opfFilePath completion:(void (^)(NSDictionary *bookInfo))completion
{
    if (![REPathManager fileExists:opfFilePath])
    {
        completion(nil);
    }
    
    NSMutableArray *chapters    = [NSMutableArray new];
    NSMutableArray *styles      = [NSMutableArray new];
    NSMutableArray *images      = [NSMutableArray new];
    NSMutableArray *content     = [NSMutableArray new];
    
    __block NSString *ncxFileName = @"";
    
    
    RXMLElement *opfFile = [[RXMLElement alloc] initFromXMLFilePath:opfFilePath];

    [opfFile iterate:@"manifest.item"
          usingBlock:^(RXMLElement *element)
     {
         NSString *urlPrefix = [opfFilePath stringByDeletingLastPathComponent];
         
         NSMutableDictionary *elementInfo = [@{ID_XML_KEY : [element attribute:ID_XML_KEY],
                                              HREF_XML_KEY : [element attribute:HREF_XML_KEY],
                                              HREF_FULL_XML_KEY : [urlPrefix stringByAppendingPathComponent:[element attribute:HREF_XML_KEY]]} mutableCopy];
         
         if ([[element attribute:META_TYPE_XML_KEY] isEqualToString:META_TYPE_XHTML_XML_KEY])
         {
             [chapters addObject:elementInfo];
         }
         
         if ([[element attribute:META_TYPE_XML_KEY] isEqualToString:META_TYPE_CSS_KEY])
         {
             NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
             
             NSString *cssString = [NSString stringWithContentsOfFile:elementInfo[HREF_FULL_XML_KEY] 
                                                             encoding:NSUTF8StringEncoding 
                                                                error:nil];
             
             cssString = [cssString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
             cssString = [cssString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
             cssString = [cssString stringByReplacingOccurrencesOfString:@" " withString:@""];
             cssString = [cssString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
             cssString = [cssString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
             
             NSArray *elements = [cssString componentsSeparatedByString:@"}"];
             
             for (NSString *chunk in elements) 
             {
                 NSArray *parts = [chunk componentsSeparatedByString:@"{"];
                 
                 if (parts.count > 1) 
                 {
                     NSArray *attributes = [parts[1] componentsSeparatedByString:@";"];
                     
                     NSMutableDictionary *attrs = [[NSMutableDictionary alloc] init];
                     
                     for (NSString *attr in attributes) 
                     {
                         NSArray *parts = [attr componentsSeparatedByString:@":"];
                         if (parts.count > 1) 
                         {
                             NSString *key = parts[0];
                             NSString *value = parts[1];

                             attrs[key] = value;
                         }

                     }
                     dict[parts[0]] = attrs;
                 }
             }
             
             [styles addObject:dict];
         }
         
         if ([[element attribute:META_TYPE_XML_KEY] isEqualToString:META_TYPE_IMAGE_KEY])
         {
             [images addObject:elementInfo];
         }
         
         if ([[element attribute:META_TYPE_XML_KEY] isEqualToString:META_TYPE_DTBNCX_XML_KEY])
         {
             ncxFileName = elementInfo[HREF_FULL_XML_KEY];
         }
     }];

    RXMLElement *ncxFile = [[RXMLElement alloc] initFromXMLFilePath:ncxFileName];
    
    [ncxFile iterate:@"navMap.navPoint"
          usingBlock:^(RXMLElement *element)
     {
         RXMLElement *contentElement = [element child:@"content"];
         NSString * contentSrc = [contentElement attribute:@"src"];
         NSString * text = [[[element child:@"navLabel"] child:@"text"] text];
         
         NSArray *markerArray = [contentSrc componentsSeparatedByString:@"#"];
         NSString *marker = @"";
         
         if ([markerArray count] > 1)
         {
             marker = markerArray[1];
         }
         
         for (NSMutableDictionary *dict in chapters)
         {
             if ([contentSrc rangeOfString:dict[HREF_XML_KEY]].length > 0)
             {
                 [content addObject:@{TEXT_XML_KEY : text, HREF_FULL_XML_KEY : dict[HREF_FULL_XML_KEY], MARKER_XML_KEY : marker}];
                 dict[@"title"] = text;
                 
                 break;
             }
         }
     }];
    
    NSString *imagesPath = @"";
    
    if ([images count])
    {
        imagesPath = [images[0][HREF_FULL_XML_KEY] stringByDeletingLastPathComponent];
    }
    
    completion(@{@"chapters" : chapters, @"content" : content, @"images" : images, @"css" : styles, @"imagesPath" : imagesPath});
}


@end
