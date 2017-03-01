//
//  SFDebugDB.h
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFDebugRouter.h"
#import "SFDebugDBServer.h"
#import "SFDebugDBRespone.h"
#import "SFDebugDBModel.h"
#import "SFDebugDBQueryRespone.h"
#import "SFDebugDBUtil.h"

@interface SFDebugDB : NSObject
@property(nonatomic, readonly) NSUInteger port;
@property(nonatomic, readonly) NSString *host;
@property(nonatomic, readonly) NSArray *directorys;
@property(nonatomic, readonly) NSDictionary *databases;
- (instancetype)init __attribute__((unavailable("Forbidden use init!")));
+ (SFDebugDB*)shared;

+ (instancetype)startWithPort:(NSInteger)port directorys:(NSArray*)directorys;
- (void)router:(NSString*)method basePath:(NSString*)basePath handler:(SFDebugRouterHandler)handler;

- (void)router:(NSString*)method path:(NSString*)path handler:(SFDebugRouterHandler)handler;

- (void)router:(NSString*)method filename:(NSString*)filename handler:(SFDebugRouterHandler)handler;

- (void)router:(NSString*)method extension:(NSString*)extension handler:(SFDebugRouterHandler)handler;
@end
