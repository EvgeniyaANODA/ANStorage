//
//  ANCoreDataStorage.m
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#ifdef AN_TABLE_LOG
#    define ANLog(...) NSLog(__VA_ARGS__)
#else
#    define ANLog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)

#import "ANMemoryStorage.h"
#import "ANSectionInterface.h"
#import "ANStorageUpdate.h"
#import "ANSectionModel.h"
#import "ANRuntimeHelper.h"

@interface ANMemoryStorage ()

@property (nonatomic, strong) ANStorageUpdate * currentUpdate;
@property (nonatomic, retain) NSMutableDictionary * searchingBlocks;
@property (nonatomic, assign) BOOL isBatchUpdateCreating;

@end

@implementation ANMemoryStorage

+ (instancetype)storage
{
    ANMemoryStorage * storage = [self new];
    storage.sections = [NSMutableArray array];
    
    return storage;
}

- (NSMutableDictionary *)searchingBlocks
{
    if (!_searchingBlocks)
    {
        _searchingBlocks = [NSMutableDictionary dictionary];
    }
    return _searchingBlocks;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    id <ANSectionInterface> sectionModel = nil;
    if (indexPath.section >= self.sections.count)
    {
        return nil;
    }
    else
    {
        sectionModel = [self sections][indexPath.section];
        if (indexPath.item >= [sectionModel numberOfObjects])
        {
            return nil;
        }
    }
    
    return [sectionModel.objects objectAtIndex:indexPath.row];
}


- (void)batchUpdateWithBlock:(ANCodeBlock)block
{
    [self startUpdate];
    self.isBatchUpdateCreating = YES;
    if (block)
    {
        block();
    }
    self.isBatchUpdateCreating = NO;
    [self finishUpdate];
}

- (BOOL)hasItems
{
    //TODO: handle exeptions
    //    NSNumber* count = [self.sections valueForKeyPath:@"objects.@count.numberOfObjects"];// TODO:
    __block NSInteger totalCount = 0;
    [self.sections enumerateObjectsUsingBlock:^(ANSectionModel* obj, NSUInteger idx, BOOL *stop) {
        totalCount += obj.numberOfObjects;
    }];
    return [@(totalCount) boolValue];
}

#pragma mark - Holy shit


- (void)setItems:(NSArray *)items forSectionIndex:(NSUInteger)sectionIndex
{
    ANSectionModel * section = [self sectionAtIndex:sectionIndex];
    [section.objects removeAllObjects];
    [section.objects addObjectsFromArray:items];
    self.currentUpdate = nil; // no update if storage reloading
    [self.delegate storageNeedsReload];
}


#pragma mark - Updates

- (void)startUpdate
{
    if (!self.isBatchUpdateCreating)
    {
        self.currentUpdate = [ANStorageUpdate new];
    }
}

- (void)finishUpdate
{
    if (!self.isBatchUpdateCreating)
    {
        if ([self.delegate respondsToSelector:@selector(storageDidPerformUpdate:)])
        {
            ANStorageUpdate* update = self.currentUpdate; //for hanling nilling
            [self.delegate storageDidPerformUpdate:update];
        }
        self.currentUpdate = nil;
    }
}

#pragma mark - Adding items

- (void)addItem:(id)item
{
    [self addItem:item toSection:0];
}

- (void)addItem:(id)item toSection:(NSUInteger)sectionNumber
{
    if (item)
    {
        [self startUpdate];
        
        ANSectionModel * section = [self createSectionIfNotExist:sectionNumber];
        NSUInteger numberOfItems = [section numberOfObjects];
        [section.objects addObject:item];
        [self.currentUpdate.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:numberOfItems
                                                                               inSection:sectionNumber]];
        
        [self finishUpdate];
    }
}

- (void)addItems:(NSArray *)items
{
    [self addItems:items toSection:0];
}

- (void)addItems:(NSArray *)items toSection:(NSUInteger)sectionNumber
{
    [self startUpdate];
    
    ANSectionModel * section = [self createSectionIfNotExist:sectionNumber];
    
    for (id item in items)
    {
        NSUInteger numberOfItems = [section numberOfObjects];
        [section.objects addObject:item];
        [self.currentUpdate.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:numberOfItems
                                                                               inSection:sectionNumber]];
    }
    
    [self finishUpdate];
}

- (void)addItem:(id)item atIndexPath:(NSIndexPath *)indexPath
{
    [self startUpdate];
    // Update datasource
    ANSectionModel * section = [self createSectionIfNotExist:indexPath.section];
    
    if ([section.objects count] < indexPath.row)
    {
        ANLog(@"ANMemoryStorage: failed to insert item for section: %ld, row: %ld, only %lu items in section",
              (long)indexPath.section,
              (long)indexPath.row,
              (unsigned long)[section.objects count]);
        return;
    }
    [section.objects insertObject:item atIndex:indexPath.row];
    
    [self.currentUpdate.insertedRowIndexPaths addObject:indexPath];
    
    [self finishUpdate];
}

