//
//  REAppDelegate.m
//  Reader
//
//  Created by Vladimir Gogunsky on 4/2/14.
//  Copyright (c) 2014 Vladimir Gogunsky. All rights reserved.
//

#import "REAppDelegate.h"
#import "REGUIHelper.h"
#import "REReaderController.h"

@implementation REAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [REGUIHelper customize];
    
    /*
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }*/
    
    NSString *bookPath = [[NSBundle mainBundle] resourcePath];
    
    [READER addDocumentToLibraryWithTitle:@"000000000001"
                              description:@"000000000001"
                                   author:@"000000000001"
                               sourcePath:[bookPath stringByAppendingPathComponent:@"000000000001.epub"]];
    
    [READER addDocumentToLibraryWithTitle:@"000000000002"
                              description:@"000000000002"
                                   author:@"000000000002"
                               sourcePath:[bookPath stringByAppendingPathComponent:@"000000000002.epub"]];
    
    [READER addDocumentToLibraryWithTitle:@"000000000003"
                              description:@"000000000003"
                                   author:@"000000000003"
                               sourcePath:[bookPath stringByAppendingPathComponent:@"000000000003.epub"]];
    
    [READER addDocumentToLibraryWithTitle:@"Moskva - Petushki"
                              description:@"Moskva - Petushki"
                                   author:@"Moskva - Petushki"
                               sourcePath:[bookPath stringByAppendingPathComponent:@"Moskva - Petushki.epub"]];
    
    [READER addDocumentToLibraryWithTitle:@"bezopasnoe_obschenie"
                              description:@"bezopasnoe_obschenie"
                                   author:@"bezopasnoe_obschenie"
                               sourcePath:[bookPath stringByAppendingPathComponent:@"bezopasnoe_obschenie.epub"]];
    
    [READER addDocumentToLibraryWithTitle:@"Kak_my_prinimaem_reshenia"
                              description:@"Kak_my_prinimaem_reshenia"
                                   author:@"Kak_my_prinimaem_reshenia"
                               sourcePath:[bookPath stringByAppendingPathComponent:@"Kak_my_prinimaem_reshenia.epub"]];
    
    [READER addDocumentToLibraryWithTitle:@"Akunin_-_Skazki_dlya_idiotov"
                              description:@"Akunin_-_Skazki_dlya_idiotov"
                                   author:@"Akunin_-_Skazki_dlya_idiotov"
                               sourcePath:[bookPath stringByAppendingPathComponent:@"Akunin_-_Skazki_dlya_idiotov.epub"]];
    
    [READER addDocumentToLibraryWithTitle:@"evgenii_onegin"
                              description:@"evgenii_onegin"
                                   author:@"Pushkin"
                               sourcePath:[bookPath stringByAppendingPathComponent:@"evgenii_onegin_.epub"]];
    
    
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
