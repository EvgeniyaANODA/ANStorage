//
//  ANMemoryStorage+ANItems.h
//  Pods
//
//  Created by Dmitriy Frolow on 15/07/15.
//
//

#import "ANMemoryStorage.h"

@interface ANMemoryStorage (ANItems)

#pragma mark Add Items
- (void)_addItem:(id)item;
- (void)_addItems:(NSArray*)items;
- (void)_addItem:(id)item toSection:(NSUInteger)sectionIndex;
- (void)_addItems:(NSArray*)items toSection:(NSUInteger)sectionIndex;
- (void)_addItem:(id)item atIndexPath:(NSIndexPath *)indexPath;

#pragma mark Removing Itmes
- (void)_removeItem:(id)item;
- (void)_removeItemsAtIndexPaths:(NSArray *)indexPaths;

// Removing items. If some item is not found, it is skipped.
- (void)_removeItems:(NSArray*)items;
- (void)_removeAllItems;

#pragma mark Changing and Reorder Items
// Replace itemToReplace with replacingItem. If itemToReplace is not found, or replacingItem is nil, this method does nothing.
- (void)_replaceItem:(id)itemToReplace withItem:(id)replacingItem;
- (void)_moveItemFromIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath;

#pragma mark Reload Items
- (void)_reloadItem:(id)item;

#pragma mark Get indexPath or items
- (NSArray *)_indexPathArrayForItems:(NSArray *)items;
- (id)_itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)_indexPathForItem:(id)item;
- (NSArray *)_itemsInSection:(NSUInteger)sectionNumber;

@end
