//
//  ANCoreDataStorage.h
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANBaseStorage.h"
#import "ANSectionModel.h"
#import "ANHelperFunctions.h"

typedef NSPredicate*(^ANMemoryStoragePredicate)(NSString* searchString, NSInteger scope);

@interface ANMemoryStorage : ANBaseStorage <ANStorageInterface>

@property (nonatomic, strong) NSMutableArray * sections;

+(instancetype)storage;

- (void)batchUpdateWithBlock:(ANCodeBlock)block;


#pragma mark - Items

- (BOOL)hasItems;

#pragma mark - Adding Items

// Add item to section 0.
- (void)addItem:(id)item;

// Add items to section 0.
- (void)addItems:(NSArray*)items;

- (void)addItem:(id)item toSection:(NSUInteger)sectionIndex;
- (void)addItems:(NSArray*)items toSection:(NSUInteger)sectionIndex;

- (void)addItem:(id)item atIndexPath:(NSIndexPath *)indexPath;


#pragma mark - Reloading Items

- (void)reloadItem:(id)item;


#pragma mark - Removing Items

- (void)removeItem:(id)item;
- (void)removeItemsAtIndexPaths:(NSArray *)indexPaths;

// Removing items. If some item is not found, it is skipped.
- (void)removeItems:(NSArray*)items;
- (void)removeAllItems;

#pragma mark - Changing and Reorder Items

// Replace itemToReplace with replacingItem. If itemToReplace is not found, or replacingItem is nil, this method does nothing.
- (void)replaceItem:(id)itemToReplace withItem:(id)replacingItem;

- (void)moveItemFromIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath;



#pragma mark - Sections

- (void)deleteSections:(NSIndexSet*)indexSet;
- (ANSectionModel*)sectionAtIndex:(NSUInteger)sectionIndex;

#pragma mark - Views Models

- (void)setSupplementaries:(NSArray *)supplementaryModels forKind:(NSString *)kind;

/**
 Set header models for sections. `ANSectionModel` objects are created automatically, if they don't exist already. Pass nil or empty array to this method to clear all section header models.
 
 @param headerModels Section header models to use.
 */
- (void)setSectionHeaderModels:(NSArray *)headerModels;
- (void)setSectionFooterModels:(NSArray *)footerModels;

- (void)setSectionHeaderModel:(id)headerModel forSectionIndex:(NSUInteger)sectionIndex;
- (void)setSectionFooterModel:(id)footerModel forSectionIndex:(NSUInteger)sectionIndex;



// Remove all items in section and replace them with array of items. After replacement is done, storageNeedsReload delegate method is called.

- (void)setItems:(NSArray *)items forSectionIndex:(NSUInteger)sectionIndex;

#pragma mark - Get Items

- (NSArray *)itemsInSection:(NSUInteger)sectionIndex;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForItem:(id)item;


#pragma mark - Searching

@property (nonatomic, copy) ANMemoryStoragePredicate storagePredicateBlock;

@end
