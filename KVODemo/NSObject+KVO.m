//
//  NSObject+KVO.m
//  KVODemo
//
//  Created by kevin on 16/9/18.
//  Copyright © 2016年 kevin. All rights reserved.
//

#import "NSObject+KVO.h"

#import <objc/objc.h>
#import <objc/runtime.h>

@interface _NSObjectKVOBlockTarget : NSObject

@property (nullable,nonatomic,copy) void(^block)(__weak id obj, id oldValue, id newValue);

@end

@implementation _NSObjectKVOBlockTarget

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (id)initWithBlock:(void(^)(__weak id obj, id oldValue, id newValue))block
{
    
    self = [super init];
    if (self)
    {
        self.block = block;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (!self.block)
    {
        return;
    }
    
    BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
    if (isPrior) return;
    
    NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if (changeKind != NSKeyValueChangeSetting) return;
    
    id oldVal = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldVal == [NSNull null]) oldVal = nil;
    
    id newVal = [change objectForKey:NSKeyValueChangeNewKey];
    if (newVal == [NSNull null]) newVal = nil;
    
    self.block(object, oldVal, newVal);
    
}

@end

static const int block_key;

@implementation NSObject (KVO)

- (void)addObserverBlockForKeyPath:(NSString *)keyPath block:(void(^)(__weak id obj, id oldValue,  id newValue))block
{
    
    if (!keyPath || !block)
    {
        return ;
    }
    
    _NSObjectKVOBlockTarget *target = [[_NSObjectKVOBlockTarget alloc] initWithBlock:block];
    
    NSMutableDictionary *dic = [self _allNSObjectObserverBlocks];
    
    NSMutableArray      *arr = dic[keyPath];
    if (!arr)
    {
        arr = [NSMutableArray new];
        dic[keyPath] = arr;
    }
    [arr addObject:target];
    [self addObserver:target forKeyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew  context:nil];
}

- (void)removeObserverBlockForKeyPath:(NSString *)keyPath
{
    if (!keyPath)
    {
        return;
    }
    
    NSMutableDictionary *dic = [self _allNSObjectObserverBlocks];
    
    NSMutableArray      *arr = dic[keyPath];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeObserver:obj forKeyPath:keyPath];
    }];
    
    [dic removeObjectForKey:keyPath];
}

- (void)removeAllObserverBlocks
{
    NSMutableDictionary *dic = [self _allNSObjectObserverBlocks];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSArray * _Nonnull arr, BOOL * _Nonnull stop) {
       [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           [self removeObserver:obj forKeyPath:key];
       }];
    }];
}

- (NSMutableDictionary *)_allNSObjectObserverBlocks {
    
    NSMutableDictionary *targets = objc_getAssociatedObject(self, &block_key);
    
    if (!targets) {
        targets = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return targets;
}



@end
