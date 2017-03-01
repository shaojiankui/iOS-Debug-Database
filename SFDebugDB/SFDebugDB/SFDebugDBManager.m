//
//  SFDebugDBManager.m
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import "SFDebugDBManager.h"
@interface SFDebugDBManager()
@property(strong,nonatomic) NSString *dbPath;
@property(strong,nonatomic) NSString *dbName;
@end

@implementation SFDebugDBManager
+ (SFDebugDBManager*)sharedManager
{
    static SFDebugDBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
- (NSDictionary*)getTableData{
    return nil;
}
- (BOOL)openDatabase:(NSString*)databasePath{
    if (self.dbPath && _db && ![databasePath isEqualToString:self.dbPath])
    {
        [self close];
    }
    self.dbPath = databasePath;
    //多线程模式
    sqlite3_config(SQLITE_CONFIG_MULTITHREAD);
    //串行
    //sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    //单线程
    // sqlite3_config(SQLITE_CONFIG_SINGLETHREAD);
    NSString *dbDir = [self.dbPath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbDir]) {
//        [[NSFileManager defaultManager] createDirectoryAtPath:dbDir withIntermediateDirectories:YES attributes:nil error:NULL];
        return NO;
    }
    
    if (sqlite3_open([self.dbPath UTF8String], &_db) != SQLITE_OK)
    {
        [self close];
        NSLog(@"Open Database faild。");
        return NO;
    }
    char *errorMsg = nil;
    if (sqlite3_exec(_db, "PRAGMA journal_mode=WAL;", NULL, NULL, &errorMsg) != SQLITE_OK) {
        NSLog(@"Failed to set WAL mode: %s",errorMsg);
    }
    sqlite3_wal_checkpoint(_db, NULL);
    //NSLog(@"Open Database success。");
    return YES;
    
}
- (NSArray*)getAllTableName:(sqlite3 *)db{
    NSArray *descs = [self executeQuery:@"SELECT tbl_name FROM sqlite_master WHERE type = 'table'" rowType:RowTypeObject];
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *row in descs) {
        NSString *tblName = [row objectForKey:@"tbl_name"];
        [result addObject:tblName];
    }
    return result;
}

#pragma mark - execute methods
/**
 *  无结果集执行更新
 *
 *  @param sql 完整sql语句
 *
 *  @return 操作结果
 */
-(BOOL)executeUpdate:(NSString*)sql{
    char *err;
    if (sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        //        sqlite3_close(_db);
        NSLog(@"Database Opration faild!:%s",err);
        return NO;
    }else{
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //            NSLog(@"Database Opration success!:%@",sql);
        //        });
        return YES;
    }
}
/**
 *  查询结果集
 *
 *  @param query sql语句
 *  @param type  row对象类型枚举,关联对象/关联数组
 *
 *  @return 结果集
 */
- (NSArray *)executeQuery:(NSString *)query rowType:(RowType)type;
{
    __block NSMutableArray *result = [NSMutableArray array];
    [self executeQuery:query rowType:type withBlock:^(id row, NSError *error, BOOL finished) {
        if (!error)
        {
            if (!finished) {
                [result addObject:row];
            } else {
                // NSLog(@"Query finished!");
            }
        } else {
            NSLog(@"Query error!");
        }
    }];
    
    return result;
}
/**
 *  查询遍历器
 *
 *  @param query          sql语句
 *  @param type           ow对象类型,关联对象/关联数组
 *  @param fetchItemBlock 遍历block,id row为每一条记录对应的对象或者数组
 */
-(void)executeQuery:(NSString *)query rowType:(RowType)type withBlock:(FetchItemBlock)fetchItemBlock{
    
    NSString *fixedQuery = [query stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    //    for (int i = 0; i < [params count]; i++) {
    //        id obj = [params objectAtIndex:i];
    //        if ([obj isKindOfClass:[NSString class]]) {
    //            const char * utfString = [(NSString *)obj UTF8String];
    //            sqlite3_bind_text(stmt, i+1, utfString,
    //                              (int)strlen(utfString), SQLITE_TRANSIENT);
    //        } else if ([obj isKindOfClass:[NSData class]]) {
    //            sqlite3_bind_blob(stmt, i+1, [(NSData *)obj bytes],
    //                              (int)[(NSData *)obj length], SQLITE_TRANSIENT);
    //        } else if ([obj isKindOfClass:[NSNumber class]]) {
    //            if ([(NSNumber *)obj doubleValue] == (double)([(NSNumber *)obj longLongValue])) {
    //                sqlite3_bind_double(stmt, i+1, [(NSNumber *)obj doubleValue]);
    //            } else {
    //                sqlite3_bind_int64(stmt, i+1, [(NSNumber *)obj longLongValue]);
    //            }
    //        }
    //    }
    //
    sqlite3_stmt *statement;
    const char *tail;
    __unused int resultCode = sqlite3_prepare_v2(_db, [fixedQuery UTF8String], -1, &statement, &tail);
    if (statement) {
        
        int num_cols, i, column_type;
        id obj;
        NSString *key;
        NSMutableDictionary *row;
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            row = [NSMutableDictionary dictionary];
            num_cols = sqlite3_data_count(statement);
            for (i = 0; i < num_cols; i++) {
                obj = nil;
                column_type = sqlite3_column_type(statement, i);
                switch (column_type) {
                    case SQLITE_INTEGER:
                        obj = [NSNumber numberWithLongLong:sqlite3_column_int64(statement, i)];
                        break;
                    case SQLITE_FLOAT:
                        obj = [NSNumber numberWithDouble:sqlite3_column_double(statement, i)];
                        break;
                    case SQLITE_TEXT:
                        obj = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, i)];
                        break;
                    case SQLITE_BLOB:
                        obj = [NSData dataWithBytes:sqlite3_column_blob(statement, i) length:sqlite3_column_bytes(statement, i)];
                        break;
                    case SQLITE_NULL:
                        obj = [NSNull null];
                        break;
                    default:{
                        NSLog(@"[SQLITE] UNKNOWN DATATYPE");
                    }
                        break;
                }
                
                key = [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
                [row setObject:obj?:@"" forKey:key];
            }
            if (type == RowTypeArray) {
                if (fetchItemBlock) {
                    fetchItemBlock([row allValues], nil, NO);
                }
            }else{
                if (fetchItemBlock) {
                    fetchItemBlock(row, nil, NO);
                }
            }
            
        }
        
        sqlite3_finalize(statement);
        if(fetchItemBlock){
            fetchItemBlock(nil, nil, YES);
        }
        
    }else
    {
        NSLog(@"statement is NULL,sql:%@",fixedQuery);
        fetchItemBlock(nil, [NSError errorWithDomain:@"statement is NULL" code:21323 userInfo:@{@"statement为空": @"中文",@"stmt is NULL":@"English"}], YES);
        
    }
    
}

- (BOOL)close
{
    if (_db != NULL)
    {
        if(sqlite3_close(_db) == SQLITE_OK)
        {
            //NSLog(@"Close Database success。");
            return YES;;
        }
        else
        {
            NSLog(@"Close Database faild: %s",sqlite3_errmsg(_db));
            return NO;
        }
    }else{
        NSLog(@"Cannot close a database that is not open.");
    }
    return YES;
}
@end
