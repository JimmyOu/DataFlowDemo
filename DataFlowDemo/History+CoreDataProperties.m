//
//  History+CoreDataProperties.m
//  DataFlowDemo
//
//  Created by JimmyOu on 2017/8/1.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "History+CoreDataProperties.h"
#import "CoreDataHelper.h"
@implementation History (CoreDataProperties)


@dynamic date;
@dynamic name;

@end


@implementation History (Add)

+ (instancetype)historyWithDate:(NSDate *)date name:(NSString *)name{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    History *history = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:helper.context];
    history.date = date;
    history.name = name;
    return history;
}
+ (void)save {
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    NSError *error;
    [helper.context save:&error];
    if (error) {
        NSLog(@"%s --> saving history Error = %@",__func__,error);
    }
}
+ (void)deleteObj:(NSManagedObject *)obj;{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    [helper.context deleteObject:obj];
}

+ (void)clearAllCompletion:(void (^)())handler{
    NSArray <History *>*all = [self fetchAllHistory];
    [all enumerateObjectsUsingBlock:^(History * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self deleteObj:obj];
    }];
    
    if (handler) {
        handler();
    }
}

@end

@implementation History (Fetch)

+ (NSFetchRequest<History *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"History"];
}

+ (NSArray<History *> *)fetchHistoryWithPredicate:(NSPredicate *)predicate {
    NSManagedObjectContext *context = [CoreDataHelper sharedInstance].context;
    NSFetchRequest *request = [self fetchRequest];
    request.predicate = predicate;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    request.sortDescriptors = @[sort];
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    return array;
}

+ (NSArray<History *> *)fetchAllHistory {
   return [self fetchHistoryWithPredicate:nil];
    
}

@end


@implementation History (Update)

+ (void)updateWithName:(NSString *)name {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@",name];;
    NSArray <History *>*matches = [[self class] fetchHistoryWithPredicate:predicate];
    if (matches.count > 0) {
       History *match = [matches firstObject];
        match.date = [NSDate date];
        [[self class] save];
    } else {
        [History historyWithDate:[NSDate date] name:name];
        [[self class] save];
    }
}



@end
