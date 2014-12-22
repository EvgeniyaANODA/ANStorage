//
//  ANCoreDataStorage.h
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANBaseStorage.h"
@import CoreData;

/**
 This class is used to provide CoreData storage. Storage object will automatically react to NSFetchResultsController changes and will call delegate with appropriate DTStorageUpdate object.
 */

@interface ANCoreDataStorage : ANBaseStorage <NSFetchedResultsControllerDelegate, ANStorageInterface>

@property (nonatomic, strong) ANStorageUpdate * currentUpdate;
@property (nonatomic, assign) BOOL useMovingRows;

/**
 Use this method to create `DTCoreDataStorage` object with your NSFetchedResultsController.
 
 @param controller NSFetchedResultsController instance, that will be used as datasource.
 
 @return `DTCoreDataStorage` object.
 */

+(instancetype)storageWithFetchResultsController:(NSFetchedResultsController *)controller;

/**
 NSFetchedResultsController of current `DTCoreDataStorage` object.
 */
@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;

- (void)finishUpdate;


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type;


@end
