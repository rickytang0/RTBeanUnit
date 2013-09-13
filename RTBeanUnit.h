//
//  RTBeanUnit.h
//  RTBeanUnitDemo
//
//  Created by 唐 嘉宾 on 13-5-8.
//  Copyright (c) 2013年 唐 嘉宾. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    kClassTypeNull,
    kClassTypeNumber,
    kClassTypeString,
    kClassTypeArray,
    kClassTypeDictionary,
    kClassTypeObject,
    kClassTypeNone,
}kClassType;

typedef id (^BeanUnitBlock)(id data);

typedef NSDate* (^BeanUnitDateBlock)(id data,id key);

typedef NSString* (^BeanUnitStringBlock)(id data);

typedef NSString* (^BeanUnitStringChangeBlock)(id data,id key);

typedef NSNumber* (^BeanUnitNumberBlock)(id data,id key);

@interface RTBeanUnit : NSObject
{
    BeanUnitDateBlock beanUnitDateConvertBlock;
    
    BeanUnitStringBlock beanUnitStringConvertEncodingBlock;
    
    BeanUnitStringChangeBlock beanUnitStringChangeBlock;
    
    BeanUnitNumberBlock beanUnitNumberConvertBlock;
}

//Converter
-(void)setDateConvertBlock:(BeanUnitDateBlock)aDataConvertBlock;

-(void)setStringConvertEncodingBlock:(BeanUnitStringBlock)aStringConvertBlock;

-(void)setStringChangeBlock:(BeanUnitStringChangeBlock)aStringChangeBlock;

-(void)setNumberConvertBlock:(BeanUnitNumberBlock)aNumberConvertBlock;
/////////////////////

-(SEL)getSeletorWith:(NSString *)_key;

/*
 set the bean from every object
 */

-(void)setBeanWith:(NSObject *)_bean andJSONString:(NSString *)_jsonString;

-(void)setBeanWith:(NSObject *)_bean andJSONData:(NSData *)_data;

//
-(void)setBeanWith:(NSObject *)_bean andDictionary:(NSDictionary *)_dic;

-(void)setBeanWith:(NSObject *)_bean andArray:(NSArray *)_array;

//////////
-(id)setBeanWithClass:(Class)_class jsonString:(NSString *)_jsonString;

-(id)setBeanWithClass:(Class)_class jsonData:(NSData *)_data;

-(NSArray *)setBeanWithClass:(Class)_class array:(NSArray *)_array;

-(id)setBeanWithObject:(NSObject *)_object fromDictionary:(NSDictionary *)dic;

//
-(id)setBeanWith:(NSObject *)_bean andValue:(NSObject *)_value andKey:(NSString *)_key;



/*
 set the bean to every object
 */
-(NSMutableDictionary *)convertToDictionaryFromBean:(NSObject *)_bean;

-(NSData *)convertToJSONFromBean:(NSObject *)_bean;

/*
 reflesh
 */

@end
