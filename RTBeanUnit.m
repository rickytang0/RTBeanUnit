//
//  RTBeanUnit.m
//  RTBeanUnitDemo
//
//  Created by 唐 嘉宾 on 13-5-8.
//  Copyright (c) 2013年 唐 嘉宾. All rights reserved.
//

#import "RTBeanUnit.h"
#import <objc/runtime.h>

@interface RTBeanUnit ()
-(void)setupDefualtConvertBlock;
-(kClassType)getClassTypeWithObject:(id)object;
@end

@implementation RTBeanUnit

-(id)init
{
    if (self = [super init]) {
        [self setupDefualtConvertBlock];
    }
    return self;
}


-(void)setupDefualtConvertBlock
{
    //设置默认时间转换器
    [self setDateConvertBlock:^NSDate* (id data,id key){
        
        if (!data) {
            return nil;
        }
        
        if (![data isKindOfClass:[NSString class]]) {
            return nil;
        }
        
        NSString *dateString = (NSString *)data;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSDate *date1 = [formatter dateFromString: dateString];
        return date1;
    }];
    
}




-(void)setBeanWith:(NSObject *)_bean andJSONString:(NSString *)_jsonString
{
    NSString *temp = nil;
    temp = (beanUnitStringConvertEncodingBlock) ? beanUnitStringConvertEncodingBlock(_jsonString) : _jsonString;
    NSData *data = [temp dataUsingEncoding:NSUTF8StringEncoding];
    [self setBeanWith:_bean andJSONData:data];
}



-(void)setBeanWith:(NSObject *)_bean andJSONData:(NSData *)_data
{
    NSError *err = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:&err];
    
    NSAssert(!err, @"JSONSerialization can not parse");
    
    if ([obj isKindOfClass:[NSArray class]]) {
        [self setBeanWith:_bean andArray:obj];
    }
    else if ([obj isKindOfClass:[NSDictionary class]])
    {
        [self setBeanWith:_bean andDictionary:obj];
    }
}


-(void)setBeanWith:(NSObject *)_bean andArray:(NSArray *)_array
{
    [_array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [self setBeanWith:_bean andDictionary:obj];
        }
        else if ([obj isKindOfClass:[NSArray class]])
        {
            [self setBeanWith:_bean andArray:obj];
        }
    }];
}


-(void)setBeanWith:(NSObject *)_bean andDictionary:(NSDictionary *)_dic
{
    [_dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        //if can not find model value and the obj is array then goto parse array
        if (![obj isKindOfClass:[NSArray class]]) {
            [self setBeanWith:_bean andValue:obj andKey:key];
        }
        else{
            [self setBeanWith:_bean andArray:obj];
        }
    }];
}


/////////////
-(id)setBeanWithClass:(Class)_class jsonString:(NSString *)_jsonString
{
    NSData *data = [_jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [self setBeanWithClass:_class jsonData:data];
}

-(id)setBeanWithClass:(Class)_class jsonData:(NSData *)_data
{
    NSError *error = nil;
    id temp = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:&error];
    
    if ([temp isKindOfClass:[NSArray class]]) {
        return [self setBeanWithClass:_class array:temp];
    }
    else{
        return [self setBeanWithObject:[_class new] fromDictionary:temp];
    }
}


-(NSArray *)setBeanWithClass:(Class)_class array:(NSArray *)_array
{
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:_array.count];
    [temp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [temp addObject:[self setBeanWithObject:[_class new] fromDictionary:obj]];
    }];
    return temp;
}


-(id)setBeanWithObject:(NSObject *)_object fromDictionary:(NSDictionary *)dic
{
    __block NSObject *temp;
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        //if can not find model value and the obj is array then goto parse array
        temp = [self setBeanWith:_object andValue:obj andKey:key];
    }];
    return temp;
}


-(kClassType)getClassTypeWithObject:(id)object
{
    if (!object || (NSNull *)object == [NSNull null]) {
        return kClassTypeNull;
    }
    else if ([object isKindOfClass:[NSString class]])
    {
        return kClassTypeString;
    }
    else if ([object isKindOfClass:[NSNumber class]])
    {
        return kClassTypeNumber;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        return kClassTypeArray;
    }
    else if ([object isKindOfClass:[NSDictionary class]])
    {
        return kClassTypeDictionary;
    }
    else if([object isMemberOfClass:[NSObject class]] && ![object isKindOfClass:[NSString class]] && ![object isKindOfClass:[NSNumber class]] && ![object isKindOfClass:[NSArray class]] && ![object isKindOfClass:[NSDictionary class]]){
        return kClassTypeObject;
    }
    else{
        return kClassTypeNone;
    }
}


