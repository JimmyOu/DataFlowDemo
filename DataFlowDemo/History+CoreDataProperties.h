//
//  History+CoreDataProperties.h
//  DataFlowDemo
//
//  Created by JimmyOu on 2017/8/1.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "History+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface History (CoreDataProperties)

@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *name;

@end

@interface History (Add)

+ (instancetype)historyWithDate:(NSDate *)date name:(NSString *)name;
+ (void)save;
+ (void)deleteObj:(NSManagedObject *)obj;
+ (void)clearAllCompletion:(void(^)())handler;

@end


@interface History (Fetch)

+ (NSFetchRequest<History *> *)fetchRequest;

+ (NSArray<History *> *)fetchHistoryWithPredicate:(NSPredicate *)predicate;

+ (NSArray<History *> *)fetchAllHistory;

@end

@interface History (Update)
// if exist history according to name ,update else add a new one to dataBase
+ (void)updateWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
