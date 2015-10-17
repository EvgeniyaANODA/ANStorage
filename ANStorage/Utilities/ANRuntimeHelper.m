//
//  ANRuntimeHelper.m
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANRuntimeHelper.h"

@implementation ANRuntimeHelper

+ (NSString *)classStringForClass:(Class)class
{
    NSString * classString = NSStringFromClass(class);
    if ([classString rangeOfString:@"."].location != NSNotFound)
    {
        // Swift class, format <ModuleName>.<ClassName>
        classString = [[classString componentsSeparatedByString:@"."] lastObject];
    }
    return classString;
}

+ (NSString *)modelStringForClass:(Class)class
{
    NSString * classString = [self classStringForClass:class];
    if ([class isSubclassOfClass:[NSString class]])
    {
        return @"NSString";
    }
    
    if ([classString isEqualToString:@"__NSCFNumber"] ||
        [classString isEqualToString:@"__NSCFBoolean"])
    {
        return @"NSNumber";
    }
    
    if ([classString isEqualToString:@"__NSDictionaryI"] ||
        [classString isEqualToString:@"__NSDictionaryM"] ||
       ([classString rangeOfString:@"_NativeDictionaryStorageOwner"].location != NSNotFound) ||
        [class isSubclassOfClass:[NSDictionary class]])
    {
        return @"NSDictionary";
    }
    
    if ([classString isEqualToString:@"__NSArrayI"] ||
        [classString isEqualToString:@"__NSArrayM"] ||
        ([classString rangeOfString:@"_ContiguousArrayStorage"].location != NSNotFound) ||
        [class isSubclassOfClass:[NSArray class]])
    {
        return @"NSArray";
    }
    
    if ([classString isEqualToString:@"__NSDate"] ||
        [classString isEqualToString:@"__NSTaggedDate"] ||
        [class isSubclassOfClass:[NSDate class]])
    {
        return @"NSDate";
    }
    return classString;
}

@end
