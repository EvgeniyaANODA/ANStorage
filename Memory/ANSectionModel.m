//
//  ANSectionModel.m
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANSectionModel.h"

@interface ANSectionModel ()

@property (nonatomic, strong) NSMutableDictionary * supplementaries;

@end

@implementation ANSectionModel

- (NSMutableArray *)objects
{
    if (!_objects)
    {
        _objects = [NSMutableArray array];
    }
    return _objects;
}

- (NSMutableDictionary *)supplementaries
{
    if (!_supplementaries)
    {
        _supplementaries = [NSMutableDictionary dictionary];
    }
    return _supplementaries;
}

- (NSUInteger)numberOfObjects
{
    return [self.objects count];
}

- (void)setSupplementaryModel:(id)model forKind:(NSString *)kind
{
    if (!model)
    {
        [self.supplementaries removeObjectForKey:kind];
        return;
    }
    self.supplementaries[kind] = model;
}

- (id)supplementaryModelOfKind:(NSString *)kind
{
    return self.supplementaries[kind];
}

- (instancetype)copy
{
    ANSectionModel * model = [[self class] new];
    model.objects = self.objects;
    model.supplementaries = self.supplementaries;
    return model;
}

@end
