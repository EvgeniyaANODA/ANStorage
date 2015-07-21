//
//  ANCoreDataStorage.m
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANMemoryStorage.h"
#import "ANSectionInterface.h"
#import "ANStorageUpdate.h"
#import "ANRuntimeHelper.h"
#import "ANMemoryStorage+ANItems.h"
#import "ANMemoryStorage+ANSection.h"

@interface ANMemoryStorage ()

@property (nonatomic, strong) ANStorageUpdate* currentUpdate;
@property (nonatomic, retain) NSMutableDictionary* searchingBlocks;
@property (nonatomic, assign) BOOL isBatchUpdateCreating;

@end

@implementation ANMemoryStorage

+ (instancetype)storage
{
    ANMemoryStorage * storage = [self new];
    return storage;
}

- (NSMutableArray *)sections
{
    if (!_sections)
    {
        _sections = [NSMutableArray array];
    }
    return _sections;
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

#pragma mark Clear Storage

- (void)clearStorageUpdate
{
    self.currentUpdate = nil;
//    NSAssert(!self.isBatchUpdateCreating, @"You are wrong with data added in the same update model, be careful with this!!!");
}

- (void)setItems:(NSArray *)items forSectionIndex:(NSUInteger)sectionIndex
{
    ANSectionModel * section = [self _sectionAtIndex:sectionIndex createIfNotExist:YES];;
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
    [self _addItem:item toSection:0];
}

- (void)addItem:(id)item toSection:(NSUInteger)sectionNumber
{
    [self _addItem:item toSection:sectionNumber];
}

- (void)addItems:(NSArray *)items
{
    [self _addItems:items toSection:0];
}

- (void)addItems:(NSArray *)items toSection:(NSUInteger)sectionNumber
{
    [self _addItems:items toSection:sectionNumber];
}

- (void)addItem:(id)item atIndexPath:(NSIndexPath *)indexPath
{
    [self _addItem:item atIndexPath:indexPath];
}

- (void)reloadItem:(id)item
{
    [self _reloadItem:item];
}

- (void)moveItemFromIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath
{
    [self _moveItemFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

- (void)replaceItem:(id)itemToReplace withItem:(id)replacingItem
{
    [self _replaceItem:itemToReplace withItem:replacingItem];
}

#pragma mark - Removing items

- (void)removeItem:(id)item
{
    [self _removeItem:item];
}

- (void)removeItemsAtIndexPaths:(NSArray *)indexPaths
{
    [self _removeItemsAtIndexPaths:indexPaths];
}

- (void)removeItems:(NSArray *)items
{
    [self _removeItems:items];
}

- (void)removeAllItems
{
    [self _removeAllItems];
}

- (NSArray *)indexPathArrayForItems:(NSArray *)items
{
    return [self _indexPathArrayForItems:items];
}

#pragma  mark - Sections

- (void)removeSections:(NSIndexSet *)indexSet
{
    [self _removeSections:indexSet];
}

#pragma mark - Search

- (NSArray *)itemsInSection:(NSUInteger)sectionNumber
{
    return [self _itemsInSection:sectionNumber];
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self _itemAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForItem:(id)item
{
    return [self _indexPathForItem:item];
}

- (ANSectionModel*)sectionAtIndex:(NSUInteger)sectionIndex
{
    return [self _sectionAtIndex:sectionIndex createIfNotExist:NO];
}

- (ANSectionModel *)sectionAtIndex:(NSUInteger)sectionIndex createIfNeeded:(BOOL)shouldCreate
{
//    return [self _sectionAtIndex:sectionIndex createIfNeeded:shouldCreate];
    return [self _sectionAtIndex:sectionIndex createIfNotExist:shouldCreate];
}

#pragma mark - Views

-(void)setSectionHeaderModels:(NSArray *)headerModels
{
    [self _setSectionHeaderModels:headerModels];
}

- (void)setSectionFooterModels:(NSArray *)footerModels
{
    [self _setSectionFooterModels:footerModels];
}

- (id)supplementaryModelOfKind:(NSString *)kind forSectionIndex:(NSUInteger)sectionNumber
{
    return [self _supplementaryModelOfKind:kind forSectionIndex:sectionNumber];
}

-(void)setSectionHeaderModel:(id)headerModel forSectionIndex:(NSUInteger)sectionNumber
{
    [self _setSectionHeaderModel:headerModel forSectionIndex:sectionNumber];
}

-(void)setSectionFooterModel:(id)footerModel forSectionIndex:(NSUInteger)sectionNumber
{
    [self _setSectionFooterModel:footerModel forSectionIndex:sectionNumber];
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
    [self _setSupplementaries:supplementaryModels forKind:kind];
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
        NSLog(@"No predicate was created, so no searching. Check your setter for storagePredicateBlock");
    }
    return storage;
}

- (ANStorageUpdate *)loadCurrentUpdate
{
    return self.currentUpdate;
}

- (BOOL)isButchModelCreating
{
    return self.isBatchUpdateCreating;
}

- (void)createCurrentUpdate {
    self.currentUpdate = [ANStorageUpdate new];
}

@end
