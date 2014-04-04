//
//  REEpubParser.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/3/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REEpubParser.h"
#import "RXMLElement.h"
#import "REAttributedElement.h"
#import "REChapter.h"

@implementation REEpubParser

- (void) parseAttributedDocumentFromData:(NSData *)data 
                         completionBlock:(void(^)(REDocument *document))completionBlock 
                              errorBlock:(void(^)(NSError * error))errorBlock
{
    REDocument *document = [[REDocument alloc] init];
    RXMLElement *element = [[RXMLElement alloc] initFromHTMLData:data];
    RXMLElement *chapterTag = [element childrenWithRootXPath:@"//div [@class='chapter']"][0];
   
    REAttributedElement *attrElement = [[REAttributedElement alloc] init];
    [attrElement setName:@"chapter"];
    
    REChapter *chapter = [[REChapter alloc] init];
    [[document chapters] addObject:chapter];
    
    [chapterTag iterate:@"*" 
          usingBlock:^(RXMLElement *element) 
    {
        REAttributedElement *attrElement = [[REAttributedElement alloc] init];
        [attrElement setName:@"p"];
        [attrElement setText:[element innerXml]];
        [attrElement setColor:[UIColor blackColor]];
        
        if ([[element tag] isEqualToString:@"p"]) 
        {
            [attrElement setName:@"p"];
        } 
        else if ([[element attribute:@"class"] isEqualToString:@"chapter-subtitle"])
        {
            [attrElement setName:@"subheader"];
        }  
        else if ([[element attribute:@"class"] isEqualToString:@"chapter-title"])
        {
            [attrElement setName:@"header"];
        }
        
        [[chapter elements] addObject:attrElement];
    }];
    
    completionBlock(document);
}


@end