- (void)reloadItem:(id)item
{
    [self startUpdate];
    
    NSIndexPath * indexPathToReload = [self indexPathForItem:item];
    
    if (indexPathToReload)
    {
        [self.currentUpdate.updatedRowIndexPaths addObject:indexPathToReload];
    }
    
    [self finishUpdate];
}

- (void)moveItemFromIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath
{
    //TODO: add safely
    ANSectionModel * fromSection = [self sections][fromIndexPath.section];
    ANSectionModel * toSection = [self sections][toIndexPath.section];
    id tableItem = fromSection.objects[fromIndexPath.row];
    
    [fromSection.objects removeObjectAtIndex:fromIndexPath.row];
    [toSection.objects insertObject:tableItem atIndex:toIndexPath.row];
}

- (void)replaceItem:(id)itemToReplace withItem:(id)replacingItem
{
    [self startUpdate];
    
    NSIndexPath * originalIndexPath = [self indexPathForItem:itemToReplace];
    if (originalIndexPath && replacingItem)
    {
        ANSectionModel * section = [self createSectionIfNotExist:originalIndexPath.section];
        
        [section.objects replaceObjectAtIndex:originalIndexPath.row
                                   withObject:replacingItem];
    }
    else
    {
        ANLog(@"ANMemoryStorage: failed to replace item %@ at indexPath: %@", replacingItem, originalIndexPath);
        return;
    }
    [self.currentUpdate.updatedRowIndexPaths addObject:originalIndexPath];
    
    [self finishUpdate];
}

#pragma mark - Removing items

- (void)removeItem:(id)item
{
    [self startUpdate];
    
    NSIndexPath * indexPath = [self indexPathForItem:item];
    
    if (indexPath)
    {
        ANSectionModel * section = [self createSectionIfNotExist:indexPath.section];
        [section.objects removeObjectAtIndex:indexPath.row];
    }
    else
    {
        ANLog(@"ANMemoryStorage: item to delete: %@ was not found", item);
        return;
    }
    [self.currentUpdate.deletedRowIndexPaths addObject:indexPath];
    [self finishUpdate];
}

- (void)removeItemsAtIndexPaths:(NSArray *)indexPaths
{
    [self startUpdate];
    for (NSIndexPath * indexPath in indexPaths)
    {
        id object = [self objectAtIndexPath:indexPath];
        
        if (object)
        {
            ANSectionModel * section = [self createSectionIfNotExist:indexPath.section];
            [section.objects removeObjectAtIndex:indexPath.row];
            [self.currentUpdate.deletedRowIndexPaths addObject:indexPath];
        }
        else
        {
            ANLog(@"ANMemoryStorage: item to delete was not found at indexPath : %@ ", indexPath);
        }
    }
    [self finishUpdate];
}

- (void)removeItems:(NSArray *)items
{
    [self startUpdate];
    
    NSMutableArray* indexPaths = [NSMutableArray array]; // TODO: set mb?
    
    [items enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
       
        NSIndexPath* indexPath = [self indexPathForItem:item];
        
        if (indexPath)
        {
            ANSectionModel* section = self.sections[indexPath.section];
            [section.objects removeObjectAtIndex:indexPath.row];
        }
    }];
    
    [self.currentUpdate.deletedRowIndexPaths addObjectsFromArray:indexPaths];
    [self finishUpdate];
}

- (void)removeAllItems
{
    [self.sections removeAllObjects];
    [self.delegate storageNeedsReload];
}

#pragma  mark - Sections

- (void)deleteSections:(NSIndexSet *)indexSet
{
    // add safety
    [self startUpdate];
    
    ANLog(@"Deleting Sections... \n%@", indexSet);
    [self.sections removeObjectsAtIndexes:indexSet];
    [self.currentUpdate.deletedSectionIndexes addIndexes:indexSet];
    
    [self finishUpdate];
}

#pragma mark - Search

- (NSArray *)itemsInSection:(NSUInteger)sectionNumber
{
    NSArray* objects;
    if ([self.sections count] > sectionNumber)
    {
        ANSectionModel * section = self.sections[sectionNumber];
        objects = [section objects];
    }
    return objects;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    id object = nil;
    if (indexPath.section < [self.sections count])
    {
        NSArray* section = [self itemsInSection:indexPath.section];
        if (indexPath.row < [section count])
        {
            object = [section objectAtIndex:indexPath.row];
        }
        else
        {
            ANLog(@"ANMemoryStorage: Row not found while searching for item");
        }
    }
    else
    {
        ANLog(@"ANMemoryStorage: Section not found while searching for item");
    }
    return object;
}

- (NSIndexPath *)indexPathForItem:(id)item
{
    __block NSIndexPath* foundedIndexPath = nil;
    
    [self.sections enumerateObjectsUsingBlock:^(id obj, NSUInteger sectionIndex, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(objects)])
        {
            NSArray * rows = [obj objects];
            NSUInteger index = [rows indexOfObject:item];
            if (index != NSNotFound)
            {
                foundedIndexPath = [NSIndexPath indexPathForRow:index inSection:sectionIndex];
                *stop = YES;
            }
        }
    }];

    return foundedIndexPath;
}

