//
//  AppDelegate.m
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import "AppDelegate.h"
#import "SFDebugDB.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    SFDebugDB *debugDB =  [SFDebugDB  startWithPort:9001 directorys:@[documents,[[NSBundle mainBundle] resourcePath]]];
 
    [debugDB router:@"GET" path:@"/" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
        NSString *index = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]initWithFile:index];
        return response;
    }];
    [debugDB router:@"GET" extension:@".js" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
//        NSLog(@"request header:%@",request.headers);
        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]initWithFileName:request.path];
        return response;
    }];
    
    [debugDB router:@"GET" extension:@".css" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
//        NSLog(@"request header:%@",request.headers);
        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]initWithFileName:request.path];
        return response;
    }];
    
    [debugDB router:@"GET" extension:@".png" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
        //        NSLog(@"request header:%@",request.headers);
        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]initWithFileName:request.path];
        return response;
    }];
    
    [debugDB router:@"GET" path:@"/getDbList" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
//        response.html =  [SFDebugDBQueryRespone getDBListResponse:debugDB.directorys];
        NSDictionary *JSON   = @{@"rows":[debugDB.databases allKeys]?:[NSNull null]};
        response.html =  [JSON sf_dic_JSONString];
        response.contentType =  @"application/json";
        return response;
    }];

    
    [debugDB router:@"GET" basePath:@"/getTableList" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
        response.contentType =  @"application/json";
        response.html =  [SFDebugDBQueryRespone getTableListResponse:request.path];
        return response;
    }];
    
    [debugDB router:@"GET" basePath:@"/getAllDataFromTheTable" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
        response.html =  [SFDebugDBQueryRespone getAllDataFromTheTableResponse:request.path];
        response.contentType =  @"application/json";
        return response;
    }];
    
//    [debugDB router:@"GET" basePath:@"/getDbList" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
//        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
//        response.contentType =  @"application/json";
//        return response;
//    }];
//    [debugDB router:@"GET" basePath:@"/updateTableData" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
//        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
//        response.contentType =  @"application/json";
//        return response;
//    }];
//    [debugDB router:@"GET" basePath:@"/deleteTableData" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
//        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
//        response.contentType =  @"application/json";
//        return response;
//    }];
//    [debugDB router:@"GET" basePath:@"/deleteTableData" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
//        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
//        response.contentType =  @"application/json";
//        return response;
//    }];
//    [debugDB router:@"GET" basePath:@"/query" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
//        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
//        response.contentType =  @"application/json";
//        return response;
//    }];
//    [debugDB router:@"GET" basePath:@"/downloadDb" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
//        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
//        response.contentType =  @"application/json";
//        return response;
//    }];

//    [[NSRunLoop mainRunLoop] run];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
