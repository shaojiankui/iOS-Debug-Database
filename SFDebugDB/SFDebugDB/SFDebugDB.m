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
    SFDebugDB *debugDB = [[SFDebugDB shared] initWithPort:port directorys:directorys];
    if (isatty(STDOUT_FILENO) || [[UIDevice sf_platformString]isEqualToString:@"Simulator"]) {
        [debugDB startServer];
        [self startRouter:debugDB];
    }else{
        debugDB.enableInAnyEnvironment = NO;
        NSLog(@"未连接Xcode的真机默认不能调试，设置enableInAnyEnvironment为YES开启调试");
    }
    return debugDB;
}
-(void)setEnableInAnyEnvironment:(BOOL)enableInAnyEnvironment{
    if (!_enableInAnyEnvironment) {
        [[SFDebugDB shared] startServer];
        [[self class] startRouter:[SFDebugDB shared]];
    }
    _enableInAnyEnvironment = enableInAnyEnvironment;
}
- (BOOL)startServer{
    _server =  [[SFDebugDBServer alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if ([_server acceptOnPort:self.port error:&error]) {
        NSLog(@"server start on %@:%zd",_server.localHost,_server.localPort);
        _host = _server.localHost;
        return YES;
    }else{
        NSLog(@"error %@",error);
        return NO;
    }
    return NO;
}
+(void)startRouter:(SFDebugDB*)debugDB{
    
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
    
    [debugDB router:@"GET" extension:@".icon" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
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
        response.html =  [SFDebugDBQueryRespone getTableListResponse:request.path databases:debugDB.databases];
        return response;
    }];
    
    [debugDB router:@"GET" basePath:@"/getAllDataFromTheTable" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
        response.html =  [SFDebugDBQueryRespone getAllDataFromTheTableResponse:request.path];
        response.contentType =  @"application/json";
        return response;
    }];
    
    [debugDB router:@"GET" basePath:@"/updateTableData" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
        response.contentType =  @"application/json";
        response.html =  [SFDebugDBQueryRespone updateTableDataAndGetResponse:request.path];
        return response;
    }];
    
    [debugDB router:@"GET" basePath:@"/deleteTableData" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
        response.contentType =  @"application/json";
        response.html =  [SFDebugDBQueryRespone deleteTableDataAndGetResponse:request.path];
        return response;
    }];
    
    [debugDB router:@"GET" basePath:@"/query" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
        response.contentType =  @"application/json";
        response.html =  [SFDebugDBQueryRespone executeQueryAndGetResponse:request.path];
        return response;
    }];
    
    [debugDB router:@"GET" basePath:@"/downloadDb" handler:^SFDebugDBRespone *(SFDebugDBRequest *request) {
        SFDebugDBRespone *response = [[SFDebugDBRespone alloc]init];
        response.contentType =  @"application/octet-stream";
        response.htmlData =  [SFDebugDBQueryRespone getDatabase:request.path  databases:debugDB.databases];
        response.contentDisposition =[NSString stringWithFormat:@"Content-Disposition: attachment; filename=%@",@"export.sqlite"];
        return response;
    }];
    
}

- (instancetype)initWithPort:(NSInteger)port directorys:(NSArray*)directorys{
    self = [super init];
    if (self) {
        _port = port;
        _directorys = directorys;
        _databases = [self databasesList:directorys];
    }
    return self;
}
-(NSString *)address{
    return [NSString stringWithFormat:@"http://%@:%zd",[SFDebugDB shared].host,[SFDebugDB shared].port];
}
- (NSDictionary*)databasesList:(NSArray*)databaseDirectorys{
    NSMutableDictionary *databasePaths = [NSMutableDictionary dictionary];
    for (NSString *directory in databaseDirectorys) {
        NSArray *dirList = [[[NSFileManager defaultManager] subpathsAtPath:directory] pathsMatchingExtensions:@[@"sqlite",@"SQLITE",@"db",@"DB"]];
        for (int i=0;i<[dirList count];i++) {
            NSString *suffix = [dirList[i] lastPathComponent];
            [databasePaths setObject:[directory stringByAppendingPathComponent:suffix] forKey:suffix];
        }
        if ([directory isEqualToString:@"NSUserDefault"]) {
            [databasePaths setObject:@"NSUserDefault" forKey:@"NSUserDefault"];
        }
        if ([directory hasSuffix:@"sqlite"] || [directory hasSuffix:@"SQLITE"]|| [directory hasSuffix:@"db"]|| [directory hasSuffix:@"DB"]) {
            [databasePaths setObject:directory forKey:directory.lastPathComponent];
        }
    }
    return databasePaths;
}
- (void)router:(NSString*)method basePath:(NSString*)basePath handler:(SFDebugRouterHandler)handler{
    [self _router:method path:basePath type:@"basepath" handler:handler];
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
            else if ([router.type isEqualToString:@"basepath"]) {
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