-(id)setBeanWith:(NSObject *)_bean andValue:(NSObject *)_value andKey:(NSString *)_key
{
    SEL seletor;
    seletor = [self getSeletorWith:_key];
    
    
    //无此方法就不执行
    if (![_bean respondsToSelector:seletor]) {
        return nil;
    }
    
    //判断是否为空值，空值返回
//    if(!_value || (NSNull *)_value == [NSNull null])
//    {
//        return NO;
//    }
//    //判断是否为字符串
//    else if ([_value isKindOfClass:[NSString class]])
//    {
//        NSDate *date = (NSDate *)beanUnitDateConvertBlock(_value,_key);
//        if (date) {
//            [_bean setValue:date forKey:_key];
//            return YES;
//        }
//        _value = (beanUnitStringChangeBlock) ? beanUnitStringChangeBlock(_value,_key) : _value;
//        [_bean setValue:_value forKey:_key];
//    }
//    else
//    {
//        if ([_bean isKindOfClass:[NSNumber class]]) {
//            _bean = (beanUnitNumberConvertBlock) ? beanUnitNumberConvertBlock(_value,_key) : _bean;
//        }
//        [_bean setValue:_value forKey:_key];
//    }
    
    kClassType type = [self getClassTypeWithObject:_value];
    switch (type) {
        case kClassTypeNull:
            return NO;
            break;
        case kClassTypeString:
        {
            NSDate *date = (NSDate *)beanUnitDateConvertBlock(_value,_key);
            if (date) {
                [_bean setValue:date forKey:_key];
                return YES;
            }
            _value = (beanUnitStringChangeBlock) ? beanUnitStringChangeBlock(_value,_key) : _value;
                   [_bean setValue:_value forKey:_key];
        }
            break;
        case kClassTypeNumber:
        {
            if ([_bean isKindOfClass:[NSNumber class]]) {
                _bean = (beanUnitNumberConvertBlock) ? beanUnitNumberConvertBlock(_value,_key) : _bean;
            }
        }
        case kClassTypeDictionary:
        case kClassTypeArray:
            [_bean setValue:_value forKey:_key];
            break;
        case kClassTypeNone:
            return NO;
        default:
            break;
    }
    return _bean;
}

-(NSMutableDictionary *)convertToDictionaryFromBean:(NSObject *)_bean
{
    Class clazz = [_bean class];
    u_int count;

    
    //得到所有property的名,get the class's properties name
    objc_property_t* properties = class_copyPropertyList(clazz, &count);

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);

        NSString *proString = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        SEL seletor = [self getSeletorWith:proString];
        if ([_bean respondsToSelector:seletor]) {
            
            id temp = [_bean valueForKey:proString];
            
            [dic setObject:temp forKey:proString];

        }
    }
    free(properties);
    
    return dic;
}


-(NSData *)convertToJSONFromBean:(NSObject *)_bean
{
    NSDictionary *dic = [self convertToDictionaryFromBean:_bean];
    
    NSError *error = nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    
    NSAssert(!error, @"JSONSerialization can not write");
    
    return data;
}


-(void)setDateConvertBlock:(BeanUnitDateBlock)aDataConvertBlock
{
    beanUnitDateConvertBlock = nil;
    beanUnitDateConvertBlock = [aDataConvertBlock copy];
}

-(void)setStringConvertEncodingBlock:(BeanUnitStringBlock)aStringConvertBlock
{
    beanUnitStringConvertEncodingBlock = nil;
    beanUnitStringConvertEncodingBlock = [aStringConvertBlock copy];
}

-(void)setNumberConvertBlock:(BeanUnitNumberBlock)aNumberConvertBlock
{
    beanUnitNumberConvertBlock = nil;
    beanUnitNumberConvertBlock = [aNumberConvertBlock copy];
}


-(void)setStringChangeBlock:(BeanUnitStringChangeBlock)aStringChangeBlock
{
    beanUnitStringChangeBlock = nil;
    beanUnitStringChangeBlock = [aStringChangeBlock copy];
}


- (SEL)getSeletorWith:(NSString *)_key
{
    NSString *keyTemp = [_key copy];
    NSString *firstChar = [keyTemp substringWithRange:NSMakeRange(0, 1)];
    firstChar = [firstChar uppercaseString];
    keyTemp = [keyTemp stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstChar];
    
    NSAssert(![keyTemp isEqualToString:_key], @"first not uppercase");
    
    NSString *selectorString = [NSString stringWithFormat:@"set%@:",keyTemp];
    NSLog(@"%@",selectorString);
    
    SEL seletor = NSSelectorFromString(selectorString);
    return seletor;
}


-(void)dealloc
{
    beanUnitDateConvertBlock = nil;
    beanUnitStringConvertEncodingBlock = nil;
    beanUnitStringChangeBlock = nil;
    beanUnitNumberConvertBlock = nil;
}

@end
