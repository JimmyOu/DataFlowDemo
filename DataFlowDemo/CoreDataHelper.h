//
//  CoreDataHelper.h
//  DataFlowDemo
//
//  Created by JimmyOu on 2017/8/1.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

+ (instancetype)sharedInstance;

@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (readonly, strong) NSManagedObjectContext *context;

- (void)saveContext;

@end
