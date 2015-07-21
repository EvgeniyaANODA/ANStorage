//
//  ANMemoryStorage+ANItems.m
//  Pods
//
//  Created by Dmitriy Frolow on 15/07/15.
//
//

#import "ANMemoryStorage+ANItems.h"

@implementation ANMemoryStorage (ANItems)

#pragma mark Add Items

- (void)_addItem:(id)item
{
    [self addItem:item toSection:0];
}

- (void)_addItems:(NSArray *)items
{
    [self addItems:items toSection:0];
}

- (void)_addItem:(id)item toSection:(NSUInteger)sectionNumber
{
    if (item)
    {
        [self startUpdate];
        
        ANSectionModel* section = [self _createSectionIfNotExist:sectionNumber];
        NSUInteger numberOfItems = [section numberOfObjects];
        [section.objects addObject:item];
        [[self loadCurrentUpdate].insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:numberOfItems
                                                                               inSection:sectionNumber]];
        [self finishUpdate];
    }
}

- (void)_addItems:(NSArray *)items toSection:(NSUInteger)sectionNumber
{
    [self startUpdate];
    
    ANSectionModel* section = [self _createSectionIfNotExist:sectionNumber];
    
    for (id item in items)
    {
        NSUInteger numberOfItems = [section numberOfObjects];
        [section.objects addObject:item];
        [[self loadCurrentUpdate].insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:numberOfItems
                                                                               inSection:sectionNumber]];
    }
    [self finishUpdate];
}

- (void)_addItem:(id)item atIndexPath:(NSIndexPath *)indexPath
{
    [self startUpdate];
    // Update datasource
    ANSectionModel * section = [self _createSectionIfNotExist:indexPath.section];
    
    if ([section.objects count] < indexPath.row)
    {
        NSLog(@"ANMemoryStorage: failed to insert item for section: %ld, row: %ld, only %lu items in section",
              (long)indexPath.section,
              (long)indexPath.row,
              (unsigned long)[section.objects count]);
        return;
    }
    [section.objects insertObject:item atIndex:indexPath.row];
    
    [[self loadCurrentUpdate].insertedRowIndexPaths addObject:indexPath];
    
    [self finishUpdate];
}

#pragma mark Removing Itmes

- (void)_removeItem:(id)item
{
    [self startUpdate];
    
    NSIndexPath * indexPath = [self indexPathForItem:item];
    
    if (indexPath)
    {
        ANSectionModel* section = [self _createSectionIfNotExist:indexPath.section];
        [section.objects removeObjectAtIndex:indexPath.row];
    }
    else
    {
        NSLog(@"ANMemoryStorage: item to delete: %@ was not found", item);
        return;
    }
    [[self loadCurrentUpdate].deletedRowIndexPaths addObject:indexPath];
    [self finishUpdate];
}

- (void)_removeItemsAtIndexPaths:(NSArray *)indexPaths
{
    [self startUpdate];
    for (NSIndexPath* indexPath in indexPaths)
    {
        id object = [self objectAtIndexPath:indexPath];
        
        if (object)
        {
            ANSectionModel* section = [self _createSectionIfNotExist:indexPath.section];
            [section.objects removeObjectAtIndex:indexPath.row];
            [[self loadCurrentUpdate].deletedRowIndexPaths addObject:indexPath];
        }
        else
        {
            NSLog(@"ANMemoryStorage: item to delete was not found at indexPath : %@ ", indexPath);
        }
    }
    [self finishUpdate];
}

- (void)_removeItems:(NSArray *)items
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
    
    [[self loadCurrentUpdate].deletedRowIndexPaths addObjectsFromArray:indexPaths];
    [self finishUpdate];
}

- (void)_removeAllItems
{
    [self.sections removeAllObjects];
    [self clearStorageUpdate];
    [self.delegate storageNeedsReload];
}

#pragma mark Changing and Reorder Items

- (void)_replaceItem:(id)itemToReplace withItem:(id)replacingItem
{
    [self startUpdate];
    
    NSIndexPath * originalIndexPath = [self indexPathForItem:itemToReplace];
    if (originalIndexPath && replacingItem)
    {
        ANSectionModel * section = [self _createSectionIfNotExist:originalIndexPath.section];
        
        [section.objects replaceObjectAtIndex:originalIndexPath.row
                                   withObject:replacingItem];
    }
    else
    {
        NSLog(@"ANMemoryStorage: failed to replace item %@ at indexPath: %@", replacingItem, originalIndexPath);
        return;
    }
    [[self loadCurrentUpdate].updatedRowIndexPaths addObject:originalIndexPath];
    
    [self finishUpdate];
}

- (void)_moveItemFromIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath
{
    //TODO: add safely
    ANSectionModel * fromSection = [self sections][fromIndexPath.section];
    ANSectionModel * toSection = [self sections][toIndexPath.section];
    id tableItem = fromSection.objects[fromIndexPath.row];
    
    if (fromIndexPath && toIndexPath)
    {
        id testItem = [fromSection.objects objectAtIndex:fromIndexPath.row];
        
        [self startUpdate];
        [fromSection.objects removeObjectAtIndex:fromIndexPath.row];
        [toSection.objects insertObject:tableItem atIndex:toIndexPath.row];
        ANStorageMovedIndexPath *path = [ANStorageMovedIndexPath new];
        path.fromIndexPath = fromIndexPath;
        path.toIndexPath = toIndexPath;
        
        [[self loadCurrentUpdate].movedRowsIndexPaths addObject:path];
        
        [self finishUpdate];
    }
}

#pragma mark Reload Items

- (void)_reloadItem:(id)item
{
    [self startUpdate];
    
    NSIndexPath * indexPathToReload = [self indexPathForItem:item];
    
    if (indexPathToReload)
    {
        [[self loadCurrentUpdate].updatedRowIndexPaths addObject:indexPathToReload];
    }
    
    [self finishUpdate];
}

#pragma mark Get indexPath or items
- (NSArray *)_indexPathArrayForItems:(NSArray *)items
{
    NSMutableArray * indexPaths = [[NSMutableArray alloc] initWithCapacity:[items count]];

    for (NSInteger i = 0; i < [items count]; i++)
    {
        NSIndexPath * foundIndexPath = [self indexPathForItem:[items objectAtIndex:i]];
        if (!foundIndexPath)
        {
            NSLog(@"ANMemoryStorage: object %@ not found", [items objectAtIndex:i]);
        }
        else
        {
            [indexPaths addObject:foundIndexPath];
        }
    }
    return indexPaths;
}

- (id)_itemAtIndexPath:(NSIndexPath *)indexPath
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
            NSLog(@"ANMemoryStorage: Row not found while searching for item");
        }
    }
    else
    {
        NSLog(@"ANMemoryStorage: Section not found while searching for item");
    }
    return object;
}

- (NSIndexPath *)_indexPathForItem:(id)item
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

- (NSArray *)_itemsInSection:(NSUInteger)sectionNumber
{
    NSArray* objects;
    if ([self.sections count] > sectionNumber)
    {
        ANSectionModel* section = self.sections[sectionNumber];
        objects = [section objects];
    }
    return objects;
}

#pragma mark - private

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
            ANSectionModel* section = [ANSectionModel new];
            [self.sections addObject:section];
            [[self loadCurrentUpdate].insertedSectionIndexes addIndex:sectionIterator];
        }
        return [self.sections lastObject];
    }
}

@end
