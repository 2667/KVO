//
//  NSObject+KVO.h
//  KVODemo
//
//  Created by kevin on 16/9/18.
//  Copyright © 2016年 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KVO)

- (void)addObserverBlockForKeyPath:(NSString *)keyPath block:(void(^)(__weak id obj, id oldValue,  id newValue))block;

- (void)removeObserverBlockForKeyPath:(NSString *)keyPath;

- (void)removeAllObserverBlocks;
@end
