//
//  SFDebugDBQueryRespone.h
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFDebugDBRespone.h"
@interface SFDebugDBQueryRespone : SFDebugDBRespone
+ (NSString*)getDBListResponse:(NSArray*)databaseDirectorys;
+ (NSString*)getTableListResponse:(NSString*)route;
+ (NSString*)getAllDataFromTheTableResponse:(NSString*)route;
+ (NSString*)executeQueryAndGetResponse:(NSString*)route;
+ (NSString*)updateTableDataAndGetResponse:(NSString*)route;
@end
