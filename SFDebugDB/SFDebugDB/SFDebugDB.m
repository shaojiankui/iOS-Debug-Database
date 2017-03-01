//
//  SFDebugDB.m
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import "SFDebugDB.h"


@interface SFDebugDB()<GCDAsyncSocketDelegate>
{
    SFDebugDBServer *_server;
    NSMutableArray *_routers;
}
@end
@implementation SFDebugDB
+ (SFDebugDB*)shared
{
    static SFDebugDB *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}
- (NSDictionary*)getTableData{
    return nil;
}
+ (instancetype)startWithPort:(NSInteger)port directorys:(NSArray*)directorys{
    return [[SFDebugDB shared] initWithPort:port directorys:directorys];
}
- (instancetype)initWithPort:(NSInteger)port directorys:(NSArray*)directorys{
    self = [super init];
    if (self) {
        _port = port;
        _directorys = directorys;
        _server =  [[SFDebugDBServer alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        _databases = [self databasesList:directorys];
        NSError *error = nil;
        if ([_server acceptOnPort:port error:&error]) {
            NSLog(@"server start on %@:%zd",_server.localHost,_server.localPort);
        }else{
            NSLog(@"error %@",error);
        }
    }
    return self;
}
- (NSDictionary*)databasesList:(NSArray*)databaseDirectorys{
    NSMutableDictionary *databasePaths = [NSMutableDictionary dictionary];
    for (NSString *directory in databaseDirectorys) {
        NSArray *dirList = [[[NSFileManager defaultManager] subpathsAtPath:directory] pathsMatchingExtensions:@[@"sqlite",@"SQLITE"]];
        for (int i=0;i<[dirList count];i++) {
            NSString *suffix = [dirList[i] lastPathComponent];
            [databasePaths setObject:[directory stringByAppendingPathComponent:suffix] forKey:suffix];
        }
    }
    return databasePaths;
}
- (void)router:(NSString*)method rootPath:(NSString*)rootPath handler:(SFDebugRouterHandler)handler{
    [self _router:method path:rootPath type:@"rootpath" handler:handler];
}
- (void)router:(NSString*)method path:(NSString*)path handler:(SFDebugRouterHandler)handler{
    [self _router:method path:path type:@"url" handler:handler];
}
- (void)router:(NSString*)method filename:(NSString*)filename handler:(SFDebugRouterHandler)handler{
    NSString *path = [[NSBundle mainBundle]pathForResource:filename ofType:[filename pathExtension]];
    [self _router:method path:path type:@"url" handler:handler];
}
- (void)router:(NSString*)method extension:(NSString*)extension handler:(SFDebugRouterHandler)handler{
    [self _router:method path:extension type:@"extension" handler:handler];
}

- (void)_router:(NSString*)method path:(NSString*)path type:(NSString*)type handler:(SFDebugRouterHandler)handler{
    SFDebugRouter *router = [[SFDebugRouter alloc]init];
    router.method = method;
    router.path = path?:@"/";
    router.handler = handler;
    router.type = type?:@"url";
    if (!_routers) {
        _routers = [NSMutableArray array];
    }
    [_routers addObject:router];
}

-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    NSLog(@"didAcceptNewSocket");
    NSLog(@"newSocket %@ %@ %zd",newSocket.userData,newSocket.localHost,newSocket.localPort);
    
    
//    NSMutableString *serverStr = [NSMutableString string];
//    [serverStr appendString:@"connect\n"];
//    [newSocket writeData:[serverStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [newSocket readDataWithTimeout:-1 tag:0];
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"didReadData");
    NSLog(@"sock %@ %@ %zd",sock.userData,sock.localHost,sock.localPort);
    
    SFDebugDBRequest *request = [[SFDebugDBRequest alloc]initWithData:data];
    
    BOOL found = NO;
    for (SFDebugRouter *router in _routers)
    {
        if ([router.method isEqualToString:request.method] && router.handler)
        {
            if ([router.type isEqualToString:@"url"])
            {
                if ([router.path isEqualToString:request.path]) {
                    SFDebugDBRespone *respone = router.handler(request);
                    [sock writeData:respone.data withTimeout:-1 tag:0];
                    found = YES;
                }
            }
            else if ([router.type isEqualToString:@"extension"]) {
                if ([request.path hasSuffix:router.path]) {
                    SFDebugDBRespone *respone = router.handler(request);
                    [sock writeData:respone.data withTimeout:-1 tag:0];
                    found = YES;
                }
            }
            else if ([router.type isEqualToString:@"rootpath"]) {
                if ([request.path hasPrefix:router.path]) {
                    SFDebugDBRespone *respone = router.handler(request);
                    [sock writeData:respone.data withTimeout:-1 tag:0];
                    found = YES;
                }
            }
        }
    }
    if (!found) {
        NSLog(@"request.path %@ 404",request.path);
        SFDebugDBRespone *respone = [[SFDebugDBRespone alloc]initWithHTML:@"401"];
        respone.statusCode = 404;
        [sock writeData:respone.data withTimeout:-1 tag:0];
    }
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{

}


@end


