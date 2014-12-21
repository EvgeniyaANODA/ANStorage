//
//  ANStorageInterface.h
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANStorageUpdate.h"
#import "ANStorageUpdatingInterface.h"

@protocol ANStorageInterface <NSObject>

@required

@property (nonatomic, weak) id <ANStorageUpdatingInterface> delegate;

- (NSArray*)sections;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;


@optional

- (id)headerModelForSectionIndex:(NSInteger)index;
- (id)footerModelForSectionIndex:(NSInteger)index;

- (void)setSupplementaryHeaderKind:(NSString *)headerKind;
- (void)setSupplementaryFooterKind:(NSString *)footerKind;

- (id)supplementaryModelOfKind:(NSString *)kind forSectionIndex:(NSUInteger)sectionNumber;

/**
 Method to create filtered data storage, based on current data storage and passed searchString and searchScope.
 @return searching data storage.
 */

- (instancetype)searchingStorageForSearchString:(NSString *)searchString inSearchScope:(NSUInteger)searchScope;

@end