- (ANSectionModel *)sectionAtIndex:(NSUInteger)sectionNumber
{
    [self startUpdate];
    ANSectionModel * section = [self createSectionIfNotExist:sectionNumber];
    [self finishUpdate];
    
    return section;
}

#pragma mark - private

- (ANSectionModel *)createSectionIfNotExist:(NSUInteger)sectionNumber
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
            ANLog(@"Section %d not exist, creating...", sectionIterator);
            [self.currentUpdate.insertedSectionIndexes addIndex:sectionIterator];
        }
        return [self.sections lastObject];
    }
}

//This implementation is not optimized, and may behave poorly with lot of sections
- (NSArray *)indexPathArrayForItems:(NSArray *)items
{
    NSMutableArray * indexPaths = [[NSMutableArray alloc] initWithCapacity:[items count]];
    
    for (NSInteger i = 0; i < [items count]; i++)
    {
        NSIndexPath * foundIndexPath = [self indexPathForItem:[items objectAtIndex:i]];
        if (!foundIndexPath)
        {
            ANLog(@"ANMemoryStorage: object %@ not found", [items objectAtIndex:i]);
        }
        else
        {
            [indexPaths addObject:foundIndexPath];
        }
    }
    return indexPaths;
}



#pragma mark - Views

-(void)setSectionHeaderModels:(NSArray *)headerModels
{
    NSAssert(self.supplementaryHeaderKind, @"Please set supplementaryHeaderKind property before setting section header models");
    
    [self setSupplementaries:headerModels forKind:self.supplementaryHeaderKind];
}

- (void)setSectionFooterModels:(NSArray *)footerModels
{
    NSAssert(self.supplementaryFooterKind, @"Please set supplementaryFooterKind property before setting section header models");
    
    [self setSupplementaries:footerModels forKind:self.supplementaryFooterKind];
}

- (id)supplementaryModelOfKind:(NSString *)kind forSectionIndex:(NSUInteger)sectionNumber
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

-(void)setSectionHeaderModel:(id)headerModel forSectionIndex:(NSUInteger)sectionNumber
{
    NSAssert(self.supplementaryHeaderKind, @"supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method");
    
    ANSectionModel * section = [self sectionAtIndex:sectionNumber];
    
    [section setSupplementaryModel:headerModel forKind:self.supplementaryHeaderKind];
}

-(void)setSectionFooterModel:(id)footerModel forSectionIndex:(NSUInteger)sectionNumber
{
    NSAssert(self.supplementaryFooterKind, @"supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method");
    
    ANSectionModel * section = [self sectionAtIndex:sectionNumber];
    
    [section setSupplementaryModel:footerModel forKind:self.supplementaryFooterKind];
}

-(id)headerModelForSectionIndex:(NSInteger)index
{
    NSAssert(self.supplementaryHeaderKind, @"supplementaryHeaderKind property was not set before calling headerModelForSectionIndex: method");
    
    return [self supplementaryModelOfKind:self.supplementaryHeaderKind
                          forSectionIndex:index];
}

-(id)footerModelForSectionIndex:(NSInteger)index
{
    NSAssert(self.supplementaryFooterKind, @"supplementaryFooterKind property was not set before calling footerModelForSectionIndex: method");
    
    return [self supplementaryModelOfKind:self.supplementaryFooterKind
                          forSectionIndex:index];
}

- (void)setSupplementaries:(NSArray *)supplementaryModels forKind:(NSString *)kind
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
    [self createSectionIfNotExist:([supplementaryModels count] - 1)];
    
    for (NSUInteger sectionNumber = 0; sectionNumber < [supplementaryModels count]; sectionNumber++)
    {
        ANSectionModel * section = self.sections[sectionNumber];
        [section setSupplementaryModel:supplementaryModels[sectionNumber] forKind:kind];
    }
    [self finishUpdate];
}


- (instancetype)searchingStorageForSearchString:(NSString *)searchString
                                  inSearchScope:(NSUInteger)searchScope
{
    ANMemoryStorage * storage = [[self class] storage];
    
    NSPredicate* predicate;
    if (self.storagePredicateBlock)
    {
        predicate = self.storagePredicateBlock(searchString, searchScope);
    }
    
    if (predicate)
    {
        [self.sections enumerateObjectsUsingBlock:^(ANSectionModel* obj, NSUInteger idx, BOOL *stop) {
            
            NSArray* filteredObjects = [obj.objects filteredArrayUsingPredicate:predicate];
            [storage addItems:filteredObjects toSection:idx];
        }];
    }
    else
    {
        ANLog(@"No predicate was created, so no searching. Check your setter for storagePredicateBlock");
    }
    return storage;
}

@end
