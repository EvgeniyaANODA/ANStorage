//
//  ANMemoryStorage+ANSection.h
//  Pods
//
//  Created by Dmitriy Frolow on 15/07/15.
//
//

#import "ANMemoryStorage.h"

@interface ANMemoryStorage (ANSection)

#pragma mark - Sections

- (void)_removeSections:(NSIndexSet*)indexSet;
- (ANSectionModel*)_sectionAtIndex:(NSUInteger)sectionIndex;
- (ANSectionModel*)_sectionAtIndex:(NSUInteger)sectionIndex createIfNeeded:(BOOL)shouldCreate;

#pragma mark - Views Models

- (void)_setSupplementaries:(NSArray *)supplementaryModels forKind:(NSString *)kind;

/**
 Set header models for sections. `ANSectionModel` objects are created automatically, if they don't exist already. Pass nil or empty array to this method to clear all section header models.
 
 @param headerModels Section header models to use.
 */
- (void)_setSectionHeaderModels:(NSArray *)headerModels;
- (void)_setSectionFooterModels:(NSArray *)footerModels;

- (void)_setSectionHeaderModel:(id)headerModel forSectionIndex:(NSUInteger)sectionIndex;
- (void)_setSectionFooterModel:(id)footerModel forSectionIndex:(NSUInteger)sectionIndex;



// Remove all items in section and replace them with array of items. After replacement is done, storageNeedsReload delegate method is called.

- (void)_setItems:(NSArray *)items forSectionIndex:(NSUInteger)sectionIndex;
- (ANSectionModel*)_sectionAtIndex:(NSUInteger)sectionNumber createIfNotExist:(BOOL)createIfNotExist;
- (ANSectionModel *)_createSectionIfNotExist:(NSUInteger)sectionNumber;

#pragma views part

- (id)_supplementaryModelOfKind:(NSString *)kind forSectionIndex:(NSUInteger)sectionNumber;
- (void)_setSupplementaries:(NSArray *)supplementaryModels forKind:(NSString *)kind;

@end
