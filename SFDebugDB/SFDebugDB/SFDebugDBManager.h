//
//  SFDebugDBManager.h
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
typedef NS_ENUM(NSUInteger, RowType) {
    RowTypeObject,  //关联对象
    RowTypeArray    //关联数组
};
typedef void (^FetchItemBlock)(id row, NSError *error, BOOL finished);

@interface SFDebugDBManager : NSObject
@property(nonatomic) sqlite3 *db;

+ (instancetype)sharedManager;
- (BOOL)openDatabase:(NSString*)databasePath;
- (NSDictionary*)getTableData;
- (NSArray*)getAllTableName:(sqlite3 *)db;

@end
