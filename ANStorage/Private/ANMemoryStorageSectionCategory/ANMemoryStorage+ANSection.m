//
//  ANMemoryStorage+ANSection.m
//  Pods
//
//  Created by Dmitriy Frolow on 15/07/15.
//
//

#import "ANMemoryStorage+ANSection.h"

@implementation ANMemoryStorage (ANSection)

#pragma mark - Sections

- (void)_removeSections:(NSIndexSet*)indexSet
{
    if (indexSet && [self isIndexSetInSectionBounds:indexSet])
    {
        [self startUpdate];
        
        [self.sections removeObjectsAtIndexes:indexSet];
        [[self loadCurrentUpdate].deletedSectionIndexes addIndexes:indexSet];
        
        [self finishUpdate];
    }
}

- (ANSectionModel*)_sectionAtIndex:(NSUInteger)sectionIndex
{
    return [self _sectionAtIndex:sectionIndex createIfNotExist:NO];
}

- (ANSectionModel*)_sectionAtIndex:(NSUInteger)sectionIndex createIfNeeded:(BOOL)shouldCreate
{
     return [self _sectionAtIndex:sectionIndex createIfNotExist:shouldCreate];
}

#pragma mark - Views Models

- (void)_setSupplementaries:(NSArray *)supplementaryModels forKind:(NSString *)kind
{
    [self startUpdate];
    if (!supplementaryModels || [supplementaryModels count] == 0)
    {
        for (ANSectionModel * section in self.sections)
        {
            [section setSupplementaryModel:nil forKind:kind];
        }
        return;
    }
    [self _createSectionIfNotExist:([supplementaryModels count] - 1)];
    
    for (NSUInteger sectionNumber = 0; sectionNumber < [supplementaryModels count]; sectionNumber++)
    {
        ANSectionModel * section = self.sections[sectionNumber];
        [section setSupplementaryModel:supplementaryModels[sectionNumber] forKind:kind];
    }
    [self finishUpdate];
}

/**
 Set header models for sections. `ANSectionModel` objects are created automatically, if they don't exist already. Pass nil or empty array to this method to clear all section header models.
 
 @param headerModels Section header models to use.
 */
- (void)_setSectionHeaderModels:(NSArray *)headerModels
{
    NSAssert(self.supplementaryHeaderKind, @"Please set supplementaryHeaderKind property before setting section header models");
    [self _setSupplementaries:headerModels forKind:self.supplementaryHeaderKind];
}

- (void)_setSectionFooterModels:(NSArray *)footerModels
{
    NSAssert(self.supplementaryFooterKind, @"Please set supplementaryFooterKind property before setting section header models");
    [self _setSupplementaries:footerModels forKind:self.supplementaryFooterKind];
}

- (void)_setSectionHeaderModel:(id)headerModel forSectionIndex:(NSUInteger)sectionIndex
{
    NSAssert(self.supplementaryHeaderKind, @"supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method");
    
    ANSectionModel *section = [self _sectionAtIndex:sectionIndex createIfNotExist:YES];
    [section setSupplementaryModel:headerModel forKind:self.supplementaryHeaderKind];
}

- (void)_setSectionFooterModel:(id)footerModel forSectionIndex:(NSUInteger)sectionIndex
{
    NSAssert(self.supplementaryFooterKind, @"supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method");
    ANSectionModel * section = [self _sectionAtIndex:sectionIndex createIfNotExist:YES];
    [section setSupplementaryModel:footerModel forKind:self.supplementaryFooterKind];
}

- (ANSectionModel *)_createSectionIfNotExist:(NSUInteger)sectionNumber
{
    if (sectionNumber < self.sections.count)
    {
        return self.sections[sectionNumber];
    }
    else
    {
        for (NSInteger sectionIterator = self.sections.count; sectionIterator <= sectionNumber; sectionIterator++)
        {
            ANSectionModel * section = [ANSectionModel new];
            [self.sections addObject:section];
            [[self loadCurrentUpdate].insertedSectionIndexes addIndex:sectionIterator];
        }
        return [self.sections lastObject];
    }
}

#pragma mark views part

- (id)_supplementaryModelOfKind:(NSString *)kind forSectionIndex:(NSUInteger)sectionNumber
{
    ANSectionModel * sectionModel = nil;
    if (sectionNumber >= self.sections.count)
    {
        return nil;
    }
    else
    {
        sectionModel = [self sections][sectionNumber];
    }
    return [sectionModel supplementaryModelOfKind:kind];
}

#pragma mark Helpers methods

- (ANSectionModel*)_sectionAtIndex:(NSUInteger)sectionNumber createIfNotExist:(BOOL)createIfNotExist
{
    //TODO: HOTFIX:
    ANSectionModel* section;
    if (createIfNotExist)
    {
        [self startUpdate];
        section = [self _createSectionIfNotExist:sectionNumber];
        [self finishUpdate];
    }
    else
    {
        if (sectionNumber < self.sections.count)
        {
            return self.sections[sectionNumber];
        }
    }
    return section;
}

- (BOOL)isIndexSetInSectionBounds:(NSIndexSet *)indexSet
{
    __block BOOL isInRange = YES;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        if (index >=self.sections.count)
        {
            isInRange = NO;
            *stop = YES;
        }
    }];
    return isInRange;
}

@end
