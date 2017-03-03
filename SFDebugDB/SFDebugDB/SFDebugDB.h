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
@property(nonatomic, readonly) NSString *address;

///未连接Xcode的真机默认不能调试，设置enableInAnyEnvironment为YES开启调试
@property(nonatomic, assign) BOOL enableInAnyEnvironment;

- (instancetype)init __attribute__((unavailable("Forbidden use init!")));
+ (SFDebugDB*)shared;

/**
 start SFDebugDB
 @param port some port
 @param directorys exist .sqlite or .db folder path,or database path
 @return SFDebugDB instance
 */
+ (instancetype)startWithPort:(NSInteger)port directorys:(NSArray*)directorys;

- (void)router:(NSString*)method basePath:(NSString*)basePath handler:(SFDebugRouterHandler)handler;

- (void)router:(NSString*)method path:(NSString*)path handler:(SFDebugRouterHandler)handler;

- (void)router:(NSString*)method filename:(NSString*)filename handler:(SFDebugRouterHandler)handler;

- (void)router:(NSString*)method extension:(NSString*)extension handler:(SFDebugRouterHandler)handler;
@end
