//
//  DTMemoryStorage.h
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

#import "DTBaseStorage.h"
#import "DTSectionModel.h"
#import "ANTableControllerHeader.h"

@interface DTMemoryStorage : DTBaseStorage <DTStorageProtocol>

@property (nonatomic, strong) NSMutableArray * sections;

+(instancetype)storage;

- (void)batchUpdateWithBlock:(ANCodeBlock)block;


#pragma mark - Items


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


#pragma mark - Changing and Reorder Items

// Replace itemToReplace with replacingItem. If itemToReplace is not found, or replacingItem is nil, this method does nothing.
- (void)replaceItem:(id)itemToReplace withItem:(id)replacingItem;

- (void)moveItemFromIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath;



#pragma mark - Sections

- (void)deleteSections:(NSIndexSet*)indexSet;
- (DTSectionModel*)sectionAtIndex:(NSUInteger)sectionIndex;

#pragma mark - Views Models

- (void)setSupplementaries:(NSArray *)supplementaryModels forKind:(NSString *)kind;

/**
 Set header models for sections. `DTSectionModel` objects are created automatically, if they don't exist already. Pass nil or empty array to this method to clear all section header models.
 
 @param headerModels Section header models to use.
 */
- (void)setSectionHeaderModels:(NSArray *)headerModels;
- (void)setSectionFooterModels:(NSArray *)footerModels;

- (void)setSectionHeaderModel:(id)headerModel forSectionIndex:(NSUInteger)sectionIndex;
- (void)setSectionFooterModel:(id)footerModel forSectionIndex:(NSUInteger)sectionIndex;



// Remove all items in section and replace them with array of items. After replacement is done, storageNeedsReload delegate method is called.

- (void)setItems:(NSArray *)items forSectionIndex:(NSUInteger)sectionIndex;


#pragma mark - Search

/**
 Use this method to add rules for storage to filter models, when using, for example, UISearchBar. This method works similar to deprecated `DTModelSearching` protocol and is a direct replacement for it.
 
 @param searchingBlock Block, that will be executed for all models of modelClass class to filter models for current criteria.
 
 @param modelClass Class of the model, which will use searchingBlock.
 */
- (void)setSearchingBlock:(DTModelSearchingBlock)searchingBlock forModelClass:(Class)modelClass;

/**
 Returns array with items in section.
 
 @param sectionIndex Number of the section.
 
 @return array of items in section. If section does not exist - nil.
 */
-(NSArray *)itemsInSection:(NSUInteger)sectionIndex;

/**
 If item exists at `indexPath`, it will be returned. If section or row does not exist, method will return `nil`.
 
 @param indexPath Index of the item you wish to retrieve.
 
 @return model at indexPath. If section or row does not exist - `nil`.
 */

-(id)itemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Searches for item and returns it's indexPath. If there are many equal items, indexPath of the first one will be returned.
 
 @param item Item, position of which you wish to find.
 
 @return indexPath of `item`.
 */
-(NSIndexPath *)indexPathForItem:(id)item;

@end
