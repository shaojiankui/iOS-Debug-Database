//
//  SFDebugDBManager.h
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
typedef NS_ENUM(NSUInteger, SFDebugDBRowType) {
    SFDebugDBRowTypeObjectWithColumInfo,  //关联对象 带列信息
    SFDebugDBRowTypeObject,  //关联对象
    SFDebugDBRowTypeArray    //关联数组
};
typedef void (^FetchItemBlock)(id row, NSError *error, BOOL finished);

@interface SFDebugDBManager : NSObject
@property(nonatomic) sqlite3 *db;
@property(strong,nonatomic) NSString *dbPath;
@property(strong,nonatomic) NSString *dbName;

+ (instancetype)sharedManager;
- (BOOL)openDatabase:(NSString*)databasePath;
- (NSArray*)getTableData:(sqlite3 *)db sql:(NSString*)sql tableName:(NSString*)tableName;
-(BOOL)executeUpdate:(NSString*)sql;

- (NSArray*)allTables;
- (NSArray*)infoForTable:(NSString *)table;
//表列数
- (NSUInteger)columnsInTable:(NSString *)table;
//所有表头
-(NSArray *)columnTitlesInTable:(NSString *)table;

-(BOOL)update:(NSString*)table data:(NSDictionary*)data where:(id)condition;
-(BOOL)delete:(NSString*)table where:(id)condition limit:(NSString*)limit;
@end
