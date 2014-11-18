//
//  DTMemoryStorage.m
//  DTModelStorage
//
//  Created by Denys Telezhkin on 15.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DTMemoryStorage.h"
#import "DTSection.h"
#import "DTStorageUpdate.h"
#import "DTSectionModel.h"
#import "DTRuntimeHelper.h"

@interface DTMemoryStorage ()

@property (nonatomic, strong) NSOperationQueue* updateQueues;

@property (nonatomic, strong) DTStorageUpdate * currentUpdate;
@property (nonatomic, retain) NSMutableDictionary * searchingBlocks;
@property (nonatomic, assign) BOOL isBatchUpdateCreating;

@end

@implementation DTMemoryStorage

+ (instancetype)storage
{
    DTMemoryStorage * storage = [self new];
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
    id <DTSection> sectionModel = nil;
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

#pragma mark - Holy shit


- (void)setItems:(NSArray *)items forSectionIndex:(NSUInteger)sectionIndex
{
    DTSectionModel * section = [self sectionAtIndex:sectionIndex];
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
        self.currentUpdate = [DTStorageUpdate new];
    }
}

- (void)finishUpdate
{
    if (!self.isBatchUpdateCreating)
    {
        if ([self.delegate respondsToSelector:@selector(storageDidPerformUpdate:)])
        {
            DTStorageUpdate* update = self.currentUpdate; //for hanling nilling
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
    [self startUpdate];
    
    DTSectionModel * section = [self createSectionIfNotExist:sectionNumber];
    NSUInteger numberOfItems = [section numberOfObjects];
    [section.objects addObject:item];
    [self.currentUpdate.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:numberOfItems
                                                                           inSection:sectionNumber]];
    
    [self finishUpdate];
}

- (void)addItems:(NSArray *)items
{
    [self addItems:items toSection:0];
}

- (void)addItems:(NSArray *)items toSection:(NSUInteger)sectionNumber
{
    [self startUpdate];
    
    DTSectionModel * section = [self createSectionIfNotExist:sectionNumber];
    
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
    DTSectionModel * section = [self createSectionIfNotExist:indexPath.section];
    
    if ([section.objects count] < indexPath.row)
    {
        ANLog(@"DTMemoryStorage: failed to insert item for section: %ld, row: %ld, only %lu items in section",
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
    DTSectionModel * fromSection = [self sections][fromIndexPath.section];
    DTSectionModel * toSection = [self sections][toIndexPath.section];
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
        DTSectionModel * section = [self createSectionIfNotExist:originalIndexPath.section];
        
        [section.objects replaceObjectAtIndex:originalIndexPath.row
                                   withObject:replacingItem];
    }
    else
    {
        ANLog(@"DTMemoryStorage: failed to replace item %@ at indexPath: %@", replacingItem, originalIndexPath);
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
        DTSectionModel * section = [self createSectionIfNotExist:indexPath.section];
        [section.objects removeObjectAtIndex:indexPath.row];
    }
    else
    {
        ANLog(@"DTMemoryStorage: item to delete: %@ was not found", item);
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
            DTSectionModel * section = [self createSectionIfNotExist:indexPath.section];
            [section.objects removeObjectAtIndex:indexPath.row];
            [self.currentUpdate.deletedRowIndexPaths addObject:indexPath];
        }
        else
        {
            ANLog(@"DTMemoryStorage: item to delete was not found at indexPath : %@ ", indexPath);
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
            DTSectionModel* section = self.sections[indexPath.section];
            [section.objects removeObjectAtIndex:indexPath.row];
        }
    }];
    
    [self.currentUpdate.deletedRowIndexPaths addObjectsFromArray:indexPaths];
    [self finishUpdate];
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
        DTSectionModel * section = self.sections[sectionNumber];
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
            ANLog(@"DTMemoryStorage: Row not found while searching for item");
        }
    }
    else
    {
        ANLog(@"DTMemoryStorage: Section not found while searching for item");
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

- (DTSectionModel *)sectionAtIndex:(NSUInteger)sectionNumber
{
    [self startUpdate];
    DTSectionModel * section = [self createSectionIfNotExist:sectionNumber];
    [self finishUpdate];
    
    return section;
}

#pragma mark - private

- (DTSectionModel *)createSectionIfNotExist:(NSUInteger)sectionNumber
{
    if (sectionNumber < self.sections.count)
    {
        return self.sections[sectionNumber];
    }
    else
    {
        for (int sectionIterator = self.sections.count; sectionIterator <= sectionNumber; sectionIterator++)
        {
            DTSectionModel * section = [DTSectionModel new];
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
            ANLog(@"DTMemoryStorage: object %@ not found", [items objectAtIndex:i]);
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
    DTSectionModel * sectionModel = nil;
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
    
    DTSectionModel * section = [self sectionAtIndex:sectionNumber];
    
    [section setSupplementaryModel:headerModel forKind:self.supplementaryHeaderKind];
}

-(void)setSectionFooterModel:(id)footerModel forSectionIndex:(NSUInteger)sectionNumber
{
    NSAssert(self.supplementaryFooterKind, @"supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method");
    
    DTSectionModel * section = [self sectionAtIndex:sectionNumber];
    
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
        for (DTSectionModel * section in self.sections)
        {
            [section setSupplementaryModel:nil forKind:kind];
        }
        return;
    }
    [self createSectionIfNotExist:([supplementaryModels count] - 1)];
    
    for (NSUInteger sectionNumber = 0; sectionNumber < [supplementaryModels count]; sectionNumber++)
    {
        DTSectionModel * section = self.sections[sectionNumber];
        [section setSupplementaryModel:supplementaryModels[sectionNumber] forKind:kind];
    }
    [self finishUpdate];
}


#pragma mark - search

- (void)setSearchingBlock:(DTModelSearchingBlock)searchingBlock
            forModelClass:(Class)modelClass
{
    NSParameterAssert(searchingBlock);
    NSParameterAssert(modelClass);
    
    self.searchingBlocks[[DTRuntimeHelper modelStringForClass:modelClass]] = searchingBlock;
}

- (instancetype)searchingStorageForSearchString:(NSString *)searchString
                                  inSearchScope:(NSUInteger)searchScope
{
    DTMemoryStorage * storage = [[self class] storage
                                 ];
    
    for (NSUInteger sectionNumber = 0; sectionNumber < [self.sections count]; sectionNumber++)
    {
        DTSectionModel * searchSection = [self filterSection:self.sections[sectionNumber]
                                            withSearchString:searchString
                                                 searchScope:searchScope];
        if (searchSection)
        {
            [storage.sections addObject:searchSection];
        }
    }
    storage.supplementaryHeaderKind = self.supplementaryHeaderKind;
    storage.supplementaryFooterKind = self.supplementaryFooterKind;
    
    return storage;
}

- (DTSectionModel *)filterSection:(DTSectionModel *)section
                 withSearchString:(NSString *)searchString
                      searchScope:(NSInteger)searchScope
{
    NSMutableArray * searchResults = [NSMutableArray array];
    for (NSUInteger row = 0; row < section.objects.count; row++)
    {
        NSObject * item = section.objects[row];
        
        if (self.searchingBlocks[[DTRuntimeHelper modelStringForClass:item.class]])
        {
            DTModelSearchingBlock block = self.searchingBlocks[[DTRuntimeHelper modelStringForClass:item.class]];
            
            if (block && block(item, searchString, searchScope, section))
            {
                [searchResults addObject:item];
            }
        }
    }
    if ([searchResults count])
    {
        DTSectionModel * searchSection = [section copy];
        searchSection.objects = searchResults;
        return searchSection;
    }
    return nil;
}



@end
